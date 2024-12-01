import 'package:flutter/material.dart';


class SliverPanel3Controller {
  _SliverPanel3ViewState? onState;

  _addState(_SliverPanel3ViewState? onState){
    this.onState = onState;
  }

  void setPanel3State(Panel3State state){
    onState?.setPanel3state(state);
  }

  Panel3State getPanel3State(){
    return onState?._panel3state.value ?? Panel3State.CENTER;
  }

}

enum Panel3State { OPEN, CENTER, CLOSE, EXIT }

class SliverPanel3View extends StatefulWidget {
  final double heightOpen; //展开高度
  final double heightCenter; //中间高度
  final double heightClose; //闭合高度
  final Widget headWidget; //标题布局
  final Widget Function(ScrollController sc , ScrollPhysics? physics)? bodyWidget; //内容布局
  final Panel3State initPanel3state; //初始状态
  final Color backColor; //背景色
  final SliverPanel3Controller? sliverPanel3Controller; //控制器

  const SliverPanel3View(
      {super.key,
        this.heightOpen = 600,
        this.heightCenter = 360,
        this.heightClose = 100,
        required this.headWidget,
        required this.bodyWidget,
        this.sliverPanel3Controller,
        this.initPanel3state = Panel3State.CENTER,
        this.backColor = Colors.transparent});

  @override
  State<SliverPanel3View> createState() => _SliverPanel3ViewState();
}


class _SliverPanel3ViewState extends State<SliverPanel3View> with AutomaticKeepAliveClientMixin {
  double heightClose = 100;
  double heightCenter = 360;
  double heightOpen = 600;
  final ValueNotifier<Panel3State> _panel3state = ValueNotifier(Panel3State.CENTER);
  SliverPanel3Controller? sliverPanel3Controller;
  ScrollController _sc = ScrollController();
  ScrollPhysics? _physics;

  @override
  void initState() {
    super.initState();
    heightClose = widget.heightClose;
    heightCenter = widget.heightCenter;
    heightOpen = widget.heightOpen;
    _panel3state.value = widget.initPanel3state;
    sliverPanel3Controller = widget.sliverPanel3Controller;
    sliverPanel3Controller?._addState(this);

  }

  void setPanel3state(Panel3State s){
    _panel3state.value = s;
  }

  double panelHeight() {

    if(_panel3state.value == Panel3State.OPEN){
      _physics = const AlwaysScrollableScrollPhysics();
    }else{
      _physics = const NeverScrollableScrollPhysics();
    }

    if (_panel3state.value == Panel3State.OPEN) {
      return heightOpen;
    } else if (_panel3state.value == Panel3State.CENTER) {
      return heightCenter;
    } else if (_panel3state.value == Panel3State.CLOSE) {
      return heightClose;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _panel3state,
      builder: (context, state, child) {
        return AnimatedContainer(
          color: widget.backColor,
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          height: panelHeight(),
          child: Column(
            children: [HeadView(),  Expanded(child: BodyView())],
          ),
        );
      },
    );
  }

  double pointerMove = 0;
  bool isCan = true;
  double scOffset = 0;

  Widget HeadView() {
    return Listener(
      onPointerDown: (e) {
        pointerMove = e.position.dy;
        isCan = true;
      },
      onPointerMove: (e) {
        if (e.position.dy - pointerMove > 36 && isCan) {
          // print("手指下滑触发 -- ");
          isCan = false;
          if (_panel3state.value == Panel3State.OPEN) {
            _panel3state.value = Panel3State.CENTER;
          } else if (_panel3state.value == Panel3State.CENTER) {
            _panel3state.value = Panel3State.CLOSE;
          }
        } else if (e.position.dy - pointerMove < -36 && isCan) {
          // print("手指上滑触发 -- ");
          isCan = false;
          if (_panel3state.value == Panel3State.CLOSE) {
            _panel3state.value = Panel3State.CENTER;
          } else if (_panel3state.value == Panel3State.CENTER) {
            _panel3state.value = Panel3State.OPEN;
          }
        }
      },
      onPointerUp: (e) {
        isCan = true;
      },
      child: widget.headWidget,
    );
  }


  Widget BodyView() {
    return Listener(
      onPointerDown: (e) {
        pointerMove = e.position.dy;
        isCan = true;
      },
      onPointerMove: (e) {
        scOffset = _sc.hasClients ? _sc.offset : 0; //滑动控制器是否绑定

        if (e.position.dy - pointerMove > 36 && isCan) {
          // print("手指下滑触发 -- ");
          isCan = false;
          if (_panel3state.value == Panel3State.OPEN && scOffset <= 0) {
            _panel3state.value = Panel3State.CENTER;
          } else if (_panel3state.value == Panel3State.CENTER) {
            _panel3state.value = Panel3State.CLOSE;
          }
        } else if (e.position.dy - pointerMove < -36 && isCan) {
          // print("手指上滑触发 -- ");
          isCan = false;
          if (_panel3state.value == Panel3State.CLOSE) {
            _panel3state.value = Panel3State.CENTER;
          } else if (_panel3state.value == Panel3State.CENTER) {
            _panel3state.value = Panel3State.OPEN;
          }
        }
      },
      onPointerUp: (e) {
        isCan = true;
      },
      child: Container(child: widget.bodyWidget!(_sc , _physics),),
    );
  }

  @override
  bool get wantKeepAlive => true;
}