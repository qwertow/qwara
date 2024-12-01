import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:get/get.dart' hide Response;

class UserList extends StatelessWidget {
  const UserList({
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
                Get.toNamed('/userProfile', arguments: _Info['user']);
              },
              child: Card(
                  child: ListTile(
                    leading:  CircleAvatar(
                      radius: 20,
                      child: ClipOval(
                        child: Skeleton.replace(child: Image.network(
                          'https://i.iwara.tv/image/avatar/${_Info['user']?['avatar']?['id'] }/${_Info['user']?['avatar']?['name']}',
                          headers: const {
                            'Referer': "https://www.iwara.tv/",
                          },
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            // 显示默认图片，并确保是圆形
                            return Image.asset(
                              'assets/images/default-avatar.jpg',
                              fit: BoxFit.cover,
                            );
                          },
                        )),
                      ),
                    ),
                    title: Text(_Info['user']?['name'] ?? '作者名称',maxLines:1),
                    subtitle: Text("@${_Info['user']?['username'] ?? '作者用户名'}",maxLines:1),
                  )
              ),
            );
          },
        ));
  }
}