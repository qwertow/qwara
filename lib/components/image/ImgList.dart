import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:qwara/constant.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
class ImgList extends StatelessWidget {
  const ImgList({
    super.key,
    required this.items,
    required this.loading,
    this.scrollPhysics,
    this.shrink=false, this.crossAxisCountMobile=2, this.crossAxisCountTablet=4,

  });
  final List items;
  final bool loading;
  final ScrollPhysics? scrollPhysics;
  final bool shrink;
  final int crossAxisCountMobile;
  final int crossAxisCountTablet;
  String getThumbnailUrl(int index) {

    var customThumbnail;
    var id ;
    var name;
    String thumbnailUrl = "";

    try{
      if(items.isEmpty){
        thumbnailUrl = "https://123";
      }
      customThumbnail = items[index]["thumbnail"];
      id = customThumbnail["id"] ;
      name =  customThumbnail["name"];
      thumbnailUrl = "https://i.iwara.tv/image/thumbnail/$id/$name";
    }catch(e){
      print(e);
    }
    return thumbnailUrl;
  }

  @override
  Widget build(BuildContext context) {
    final List _items = loading ? List<Map<String, dynamic>>.generate(10, (index) => {
      "thumbnail": {"id": "123","name": "Loading..."},
      "title": "Loading...","user": {"name": "Loading..."},
      "numLikes": 0, "file": {"id": "123"}}) : items;
    // print("imglist build $loading");
    const cardCircular=12.0;
    return Skeletonizer(
        enabled: loading,
        child: MasonryGridView.count(
          shrinkWrap: shrink,
          physics: scrollPhysics,
          itemCount: _items.length,
          crossAxisCount: getValueForScreenType<int>(
            context: context,
            mobile: crossAxisCountMobile,
            tablet: crossAxisCountTablet,
          ),
          mainAxisSpacing: 4,
          // crossAxisSpacing: 4,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                print("Recommend Item $index clicked");
                Navigator.pushNamed(context, "/imageDetail",
                    arguments: _items[index]);
              },
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.all(5.0),
                child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800] // 夜间模式颜色
                          : Colors.grey[200], // 日间模式颜色
                      borderRadius: BorderRadius.circular(cardCircular),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(cardCircular), // 左上角圆角
                                topRight: Radius.circular(cardCircular), // 右上角圆角
                              ),
                              child: ConstrainedBox(constraints: const BoxConstraints(
                                  minHeight: 100,
                                ),child:Skeleton.replace(
                                    child: CachedNetworkImage(
                                      httpHeaders: IMG_HEADERS,
                                      imageUrl: getThumbnailUrl(index),
                                      fit: BoxFit.fitWidth, // 使宽度填满，并保持高度按比例缩放
                                      progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                        child: CircularProgressIndicator(
                                          value: downloadProgress.progress,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => const Icon(Icons.error,color: Colors.red,size: 50,),
                                    ),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(5,5,5,0),
                              child: Text(
                                _items[index] ['title']!,
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(5, 0, 5, 3),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 使子元素之间的空间均分
                                children: [
                                  Flexible(
                                    child: Text("${_items[index]['user']['name']}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.favorite_outline,size: 14,),
                                      Text("${_items[index]['numLikes']}"),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),

                        Row(
                          children: [
                            const Icon(Icons.image,size: 14,color: Colors.white,),
                            Text("${_items[index]['numImages']}",style: const TextStyle(
                              color: Colors.white,
                            ),),
                          ],
                        )

                      ],
                    )
                ),
              ),
            );
          },
        ));
  }
}