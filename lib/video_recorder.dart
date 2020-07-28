
/*
//import 'package:camera/camera.dart';

//List<CameraDescription> cameras = [];


onPressed: ()async{
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
          }*/
/*
import 'dart:async';
import 'dart:io';
import 'main.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
//import 'package:video_thumbnail/video_thumbnail.dart';
class VideoHome extends StatefulWidget
{
  @override
  State<StatefulWidget> createState() {
    return VideoHomeState();
  }
}

class VideoHomeState extends State<VideoHome>
{
  List<FileSystemEntity> _files;
  List<FileSystemEntity> _videos = new List<FileSystemEntity>();
  List<String> videoName = [];
  bool playerState = false;


  @override
  void initState() {
    super.initState();
     _loadFile();
  }
  Future _loadFile() async {
    setState(() {
      _videos.clear();
      videoName.clear();
    });

    Directory directory = await getExternalStorageDirectory();
    final myDir = new Directory('${directory.path}/TBB/Videos/');

    String mp3Path = myDir.toString();
    print('mp3path ' + mp3Path);
    myDir.exists().then((isThere) {
      if (isThere) {
        _files = myDir.listSync(recursive: true, followLinks: false);
        for (FileSystemEntity entity in _files) {
          String path = entity.path;
          if (path.endsWith('.mp4'))
            setState(() {
              _videos.add(entity);
              videoName
                  .add(entity.path.replaceAll('${directory.path}/TBB/Videos/', ''));
            });
        }
      }
    });
    print('List of array songs is : $_videos');
    print('List of array songs NAme is : $videoName');
  }
  deleteFile(String filePath) async {
    final dir = Directory(filePath);
    dir.deleteSync(recursive: true);
    _loadFile();
  }
  Widget getList() {
    List<FileSystemEntity> list;
    setState(() {
      list = _videos;
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
                Icons.play_circle_outline,
                color: Colors.white,
              ),
            ),
            title: Text('${videoName[i]}'),
            trailing: IconButton(
              onPressed: () {
                deleteFile(_videos[i].path);
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
                    return VideoPlayerScreen(_videos[i]);
                  });
            },
          );
        });

    return myList;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Recorder TBB'),
      ),
      body:  _videos.length > 0
          ? getList()
          : Center(
        child: Text('No Data Found !'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:
        */
/*_isRecording ? Colors.green :*//*
 Theme.of(context).primaryColor,
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
        child: Icon(*/
/*_isRecording ? Icons.videocam : *//*
Icons.videocam_off),
      ),
    );
  }

}



class VideoPlayerScreen extends StatefulWidget {
  File _file;
  VideoPlayerScreen(this._file,{Key key}) : super(key: key);
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState(_file);
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  File _file;
  _VideoPlayerScreenState(this._file);

  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(_file);

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
    return AlertDialog(content: Container(
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

class VideoRecorder extends StatefulWidget {
  @override
  _VideoRecorderState createState() {
    return _VideoRecorderState();
  }
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _VideoRecorderState extends State<VideoRecorder>
    with WidgetsBindingObserver {
  CameraController controller;
  String imagePath;
  String videoPath;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  bool enableAudio = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getCameras();
    // onNewCameraSelected(cameras[0]);

  }


  final List<CameraDescription> toggles = <CameraDescription>[];

  _getCameras() {
    if (cameras.isEmpty) {
      showInSnackBar('No camera found');
    } else {
      for (CameraDescription cameraDescription in cameras) {
        toggles.add(cameraDescription);
      }
      onNewCameraSelected();
    }    //  return Row(children: toggles);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected();
      }
    }
  }


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Camera TBB'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: controller != null && controller.value.isRecordingVideo
                      ? Colors.redAccent
                      : Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
          ),
          _captureControlRowWidget(),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }


  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.sync),
          color: Colors.blue,
          onPressed: (){
            if(controller != null && controller.value.isRecordingVideo)
            {}
            else{
              setState(() {
                if(index==0)
                {
                  index =1;
                }else{
                  index =0;
                }
              });
              onNewCameraSelected();
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.videocam),
          color: Colors.blue,
          onPressed: controller != null &&
              controller.value.isInitialized &&
              !controller.value.isRecordingVideo
              ? onVideoRecordButtonPressed
              : null,
        ),
        IconButton(
          icon: controller != null && controller.value.isRecordingPaused
              ? Icon(Icons.play_arrow)
              : Icon(Icons.pause),
          color: Colors.blue,
          onPressed: controller != null &&
              controller.value.isInitialized &&
              controller.value.isRecordingVideo
              ? (controller != null && controller.value.isRecordingPaused
              ? onResumeButtonPressed
              : onPauseButtonPressed)
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.stop),
          color: Colors.red,
          onPressed: controller != null &&
              controller.value.isInitialized &&
              controller.value.isRecordingVideo
              ? onStopButtonPressed
              : null,
        )
      ],
    );
  }

 // String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
  String fileName =
      '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}_${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}:${DateTime.now().millisecond}';

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onNewCameraSelected() async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(
      toggles[index],
      ResolutionPreset.medium,
      enableAudio: enableAudio,
    );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      if (mounted) setState(() {});
      if (filePath != null) showInSnackBar('Recording start');
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recorded');
    });
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording resumed');
    });
  }

  Future<String> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    final Directory extDir = await getExternalStorageDirectory();
    final String dirPath = '${extDir.path}/TBB/Videos';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${fileName}.mp4';

    if (controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      videoPath = filePath;
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    //await _startVideoPlayer();
  }

  Future<void> pauseVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}
*/
