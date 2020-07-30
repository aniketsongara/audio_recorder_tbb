import 'dart:io' as io;
import 'dart:math';
import 'dart:async';
import 'dart:typed_data';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

void main() {
  runApp(new MyApp());
}

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
  List<io.FileSystemEntity> _audio = new List<io.FileSystemEntity>();
  List<io.FileSystemEntity> _thumbnail = new List<io.FileSystemEntity>();
  List<String> audioName = new List<String>();
  List<String> thumbnailName =  new List<String>();
  bool playerState = false;

  Future _loadFile() async {
    setState(() {
      _audio.clear();
      audioName.clear();
      _thumbnail.clear();
      thumbnailName.clear();
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
          if (path.endsWith('.m4a') || path.contains('JPEG') || path.endsWith('.mp3') ||
              path.endsWith('.mp4')) {

            print('Added Audio & Video Data....!!!!!!!!!!!!');
            setState(() {
              _audio.add(entity);
              audioName
                  .add(entity.path.replaceAll('${directory.path}/TBB/', ''));
            });

          } else if (path.endsWith('.png')) {
            print('Added Png Data....!!!!!!!!!!!!');
            setState(() {
              _thumbnail.add(entity);
              thumbnailName
                  .add(entity.path.replaceAll('${directory.path}/TBB/', ''));
            });
          }
        }
      }
    });
    print('List of array _thumbnail is : $_thumbnail');
    print('List of array thumbnailName is : $thumbnailName');
  }

 Widget ImagePreview(io.File imageFile){
    return AlertDialog(
      contentPadding: const EdgeInsets.all(5),
      content: Image.file(imageFile),
    );
  }

  deleteFile(String filePath, String fileName) async {
    if (filePath.contains('mp4')) {
      for (int p = 0; p < _thumbnail.length; p++) {
        if (thumbnailName[p].replaceAll('.png', '').contains(
            fileName.replaceAll('.mp4', ''))) {
          final dir = io.Directory(_thumbnail[p].path);
          dir.deleteSync(recursive: true);
        }
      }

      final dir = io.Directory(filePath);
      dir.deleteSync(recursive: true);
    } else {
      final dir = io.Directory(filePath);
      dir.deleteSync(recursive: true);
    }
    _loadFile();
  }

  Future<bool> checkPermission() async {
    print('Checking permissions.....');
    if (!await Permission.microphone.isGranted &&
        !await Permission.storage.isGranted) {
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
      list = _audio;
    });
    ListView myList = new ListView.builder(
        padding: const EdgeInsets.only(
            top: 16.0, bottom: 16.0, left: 10.0, right: 10.0),
        itemCount: list.length,
        itemBuilder: (context, i) {
          return ListTile(
            leading: _audio[i].path.endsWith('.mp4') ?
            Container(
              width: 45.0,
              height: 45.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(_thumbnail[thumbnailName.indexOf(
                        audioName[i].replaceAll('.mp4', '.png'))],)),
                borderRadius: BorderRadius.all(Radius.circular(200.0)),
                color: Theme
                    .of(context)
                    .primaryColor,
              ),
              child: Center(
                child: Icon(Icons.play_arrow, color: Colors.white70,),),
            )
                : _audio[i].path.endsWith('.JPEG') ?
            CircleAvatar(
              backgroundImage:
              FileImage(_audio[i]),
            )
                :
            CircleAvatar(
              backgroundColor: Theme
                  .of(context)
                  .primaryColor,
              child: Icon(Icons.settings_voice,
                color: Colors.white,
              ),
            ),
            title: Text('${audioName[i]}'),
            trailing: IconButton(
              onPressed: () {
                deleteFile(_audio[i].path, audioName[i]);
              },
              icon: Icon(
                Icons.delete,
                color: Colors.black54,
              ),
            ),
            onTap: () {
              if (_audio[i].path.contains('mp3') ||
                  _audio[i].path.contains('m4a'))  {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) {
                      return PlayerWidget(
                        url: _audio[i].uri.toString(),
                      );
                    });
              } else if (_audio[i].path.contains('JPEG'))  {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) {
                      return ImagePreview(_audio[i]);
                    });
              } else {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) {
                      return VideoPlayerScreen(_audio[i],
                      );
                    });
                // Navigator.push(context, MaterialPageRoute(builder: (context)=>VideoPlayerScreen(_files[i])));
              }
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
          : _audio.length > 0
          ? getList()
          : Center(
        child: Text('No Data Found !'),
      ),
      floatingActionButton:
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Visibility(child: FloatingActionButton(
            onPressed: _videoStart,
            child: Icon(Icons.videocam),
            tooltip: "Capture a video",
          ), visible: !_isRecording,),
          const SizedBox(
            width: 5.0,
          ),
          Visibility(child: FloatingActionButton(
            onPressed: _takePicture,
            child: Icon(Icons.camera),
            tooltip: "Capture a video",
          ), visible: !_isRecording,),
          const SizedBox(
            width: 5.0,
          ),
          FloatingActionButton(
            backgroundColor:
            _isRecording ? Colors.green : Theme
                .of(context)
                .primaryColor,
            onPressed: _isRecording
                ? _stopAudioRecording
                : _startAudioRecording,
            child: Icon(Icons.mic ),
          )
        ],
      )
      ,
    );
  }

  void logError(String code, String message) =>
      print('Error: $code\nError Message: $message');

  _startAudioRecording() async {
    bool hasPermission = await checkPermission();
    try {
      if (hasPermission) {
        setState(() {
          btnStatus = true;
        });

        createDirectory();
        String fileName =
            'AUD_${DateTime
            .now()
            .day}-${DateTime
            .now()
            .month}-${DateTime
            .now()
            .year}_${DateTime
            .now()
            .hour}:${DateTime
            .now()
            .minute}:${DateTime
            .now()
            .second}:${DateTime
            .now()
            .millisecond}';
        await AudioRecorder.start(
            path: dir.path + '/TBB/' + fileName,
            audioOutputFormat: AudioOutputFormat.AAC);

        print(
            '*********************************custom recording path is : ${dir
                .path + '/TBB/' + fileName}*********************************');

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

  _stopAudioRecording() async {
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
        '*********************************Recording path is : ${recording
            .path}*********************************');
  }

  _videoStart() async
  {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      createDirectory();
      _videoRecord();
    } else {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: new Text("You must accept permissions")));
    }
  }

  _takePicture() async{
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      createDirectory();
      try {
        final io.File image = await ImagePicker.pickImage(
            source: ImageSource.camera,);

        io.Directory localDir = await getExternalStorageDirectory();
        String fileName =
            'IMG_${DateTime
            .now()
            .day}-${DateTime
            .now()
            .month}-${DateTime
            .now()
            .year}_${DateTime
            .now()
            .hour}:${DateTime
            .now()
            .minute}:${DateTime
            .now()
            .second}:${DateTime
            .now()
            .millisecond}';

        final io.File newImage = await image.copy(
            '${localDir.path}/TBB/$fileName.JPEG');

        final tempDir = io.Directory(image.path);
        tempDir.deleteSync(recursive: true);

        if (newImage.path != null) {

          print('Calling File load method........!!!!!!');
          Future.delayed(Duration(seconds: 1),_loadFile);
        }
      } catch (e) {
        print('Error is : ' + e.toString());
      }
    } else {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: new Text("You must accept permissions")));
    }
  }


  Future _videoRecord() async {
    try {
      final io.File video = await ImagePicker.pickVideo(
          source: ImageSource.camera);

      io.Directory localDir = await getExternalStorageDirectory();
      String fileName =
          'VID_${DateTime
          .now()
          .day}-${DateTime
          .now()
          .month}-${DateTime
          .now()
          .year}_${DateTime
          .now()
          .hour}:${DateTime
          .now()
          .minute}:${DateTime
          .now()
          .second}:${DateTime
          .now()
          .millisecond}';

      final io.File newVideo = await video.copy(
          '${localDir.path}/TBB/$fileName.mp4');

      final tempDir = io.Directory(video.path);
      tempDir.deleteSync(recursive: true);

      genThumbnailFile(
          '${localDir.path}/TBB/$fileName.mp4', localDir.path + '/TBB/');


      if (newVideo.path != null) {

        print('Calling Video load method........!!!!!!');
        Future.delayed(Duration(seconds: 1),_loadFile);
      }
    } catch (e) {
      print('Error is : ' + e.toString());
    }
  }

  genThumbnailFile(String _videoPath, String _tempDir) async {
    //WidgetsFlutterBinding.ensureInitialized();
    Uint8List bytes;
    //final Completer<String> completer = Completer();
    if (_tempDir != null) {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: _videoPath,
          thumbnailPath: _tempDir,
          imageFormat: ImageFormat.PNG,
          maxHeight: 300,
          maxWidth: 300,
          timeMs: 0,
          quality: 50);

      print("thumbnail file is located: $thumbnailPath");

      final file = io.File(thumbnailPath);
      bytes = file.readAsBytesSync();
    } else {
      bytes = await VideoThumbnail.thumbnailData(
          video: _videoPath,
          imageFormat: ImageFormat.PNG,
          maxHeight: 300,
          maxWidth: 300,
          timeMs: 0,
          quality: 50);
    }

    int _imageDataSize = bytes.length;
    print("image size: $_imageDataSize");

    //return r.thumbnailPath;
  }

}


