import 'package:flutter/material.dart';

import '../utils/HeightMeasureWidget.dart';

class AutoHeightPageView extends StatefulWidget {
  final List<Widget> children;
  final PageController pageController;

  const AutoHeightPageView({
    super.key,
    required this.children,
    required this.pageController,
  });

  @override
  AutoHeightPageViewState createState() => AutoHeightPageViewState();
}

class AutoHeightPageViewState extends State<AutoHeightPageView> {
  final List<double> _heights = [];
  double _currentHeight = 0;

  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(_updateHeight);
  }

  void _updateHeight() {
    if (widget.pageController.position.haveDimensions && _heights.isNotEmpty) {
      // print("AutoHeightPageView updateHeight ${_heights.length == widget.children.length} ${widget.pageController.position.haveDimensions}");

      double page = widget.pageController.page ?? 0.0;
      int index = page.floor();
      int nextIndex = (index + 1) < _heights.length ? index + 1 : index;
      double percent = page - index;
      double height =
          _heights[index] + (_heights[nextIndex] - _heights[index]) * percent;
      setState(() {
        _currentHeight = height;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("AutoHeightPageView build ${_heights.length == widget.children.length} $_currentHeight");
    var isMeasureHeight = !(_heights.length == widget.children.length) ;
    return Column(
      children: [
        Stack(
          children: [
            Visibility(
              visible: isMeasureHeight,
              child: Stack(
                children: widget.children.map((e) => HeightMeasureWidget(
                  child: e,
                  onHeightChanged: (height) {
                    _heights.add(height);
                    if (_heights.length == widget.children.length) {
                      if(_heights[0]==0){
                        _heights.clear();
                      }
                      setState(() {
                        if(_heights.isNotEmpty){
                          _currentHeight = _heights[0];
                        }
                      });
                    }
                  },
                )).toList(),
              ),
            ),
            if (!isMeasureHeight)
              // ConstrainedBox(constraints: const BoxConstraints(
              //   minHeight: 200
              // ),child:
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _currentHeight,
                curve: Curves.easeOut,
                child: PageView(
                  controller: widget.pageController,
                  children: widget.children,
                ),
              )
              // )
          ],
        )
      ],
    );
  }

  @override
  void dispose() {
    widget.pageController.dispose();
    super.dispose();
  }
}