
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qwara/EventBus/EventBus.dart';
import 'package:video_player/video_player.dart';
import 'package:qwara/getX/StoreController.dart';
import 'package:get/get.dart';
import '../videoDetail/ControlMask.dart';


final storeController = Get.find<StoreController>();

class VideoView extends StatefulWidget {
  const VideoView({super.key, required this.urlList, this.height, this.width});

  final List urlList;
  final double? height;
  final double? width;

  @override
  State<VideoView> createState() => _VideoView();
}

class _VideoView extends State<VideoView> {
  List initUrlList = [];
  String definition = storeController.clarityStorage.value;
  String? url;
  double? videoWidth;
  double? videoHeight;
  late VideoPlayerController _controller;
  bool showOverlay = false; // 控制遮罩层的显隐

  double proportion = 0;
  var buffered;
  late Duration dura;
  late Duration total;
  late Duration oldDura;
  late bool oldIsPlaying;
  // var oldProportion;

  @override
  void initState() {
    super.initState();
    oldDura = const Duration(seconds: 0);
    // _updateUrl();
    _initController("https://000");
  }

  @override
  void didUpdateWidget(covariant VideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.urlList, initUrlList)) {
      // _updateUrl();
      _loadVideo();
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
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }
//初始化控制器
  void _initController(String link) {

    _controller = VideoPlayerController.networkUrl(Uri.parse(link))
      ..initialize().then((_) {
        if(oldDura.inSeconds!=0){
          print("seekTo: $oldDura");
          _controller.seekTo(oldDura);
          if(oldIsPlaying){
            _controller.play();
          }
          eventBus.fire(ControllerReloadEvent(_controller));
        }
        setState(() {});
      })..addListener(() {
            setState(() {
              //进度条的播放进度，用当前播放时间除视频总长度得到
              try{
                buffered = _controller.value.buffered[0].end;
              }catch(e){
                buffered=const Duration(seconds: 0);
              }

              dura=_controller.value.position;
              total=_controller.value.duration;
              proportion=total.inSeconds==0?0:dura.inSeconds/total.inSeconds;
              print("proportion: $proportion");
            });
            // print("resetTimer: ${_controller.value.isBuffering}",);
          }
      );
    // print("initControllerOD: $oldDura");


  }

  //加载视频
  Future<VideoPlayerController> _loadVideo() async {
    String url = "";
    if(initUrlList.isEmpty) {
      initUrlList.addAll(widget.urlList);
    }
    try{
      url="https://${widget.urlList.firstWhere((element)=>element["name"]==definition)["src"]["view"]}";
    }catch(e){

    }
    if (!_controller.value.isInitialized) {
      //没有视频在播放
      _initController(url);
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
        _initController(url);
      });

    }
    return _controller;
  }
  void _updateUrl(){
    if(initUrlList.isEmpty){
      initUrlList.addAll(widget.urlList);
    }
    try{
      if(widget.urlList.isEmpty){
        throw Exception("urlList is empty");
      }

      url="https://${widget.urlList.firstWhere((element)=>element["name"]==definition)["src"]["view"]}";
    }catch(e){
      url='';
    }

    _controller = VideoPlayerController.networkUrl(Uri.parse(url!))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      })..addListener(() {
        setState(() {
          //进度条的播放进度，用当前播放时间除视频总长度得到
          try{
            buffered = _controller.value.buffered[0].end;
          }catch(e){
            buffered=const Duration(seconds: 0);
          }

          dura=_controller.value.position;
          total=_controller.value.duration;
          proportion=total.inSeconds==0?0:dura.inSeconds/total.inSeconds;
          print("proportion: $proportion");
        });
        // print("resetTimer: ${_controller.value.isBuffering}",);
      });
  }


  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Container(
          color: Colors.black,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: widget.height ?? MediaQuery.of(context).size.height,
            ),
            child: _controller.value.isInitialized ? _buildVideoPlayer() : _buildLoadingIndicator(),
          ),
        ),
        LinearProgressIndicator(
          backgroundColor: Colors.greenAccent,
          value: proportion,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    // return SizedBox(
    //   height: widget.height ?? 200,
    //   child: Chewie(
    //     controller: _chewieController,
    //   ),
    // );
    return GestureDetector(
      onDoubleTap: videoControl,
      onTap: _toggleOverlay,
      child: Stack(
        alignment: Alignment.center,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final aspectRatio = _controller.value.aspectRatio;
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (videoWidth != width) {
                  setState(() {
                    videoWidth = width; // 更新宽度
                  });
                }
                if (videoHeight!= height) {
                  setState(() {
                    videoHeight = height; // 更新高度
                  });
                }
              });
              return AspectRatio(
                aspectRatio: aspectRatio,
                child: VideoPlayer(_controller),
              );
            },
          ),
          if (showOverlay) ControlMask(
              controller: _controller,
              fullScreen: false,
              width: videoWidth,
              height: videoHeight,
              switchClarity: (clarity) {
                setState(() {
                  definition=clarity.value;
                });
                storeController.setClarity(clarity);
                _loadVideo();

              },
          ),
        ],
      ),
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