class VideoPlayerScreen extends StatefulWidget {
  io.File _file;

  VideoPlayerScreen(this._file);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {

  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget._file);

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      content: Container(
        // padding: const EdgeInsets.all(20),
        color: Colors.transparent,
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              VideoPlayer(_controller),
              _PlayPauseOverlay(controller: _controller),
              VideoProgressIndicator(_controller, allowScrubbing: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({Key key, this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
            color: Colors.black26,
            child: Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 100.0,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}

enum PlayerState { stopped, playing, paused }

class PlayerWidget extends StatefulWidget {
  final String url;
  final PlayerMode mode;

  PlayerWidget(
      {Key key, @required this.url, this.mode = PlayerMode.MEDIA_PLAYER})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState(url, mode);
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  String url;
  PlayerMode mode;

  AudioPlayer _audioPlayer;
  Duration _duration;
  Duration _position;

  PlayerState _playerState = PlayerState.stopped;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  get _isPlaying => _playerState == PlayerState.playing;

  get _isPaused => _playerState == PlayerState.paused;

  get _durationText =>
      _duration
          ?.toString()
          ?.split('.')
          ?.first ?? '';

  get _positionText =>
      _position
          ?.toString()
          ?.split('.')
          ?.first ?? '';

  _PlayerWidgetState(this.url, this.mode);

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                key: Key('play_button'),
                iconSize: 35.0,
                onPressed: _isPlaying ? _pause : _play,
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                color: Theme
                    .of(context)
                    .primaryColor,
              ),
              IconButton(
                key: Key('stop_button'),
                onPressed: _isPlaying || _isPaused ? () => _stop() : null,
                icon: Icon(Icons.stop),
                iconSize: 35.0,
                color: Theme
                    .of(context)
                    .primaryColor,
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Stack(
                  children: [
                    Slider(
                      onChanged: (v) {
                        final position = v * _duration.inMilliseconds;
                        _audioPlayer
                            .seek(Duration(milliseconds: position.round()));
                      },
                      value: (_position != null &&
                          _duration != null &&
                          _position.inMilliseconds > 0 &&
                          _position.inMilliseconds <
                              _duration.inMilliseconds)
                          ? _position.inMilliseconds / _duration.inMilliseconds
                          : 0.0,
                    ),
                  ],
                ),
              ),
              Text(
                _position != null
                    ? '${_positionText ?? ''} / ${_durationText ?? ''}'
                    : _duration != null ? _durationText : '',
                // style: TextStyle(fontSize: 24.0),
              ),
            ],
          ),
          //Text('State: $_audioPlayerState')
        ],
      ),
    );
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer(mode: mode);

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);

      // TODO implemented for iOS, waiting for android impl
      if (Theme
          .of(context)
          .platform == TargetPlatform.iOS) {
        // (Optional) listen for notification updates in the background
        _audioPlayer.startHeadlessService();

        // set at least title to see the notification bar on ios.
        _audioPlayer.setNotification(
            title: 'App Name',
            artist: 'Artist or blank',
            albumTitle: 'Name or blank',
            imageUrl: 'url or blank',
            forwardSkipInterval: const Duration(seconds: 30),
            // default is 30s
            backwardSkipInterval: const Duration(seconds: 30),
            // default is 30s
            duration: duration,
            elapsedTime: Duration(seconds: 0));
      }
    });

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) =>
            setState(() {
              _position = p;
            }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
          _onComplete();
          setState(() {
            _position = _duration;
          });
        });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });
    _play();
  }

  void _play() async {
    final playPosition = (_position != null &&
        _duration != null &&
        _position.inMilliseconds > 0 &&
        _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(url, position: playPosition);
    if (result == 1) setState(() => _playerState = PlayerState.playing);

    // default playback rate is 1.0
    // this should be called after _audioPlayer.play() or _audioPlayer.resume()
    // this can also be called everytime the user wants to change playback rate in the UI
    _audioPlayer.setPlaybackRate(playbackRate: 1.0);

    //return result;
  }

  void _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    //return result;
  }

  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration();
      });
    }
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
  }
}
