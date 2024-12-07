import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:qwara/pages/videoDetail/FullScreen.dart';
import 'package:qwara/getX/StoreController.dart';
import 'package:qwara/enum/Enum.dart';


class ControlMask extends StatefulWidget{
  const ControlMask({
    super.key,
    required this.controller,
    required this.fullScreen,
    this.width,
    this.height, this.switchClarity, required this.cClarity,
  });
  final VideoPlayerController controller;
  final List<Clarity> cClarity;
  //是否在全屏显示
  final bool fullScreen;
  final double? width;
  final double? height;
  final Function(Clarity clarity)? switchClarity;

  @override
  State<ControlMask> createState() => _ControlMaskState();
}

class _ControlMaskState extends State<ControlMask> with TickerProviderStateMixin{
  late VideoPlayerController _controller;
  late Clarity _clarity=storeController.clarityStorage ?? Clarity.low;
  var buffered;
  void _bufferedListener() {
    try{
      buffered = _controller.value.buffered[0].end;
    }catch(e){
      buffered=const Duration(seconds: 0);
    }
  }

  @override
  void initState() {
    super.initState();
    print("heightcm: ${widget.height}");
    print("widthcm: ${widget.width}");
    _controller = widget.controller;
    _controller.addListener(_bufferedListener);
  }
  void _rewind() {
    if(!_controller.value.isInitialized || _controller.value.position <= const Duration(seconds: 10)){
      return;
    }
    _controller.seekTo(_controller.value.position - const Duration(seconds: 10));
  }

  void _fastForward() {
    if(!_controller.value.isInitialized || _controller.value.position >= _controller.value.duration - const Duration(seconds: 10)){
      return;
    }
    _controller.seekTo(_controller.value.position + const Duration(seconds: 10));
  }
  void _seekVideo(Duration duration) {
    if(!_controller.value.isInitialized){
      return;
    }
    _controller.seekTo(duration);
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
    _controller.removeListener(_bufferedListener);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // print("widthcmisBuffering: ${_controller.value.isBuffering}");
    // final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    double iconSize = widget.fullScreen ? 50 : 30;
    return Stack(
      children: [
        Visibility(
          visible: _controller.value.isBuffering,
          child: Container(
            height:widget.height,
            color: Colors.black54,
            alignment: Alignment.center,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 4.0,
                  backgroundColor: Colors.blue,
                  // value: 0.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ],
            ),
          ),
        ),
        Container(
          height: widget.height,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Row(
            // mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.replay_10, color: Colors.white,size: iconSize,),
                onPressed: () {
                  _rewind();
                },
              ),
              IconButton(
                icon: Icon(
                  _controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white, size: iconSize
                ),
                onPressed: () {
                  videoControl();
                },
              ),
              IconButton(
                icon: Icon(Icons.forward_10, color: Colors.white,size: iconSize),
                onPressed: () {
                  _fastForward();
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 0, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const BackButtonIcon(),
                color: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              PopupMenuButton<Clarity>(
                offset: const Offset(0, 20),
                color: Colors.transparent,
                initialValue: _clarity,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                  child: Text(_clarity.value, style: const TextStyle(color: Colors.white)),
                ),
                onSelected: (clarity) {
                  widget.switchClarity?.call(clarity);
                  setState(() {
                    _clarity = clarity;
                  });

                },
                itemBuilder: (context) {
                  return widget.cClarity.map((clarity) {
                    return PopupMenuItem<Clarity>(
                      value: clarity,
                      child: Text(clarity.value, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList();
                },
              ),
            ],
          )
        ),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              children: [
                const SizedBox(width: 20),
                Expanded(child: ProgressBar(
                  // baseBarColor: Colors.purple[900],
                  timeLabelType: TimeLabelType.totalTime,
                  timeLabelTextStyle: const TextStyle(color: Colors.white),
                  buffered: buffered,
                  progress: Duration(seconds: _controller.value.position.inSeconds),
                  total: Duration(seconds: _controller.value.duration.inSeconds),
                  onSeek: (duration){
                    _seekVideo(duration);
                  },
                  onDragUpdate: (details){
                    // print(details);
                    _seekVideo(details.timeStamp);
                  },
                )),
                widget.fullScreen?Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: IconButton(
                      onPressed: (){
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.fullscreen_exit, color: Colors.white)
                  ),
                ):Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: IconButton(
                      onPressed: (){
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                              return FullScreen(
                                FpClarity: widget.cClarity,
                                  controller: _controller,
                                  switchClarity: widget.switchClarity
                              );
                        }));
                      },
                      icon: const Icon(Icons.fullscreen, color: Colors.white)
                  ),
                )
              ],
            )
        )
      ],
    );
  }
}