import 'package:flutter/material.dart';
import 'package:qwara/EventBus/EventBus.dart';
import 'package:qwara/pages/videoDetail/ControlMask.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:qwara/enum/Enum.dart';


class FullScreen extends StatefulWidget {
  const FullScreen({
    super.key,
    required this.controller,
    this.switchClarity, this.onBack, required this.FpClarity,
  });
  final VideoPlayerController controller;
  final Function(Clarity clarity)? switchClarity;
  final Function? onBack;
  final List<Clarity> FpClarity;
  @override
  State<FullScreen> createState() => _FullScreenState();
}
class _FullScreenState extends State<FullScreen> {
  late VideoPlayerController _controller;
  int _dragProgress = 0; // 进度值
  int _totalTime = 0; // 总时间
  bool _dragPlaying = false;

  bool _showArrowLeft = false; // 是否显示左箭头
  bool _showArrowRight = false; // 是否显示右箭头

  void listener() {
      setState(() {});
  }
  void _seekVideo(Duration duration) {
    if(!_controller.value.isInitialized){
      return;
    }
    _controller.seekTo(duration);
  }
  String formatDuration(int milliseconds) {
    // 将毫秒转换为秒
    double totalSeconds = milliseconds / 1000;

    // 计算分钟和秒
    int minutes = (totalSeconds ~/ 60);
    int seconds = (totalSeconds % 60).round();

    // 使用 sprintf 或其他格式化方法确保输出格式为分钟:秒，且秒数始终是两位数
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  @override
  void initState() {
    print("FullScreen initState");
    super.initState();
    _controller = widget.controller;
    _controller.play();
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
    });
  }
  bool showOverlay = false; // 控制遮罩层的显隐

  void _toggleOverlay() {
    setState(() {
      showOverlay = !showOverlay;
    });
  }

  void videoControl() {
    if(!_controller.value.isInitialized){
      return;
    }
      _controller.value.isPlaying
          ? _controller.pause()
          : _controller.play();
  }
  @override
  void dispose() {
    super.dispose();
    widget.onBack?.call();
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
              onHorizontalDragStart: (details){
                if(!_controller.value.isInitialized){
                  return;
                }
                _dragProgress = _controller.value.position.inMilliseconds;
                _totalTime = _controller.value.duration.inMilliseconds;
                _dragPlaying = _controller.value.isPlaying;
                _controller.pause();
              },
              onHorizontalDragUpdate: (details){
                setState(() {
                  // 计算滑动的距离
                  double delta = details.delta.dx;

                  // 根据滑动方向更新箭头和进度
                  if (delta > 0) {
                    _showArrowRight = true;
                    _showArrowLeft = false;
                  } else {
                    _showArrowLeft = true;
                    _showArrowRight = false;
                  }
                  print("delta:${delta}");
                  delta*=500;
                  if(delta.round().abs()==0){
                    print("delta.round().abs()==0");
                    delta /= delta.abs();
                  }
                  _dragProgress += delta.round();
                  // 限制进度值的范围
                  _dragProgress = _dragProgress.clamp(0, _totalTime);
                });
              },
              onHorizontalDragEnd: (details){
                _showArrowLeft = false;
                _showArrowRight = false;
                if(!_controller.value.isInitialized){
                  return;
                }
                _seekVideo(Duration(milliseconds: _dragProgress));
                if(_dragPlaying){
                  _controller.play();
                }
              },
              onHorizontalDragCancel: (){},
              onDoubleTap: videoControl,
              onTap: _toggleOverlay,
              child: showOverlay? ControlMask(
                switchClarity: widget.switchClarity,
                controller: _controller,
                fullScreen: true, cClarity: widget.FpClarity,
                // width: MediaQuery.of(context).size.width ,
                // height: MediaQuery.of(context).size.height,
              ): Container(
                color: Colors.transparent,
              ),// 不显示遮罩层时返回空容器,
            ),
            if(_showArrowLeft || _showArrowRight)
            Positioned(
              top: 100,
              child: Container(
                width: 500,
                height: 200,
                color: Colors.black54,
                child: Column(
                  children: [
                    if(_showArrowLeft)
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_left, size: 100, color: Colors.white),
                        Icon(Icons.arrow_left, size: 100, color: Colors.white)
                      ],
                    ),
                    if(_showArrowRight)
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_right, size: 100, color: Colors.white),
                        Icon(Icons.arrow_right, size: 100, color: Colors.white)
                      ],
                    ),
                    Text(
                      "${formatDuration(_dragProgress)}/${formatDuration(_totalTime)}",
                      style: TextStyle(color: Colors.white, fontSize: 20.sp),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}