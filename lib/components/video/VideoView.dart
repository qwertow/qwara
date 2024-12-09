import 'package:sizer/sizer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qwara/EventBus/EventBus.dart';
import 'package:video_player/video_player.dart';
import 'package:qwara/getX/StoreController.dart';
import 'package:qwara/pages//videoDetail/ControlMask.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:lifecycle/lifecycle.dart';

import '../../enum/Enum.dart';

class VideoView extends StatefulWidget {
  const VideoView({super.key, required this.urlList, this.height, this.width, required this.pClarity});

  final List urlList;
  final double? height;
  final double? width;
  final List<Clarity> pClarity;

  @override
  State<VideoView> createState() => VideoViewState();
}

class VideoViewState extends State<VideoView>  with LifecycleAware, LifecycleMixin {
  List initUrlList = [];
  Clarity definition = storeController.clarityStorage ?? Clarity.low;
  double? videoWidth;
  double? videoHeight;
  //后续可能根据设置调整初始值
  bool iniPlay = storeController.settings.autoPlay;
  bool loopPlay = storeController.settings.loopPlay;
  late VideoPlayerController _controller;
  bool vcInit = false;
  bool isPlaying = false;
  bool showOverlay = false; // 控制遮罩层的显隐

  double proportion = 0;
  var buffered;
  late Duration dura;
  late Duration total;
  late Duration oldDura;
  late bool oldIsPlaying;

  int _dragProgress = 0; // 进度值
  int _totalTime = 0; // 总时间
  bool _dragPlaying = false;

  bool _showArrowLeft = false; // 是否显示左箭头
  bool _showArrowRight = false; // 是否显示右箭头
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

  bool wasLifePlaying=false; // 变量用于记录上一个播放状态
  @override
  void onLifecycleEvent(LifecycleEvent event) {
    print("onLifecycleEvent: $event");
    // final currentRouteName = ModalRoute.of(context)?.settings.name;
    if (event == LifecycleEvent.invisible) {
      wasLifePlaying = isPlaying;
      if(wasLifePlaying){
        _controller.pause();
      }
    }
    if (event == LifecycleEvent.active) {
      if(wasLifePlaying){
        _controller.play();
      }
    }

  }

  @override
  void initState() {
    super.initState();

    oldDura = const Duration(seconds: 0);
    // _updateUrl();
    _initController("https://000", initializePlay: iniPlay);
    WakelockPlus.toggle(enable: iniPlay);
  }

