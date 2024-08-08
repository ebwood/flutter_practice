import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';

import 'package:flutter_vap/flutter_vap.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> downloadPathList = [];
  bool isDownload = false;

  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    initDownloadPath();
    _controller = VideoPlayerController.asset('static/video.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
        _controller.play();
      });
  }

  Future<void> initDownloadPath() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String rootPath = appDocDir.path;
    downloadPathList = ["$rootPath/vap_demo1.mp4", "$rootPath/vap_demo2.mp4"];
    print("downloadPathList:$downloadPathList");
  }

  double scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        home: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 140, 41, 43),
              // image: DecorationImage(image: AssetImage("static/bg.jpeg")),
            ),
            child: Stack(alignment: Alignment.bottomCenter, children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CupertinoButton(
                    color: Colors.purple,
                    child:
                        Text("download video source${isDownload ? "(✅)" : ""}"),
                    onPressed: _download,
                  ),
                  CupertinoButton(
                    color: Colors.purple,
                    child: Text("File1 play"),
                    onPressed: () => _playFile(downloadPathList[0]),
                  ),
                  CupertinoButton(
                    color: Colors.purple,
                    child: Text("File2 play"),
                    onPressed: () => _playFile(downloadPathList[1]),
                  ),
                  CupertinoButton(
                    color: Colors.purple,
                    child: Text("asset play 0.5"),
                    onPressed: () {
                      setState(() {
                        scale = 0.5;
                      });
                      _playAsset("static/video.mp4");
                    },
                  ),
                  CupertinoButton(
                    color: Colors.purple,
                    child: Text("asset play"),
                    onPressed: () {
                      setState(() {
                        scale = 1.0;
                      });
                      _playAsset("static/video.mp4");
                    },
                  ),
                  CupertinoButton(
                    color: Colors.purple,
                    child: Text("asset play 2"),
                    onPressed: () {
                      setState(() {
                        scale = 2.0;
                      });
                      _playAsset("static/video.mp4");
                    },
                  ),
                  CupertinoButton(
                    color: Colors.purple,
                    child: Text("stop play"),
                    onPressed: () => VapController.stop(),
                  ),
                  CupertinoButton(
                    color: Colors.purple,
                    child: Text("queue play"),
                    onPressed: _queuePlay,
                  ),
                  CupertinoButton(
                    color: Colors.purple,
                    child: Text("cancel queue play"),
                    onPressed: _cancelQueuePlay,
                  ),
                ],
              ),
              IgnorePointer(
                // VapView可以通过外层包Container(),设置宽高来限制弹出视频的宽高
                // VapView can set the width and height through the outer package Container() to limit the width and height of the pop-up video
                child: Transform.scale(
                  scale: 1.0,
                  child: Container(
                      width: MediaQuery.of(context).size.width * scale,
                      height: MediaQuery.of(context).size.height * scale,
                      child: VapView()),
                ),
              ),
              _controller.value.isInitialized
                  ? Visibility(
                    visible: false,
                    child: Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                            });
                          },
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      ),
                  )
                  : Container(),
            ]),
          ),
        ),
      ),
    );
  }

  _download() async {
    await Dio().download(
        "http://file.jinxianyun.com/vap_demo1.mp4", downloadPathList[0]);
    await Dio().download(
        "http://file.jinxianyun.com/vap_demo2.mp4", downloadPathList[1]);
    setState(() {
      isDownload = true;
    });
  }

  Future<Map<dynamic, dynamic>?> _playFile(String path) async {
    if (path == null) {
      return null;
    }
    var res = await VapController.playPath(path);
    if (res!["status"] == "failure") {
      showToast(res["errorMsg"]);
    }
    return res;
  }

  Future<Map<dynamic, dynamic>?> _playAsset(String asset) async {
    if (asset == null) {
      return null;
    }
    var res = await VapController.playAsset(asset);
    if (res!["status"] == "failure") {
      showToast(res["errorMsg"]);
    }
    return res;
  }

  _queuePlay() async {
    // 模拟多个地方同时调用播放,使得队列执行播放。
    // Simultaneously call playback in multiple places, making the queue perform playback.
    QueueUtil.get("vapQueue")
        ?.addTask(() => VapController.playPath(downloadPathList[0]));
    QueueUtil.get("vapQueue")
        ?.addTask(() => VapController.playPath(downloadPathList[1]));
  }

  _cancelQueuePlay() {
    QueueUtil.get("vapQueue")?.cancelTask();
  }
}
