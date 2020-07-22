import 'dart:io' as io;
import 'dart:math';
import 'dart:async';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'player_widget.dart';
import 'package:camera/camera.dart';
import 'video_recorder.dart';

List<CameraDescription> cameras = [];
void main() {
  runApp(new MyApp());}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        debugShowCheckedModeBanner: false,
      home: new Scaffold(
        body: new AppBody(),
      ),
    );
  }
}


class AppBody extends StatefulWidget {
  final LocalFileSystem localFileSystem;

  AppBody({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  State<StatefulWidget> createState() => new AppBodyState();
}

class AppBodyState extends State<AppBody> {
  //Recording _recording = new Recording();
  bool _isRecording = false;
  Random random = new Random();
  bool btnStatus = false;
  AudioPlayer audioPlayer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadFile();
  }

  var dir;

  createDirectory() async {
    dir = await getExternalStorageDirectory();
    final myDir = new io.Directory('${dir.path}/TBB');
    myDir.exists().then((isThere) {
      if (!isThere) {
        new io.Directory('${dir.path}/TBB').create(recursive: true)
            // The created directory is returned as a Future.
            .then((io.Directory directory) {
          print(
              '-------------------${directory.path}--------------------------');
        });
      } else {
        print('_________exists_______________________');
      }
    });
  }

  List<io.FileSystemEntity> _files;
  List<io.FileSystemEntity> _songs = new List<io.FileSystemEntity>();
  List<String> audioName = [];
  bool playerState = false;

  Future _loadFile() async {
    setState(() {
      _songs.clear();
      audioName.clear();
    });

    io.Directory directory = await getExternalStorageDirectory();
    final myDir = new io.Directory('${directory.path}/TBB/');

    String mp3Path = myDir.toString();
    print('mp3path ' + mp3Path);
    myDir.exists().then((isThere) {
      if (isThere) {
        _files = myDir.listSync(recursive: true, followLinks: false);
        for (io.FileSystemEntity entity in _files) {
          String path = entity.path;
          if (path.endsWith('.m4a') || path.endsWith('.mp4'))
            setState(() {
              _songs.add(entity);
              audioName
                  .add(entity.path.replaceAll('${directory.path}/TBB/', ''));
            });
        }
      }
    });
    print('List of array songs is : $_songs');
    print('List of array songs NAme is : $audioName');
  }

  deleteFile(String filePath) async {
    final dir = io.Directory(filePath);
    dir.deleteSync(recursive: true);
    _loadFile();
  }

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus statusMicrophone = await Permission.microphone.request();
      PermissionStatus statusStorage = await Permission.storage.request();
      if (statusMicrophone != PermissionStatus.granted &&
          statusStorage != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Widget getList() {
    List<io.FileSystemEntity> list;
    setState(() {
      list = _songs;
    });
    ListView myList = new ListView.builder(
        padding: const EdgeInsets.only(
            top: 16.0, bottom: 16.0, left: 10.0, right: 10.0),
        itemCount: list.length,
        itemBuilder: (context, i) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                Icons.settings_voice,
                color: Colors.white,
              ),
            ),
            title: Text('${audioName[i]}'),
            trailing: IconButton(
              onPressed: () {
                deleteFile(_songs[i].path);
              },
              icon: Icon(
                Icons.delete,
                color: Colors.black54,
              ),
            ),
            onTap: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) {
                    return PlayerWidget(
                      url: _songs[i].uri.toString(),
                    );
                  });
            },
          );
        });

    return myList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TBB Recorder'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.keyboard_arrow_right), onPressed: ()async{
            try {
              WidgetsFlutterBinding.ensureInitialized();
              cameras = await availableCameras();
            } on CameraException catch (e) {
              logError(e.code, e.description);
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VideoHome()),
            );
          })
        ],
      ),
      body: _isRecording
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Icon(
                    Icons.record_voice_over,
                    color: Colors.green,
                    size: 60.0,
                  ),
                ),
                Center(
                  child: Text('Recording...'),
                )
              ],
            )
          : _songs.length > 0
              ? getList()
              : Center(
                  child: Text('No Data Found !'),
                ),
      floatingActionButton:
     /* Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            backgroundColor:
            _isRecording ? Colors.green : Theme.of(context).primaryColor,
            onPressed: _isRecording ? _stop : _start,
            child: Icon(_isRecording ? Icons.mic : Icons.mic_off),
          ),
          Padding(padding: EdgeInsets.all(6.0),),
          FloatingActionButton(
            backgroundColor:
            _isRecording ? Colors.green : Theme.of(context).primaryColor,
            onPressed: () async{
              try {
                WidgetsFlutterBinding.ensureInitialized();
                cameras = await availableCameras();
              } on CameraException catch (e) {
                logError(e.code, e.description);
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VideoRecorder()),
              );
            },
            child: Icon(_isRecording ? Icons.videocam : Icons.videocam_off),
          )
        ],
      )*/
     FloatingActionButton(
        backgroundColor:
        _isRecording ? Colors.green : Theme.of(context).primaryColor,
        onPressed: _isRecording ? _stop : _start,
        child: Icon(_isRecording ? Icons.mic : Icons.mic_off),
      ),
    );
  }
  void logError(String code, String message) =>
      print('Error: $code\nError Message: $message');
  _start() async {
    bool hasPermission = await checkPermission();
    try {
      if (hasPermission) {
        setState(() {
          btnStatus = true;
        });

        createDirectory();
        String fileName =
            '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}_${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}:${DateTime.now().millisecond}';
        await AudioRecorder.start(
            path: dir.path + '/TBB/' + fileName,
            audioOutputFormat: AudioOutputFormat.AAC);

        print(
            '*********************************custom recording path is : ${dir.path + '/TBB/' + fileName}*********************************');

        bool isRecording = await AudioRecorder.isRecording;
        setState(() {
          //_recording = new Recording(duration: new Duration(), path: "");
          _isRecording = isRecording;
        });
      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
    }
  }

  _stop() async {
    var recording = await AudioRecorder.stop();
    print("Stop recording: ${recording.path}");
    bool isRecording = await AudioRecorder.isRecording;
    File file = widget.localFileSystem.file(recording.path);
    _loadFile();
    print("  File length: ${await file.length()}");
    setState(() {
      //_recording = recording;
      _isRecording = isRecording;
    });
    print(
        '*********************************Recording path is : ${recording.path}*********************************');
  }
}


/*
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  */