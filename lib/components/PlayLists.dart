import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:get/get.dart' hide Response;

class PlayLists extends StatelessWidget {
  const PlayLists({
    super.key,
    required this.items,
    required this.loading,
    this.crossAxisCountMobile=2, this.crossAxisCountTablet=3,

  });
  final List items;
  final bool loading;
  final int crossAxisCountMobile;
  final int crossAxisCountTablet;

  @override
  Widget build(BuildContext context) {
    final List _items = loading ? List.generate(10, (index) => {
      "title": "Loading...","user": {"name": "Loading..."},
      "numLikes": 0, "file": {"id": "123"}}) : items;
    // print("uerList build $_items");
    return Skeletonizer(
        enabled: loading,
        child: MasonryGridView.count(
          itemCount: _items.length,
          crossAxisCount: getValueForScreenType<int>(
            context: context,
            mobile: crossAxisCountMobile,
            tablet: crossAxisCountTablet,
          ),
          mainAxisSpacing: 4,
          // crossAxisSpacing: 4,
          itemBuilder: (context, index) {
            // print("uerList itemBuilder $index");
            var _Info = _items[index];
            return InkWell(
              onTap: () {
                Get.toNamed('/playListDetail', arguments: _Info);
              },
              child: Card(
                  child: ListTile(
                    title: Text(_Info['title'] ?? '标题',maxLines:1),
                    subtitle: Text("${_Info['numVideos'] ?? '0'}",maxLines:1),
                  )
              ),
            );
          },
        ));
  }
}