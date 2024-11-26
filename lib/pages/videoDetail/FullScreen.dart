import 'package:flutter/material.dart';
import 'package:qwara/EventBus/EventBus.dart';
import 'package:qwara/pages/videoDetail/ControlMask.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

import 'package:qwara/enum/Enum.dart';


class FullScreen extends StatefulWidget {
  const FullScreen({
    super.key, required this.controller, this.switchClarity,
  });
  final VideoPlayerController controller;
  final Function(Clarity clarity)? switchClarity;
  @override
  State<FullScreen> createState() => _FullScreenState();
}
class _FullScreenState extends State<FullScreen> {

  late VideoPlayerController _controller;

  void listener() {
      setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;

    if(_controller.value.aspectRatio>=1){
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }else{
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

// 全屏时隐藏系统状态栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    _controller.addListener(listener);
    eventBus.on<ControllerReloadEvent>().listen((event){
      setState(() {
        _controller = event.controller;
      });
      print("eventBus");
    });
  }
  bool showOverlay = false; // 控制遮罩层的显隐

  void _toggleOverlay() {
    setState(() {
      showOverlay = !showOverlay;
    });
  }

  void videoControl() {
    setState(() {
      _controller.value.isPlaying
          ? _controller.pause()
          : _controller.play();
    });
  }
  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(listener);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }
  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      backgroundColor: Colors.black,
      body: Hero(
        tag: "player",
        child: Stack(
          alignment: Alignment.center,
          children: [

            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),

            GestureDetector(
              onDoubleTap: (){
                videoControl();
              },
              onTap: (){
                _toggleOverlay();
              },
              child: showOverlay? Container(
                child: ControlMask(
                  switchClarity: widget.switchClarity,
                  controller: _controller,
                  fullScreen: true,
                  // width: MediaQuery.of(context).size.width ,
                  // height: MediaQuery.of(context).size.height,
                ),
              ): Container(
                color: Colors.transparent,
              ),// 不显示遮罩层时返回空容器,
            )

          ],
        ),

        // )
        // ),
      ),
    );
  }

}