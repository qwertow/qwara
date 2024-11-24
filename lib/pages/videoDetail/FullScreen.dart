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
  late double? videoWidth=null;
  late double? videoHeight=null;
  late VideoPlayerController _controller;

  void listener() {
      setState(() {});
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      // DeviceOrientation.portraitUp,
      // DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    _controller = widget.controller;

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
      // body: Stack(
      //   children: <Widget>[
      body: Center(
            child: Hero(
                tag: "player",
                child: GestureDetector(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                      showOverlay? ControlMask(
                        switchClarity: widget.switchClarity,
                        controller: _controller,
                        fullScreen: true,
                        width: MediaQuery.of(context).size.width ,
                        height: MediaQuery.of(context).size.height,
                      ): Container(),// 不显示遮罩层时返回空容器
                    ],
                  ),
                  onDoubleTap: (){
                    videoControl();
                  },
                  onTap: (){
                    _toggleOverlay();
                  },
                )
            ),
          ),
      //   ],
      // ),
    );
  }

}