  @override
  void didUpdateWidget(covariant VideoView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listEquals(widget.urlList, initUrlList)) {
      // _updateUrl();
      if(!widget.pClarity.contains(definition)){
        definition=Clarity.low;
      }
      _loadVideo(initializePlay: iniPlay);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleOverlay() {
    setState(() {
      showOverlay = !showOverlay;
    });
  }

  void videoControl() {
    if(!_controller.value.isInitialized){
      return;
    }
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
  }
//初始化控制器
  void _initController(String link , {bool initializePlay = false}) {

    _controller = VideoPlayerController.networkUrl(Uri.parse(link))
      ..initialize().then((_) {
        if(initializePlay){
          _controller.play();
        }
        if(oldDura.inSeconds!=0){
          print("seekTo: $oldDura");
          _controller.seekTo(oldDura);
          if(oldIsPlaying){
            _controller.play();
          }
          eventBus.fire(ControllerReloadEvent(_controller));
        }
        setState(() {});
      })..setLooping(loopPlay)..addListener(() {
        bool wasPlaying = false; // 变量用于记录上一个播放状态
            setState(() {
              isPlaying = _controller.value.isPlaying;
              vcInit = _controller.value.isInitialized;
              if (isPlaying != wasPlaying) {
                WakelockPlus.toggle(enable: isPlaying);
                wasPlaying = isPlaying; // 更新上一个播放状态
              }

              try{
                buffered = _controller.value.buffered[0].end;
              }catch(e){
                buffered=const Duration(seconds: 0);
              }

              dura=_controller.value.position;
              total=_controller.value.duration;
              //进度条的播放进度，用当前播放时间除视频总长度得到
              proportion=total.inSeconds==0?0:dura.inSeconds/total.inSeconds;
              print("proportion: $proportion");
            });
            // print("resetTimer: ${_controller.value.isBuffering}",);
            //   _controller.value.isPlaying
          }
      );
    // print("initControllerOD: $oldDura");


  }

  //加载视频
  Future<VideoPlayerController> _loadVideo({bool initializePlay = false}) async {
    String url = "";
    if(initUrlList.isEmpty) {
      initUrlList.addAll(widget.urlList);
    }
    try{
      url="https://${widget.urlList.firstWhere((element)=>element["name"]==definition.value)["src"]["view"]}";
    }catch(e){

    }
    if (!_controller.value.isInitialized) {
      //没有视频在播放
      _initController(url, initializePlay: initializePlay);
    } else {
      // 如果有控制器，我们需要先处理旧的
      final VideoPlayerController oldController = _controller;
      oldDura = oldController.value.position;
      oldIsPlaying = oldController.value.isPlaying;
      // 为下一帧的结束注册回调
      // 处理一个旧控制器
      // (调用setState后不再使用)
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await oldController.dispose();
      });
      // 通过将其设置为null来确保没有使用该控制器
      setState(() {
        _controller.dispose();
        _initController(url, initializePlay: initializePlay);
      });

    }
    return _controller;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          // color: Colors.black,
          child:
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: widget.width ?? double.infinity,
              maxHeight:(_controller.value.isPlaying ? null : widget.height) ?? MediaQuery.of(context).size.height * 0.5,
            ),
            child: _controller.value.isInitialized ? _buildVideoPlayer() : _buildLoadingIndicator(),
          ),
        ),
        LinearProgressIndicator(
          backgroundColor: Colors.black,
          value: proportion,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    return Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // final aspectRatio = _controller.value.aspectRatio;
                final mwidth = constraints.maxWidth;
                final mheight = constraints.maxHeight;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (videoWidth != mwidth) {
                    setState(() {
                      videoWidth = mwidth; // 更新宽度
                      print("videoWidth: $videoWidth");
                      // print("videoWidth111: ${(videoWidth ?? 0) /aspectRatio}");
                    });
                  }
                  if (videoHeight!= mheight) {
                    setState(() {
                      videoHeight = mheight; // 更新高度

                    });
                  }
                  print("videoHeight: $videoHeight");
                  // print("videoWidth222: ${(videoWidth ?? 0) / aspectRatio}");
                });
                return  VideoPlayer(_controller);
              },
            ),
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
              child:showOverlay? ControlMask(
                controller: _controller,
                fullScreen: false,
                width: videoWidth,
                height: videoHeight,
                switchClarity: (clarity) {
                  setState(() {
                    definition=clarity;
                  });
                  storeController.setClarity(clarity);
                  _loadVideo();
                }, cClarity: widget.pClarity,
              ):Container(
                height: videoHeight ?? 0,
                width: 100.w,
                color: Colors.transparent,
              ),
          ),
          if(_showArrowLeft || _showArrowRight)
            Positioned(
              top: 50,
              child: Container(
                width: 300,
                height: 100,
                color: Colors.black54,
                child: Column(
                  children: [
                    if(_showArrowLeft)
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_left, size: 60, color: Colors.white),
                          Icon(Icons.arrow_left, size: 60, color: Colors.white)
                        ],
                      ),
                    if(_showArrowRight)
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_right, size: 60, color: Colors.white),
                          Icon(Icons.arrow_right, size: 60, color: Colors.white)
                        ],
                      ),
                    Text(
                      "${formatDuration(_dragProgress)}/${formatDuration(_totalTime)}",
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    )
                  ],
                ),
              ),
            )
        ],
      );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: widget.height ?? 200,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 4.0,
          backgroundColor: Colors.blue,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
        ),
      ),
    );
  }

}
