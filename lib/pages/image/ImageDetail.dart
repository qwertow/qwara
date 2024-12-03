
import 'package:flutter/services.dart';
import 'package:qwara/api/comment/comment.dart';
import 'package:qwara/api/img/img.dart';
import 'package:qwara/api/subscribe/follow.dart';
import 'package:qwara/api/subscribe/like.dart';
import 'package:qwara/components/image/ImageView.dart';
import 'package:qwara/getX/StoreController.dart';
import 'package:flutter/material.dart';
import 'package:floating_tabbar/lib.dart';
import 'package:qwara/components/profile.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:get/get.dart';

import '../generalPage/CommentPage.dart';

final storeController = Get.find<StoreController>();

class ImageDetail extends StatefulWidget {
  const ImageDetail({
    super.key,
    required this.imageInfo,
  });

  final Map<String, dynamic> imageInfo; // 视频信息

  @override
  State<ImageDetail> createState() => _ImageDetail();
}

class _ImageDetail extends State<ImageDetail> {

  final ScrollController _profileScrollController = ScrollController();
  final ScrollController _commentScrollController = ScrollController();
  late ScrollPhysics? _scrollPhysics = null;
  bool pLisTouched = false;
  bool cLisTouched = false;
  bool isHorizontalSlide = false;

  void _toucheStatus(String type) {
    print("touchStatus: $type");
    switch (type) {
      case "comment":
        cLisTouched = true;
        pLisTouched = false;
        break;
      case "profile":
        pLisTouched = true;
        cLisTouched = false;
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _getFiles();
    _commentScrollController.addListener(() {
      _toucheStatus("comment");
    });
    _profileScrollController.addListener(() {
      _toucheStatus("profile");
    });
  }

  // SliverPanel3Controller slidingPanel3Controller = SliverPanel3Controller();

  late Map<String, dynamic> imgDetail={};
  Future<void> _getImageDetail(String id) async {
    final res = await getImgDetail(id);
    try {
      setState(() {
        imgDetail=res;
      });
    }catch (e) {
      print(e);
    }

    // return res;
  }
  late List<Map<String, dynamic>> files=[];
  Future<void> _getFiles()  async {
    // try {
    await _getImageDetail(widget.imageInfo['id']);
    setState(() {
      files.clear();
      files.addAll(imgDetail['files'].cast<Map<String, dynamic>>());
      print("files0: $files");
    });

  }

  @override
  void dispose() {
    super.dispose();
    _commentScrollController.dispose();
    _profileScrollController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // print("ImageDetail build");
    final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      // backgroundColor: Colors.black,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
          toolbarHeight: 0,
          // systemOverlayStyle: SystemUiOverlayStyle.light,
          systemOverlayStyle: const SystemUiOverlayStyle(
            //设置状态栏的背景颜色
            statusBarColor: Colors.black,
            //状态栏的文字的颜色
            statusBarIconBrightness: Brightness.light,
          )

      ),
      body:
      // Stack(
      //   children: [
          Flex(
            direction: getValueForScreenType(
              context: context,
              mobile: isPortrait ? Axis.vertical : Axis.horizontal,
              tablet: Axis.horizontal,
            ),
            children: [
              _buildImgSection(isPortrait),
              _buildCommentSection(isPortrait),
            ],
          ),
          // _buildSliverPanel(),
      //   ],
      // ),
    );
  }

  Widget _buildImgProfile() {
    return Profile(
      type: ProfileType.image,
      scrollPhysics: _scrollPhysics,
      // onDownload: _downloadVideo,
      scrollController: _profileScrollController,
      handleFollow: (isFollowed) async {
        if (isFollowed) {
          await unfollowUser(widget.imageInfo['user']["id"]);
        }else {
          await followUser(imgDetail['user']["id"]);
        }
        await _getImageDetail(widget.imageInfo['id']);
      },
      handleLIke: (isLiked) async {
        if (isLiked) {
          await unlikeImage(imgDetail['id']);
        }else {
          await likeImage(imgDetail['id'], storeController.userInfo?['user'] ?? {});
        }
        await _getImageDetail(widget.imageInfo['id']);
      },
      // onSetPlaylist: () {
      //   slidingPanel3Controller.setPanel3State(Panel3State.CENTER);
      // },
      info: imgDetail,
      files: files,
    );
  }

  Widget _buildImgSection(bool isPortrait) {
    return Expanded(
      flex: 3,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            color: Colors.black,
            child: ImageView(fileList: files),
          )
          ,
          Flexible(
            child: ScreenTypeLayout.builder(
              mobile: (context) => OrientationLayoutBuilder(
                portrait: (context) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildTabBarView(),
                ),
                landscape: (context) => _buildImgProfile(),
              ),
              tablet: (context) => _buildImgProfile(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TopTabBar(
      onTap: (p0) {},
      isScrollable: false,
      children: [
        TabItem(
          title: const Text("简介"),
          onTap: () {},
          tab: _buildImgProfile(),
        ),
        TabItem(
          title: const Text("评论"),
          onTap: () {},
          tab: CommentPage(
            scrollPhysics: _scrollPhysics, scrollController: _commentScrollController,
            getComments: (int page ) async {
              return getImgComments(widget.imageInfo['id'], page: page);
            }, addComment: (String comment, {String? rpId}) async {
              return createCommentImage(widget.imageInfo['id'], comment,rpUid: rpId);
          },),
        ),
      ],
    );
  }

  Widget _buildCommentSection(bool isPortrait) {
    return Expanded(
      flex: getValueForScreenType(context: context, mobile: (isPortrait ? 0 : 2), tablet: 2),
      child: ScreenTypeLayout.builder(
        mobile: (context) => OrientationLayoutBuilder(
          portrait: (context) => const SizedBox.shrink(),
          landscape: (context) => CommentPage(
            getComments: (int page ) async {
              return getImgComments(widget.imageInfo['id'], page: page);
            },addComment: (String comment, {String? rpId}) async {
            return createCommentImage(widget.imageInfo['id'], comment,rpUid: rpId);
          }),
        ),
        tablet: (context) => CommentPage(
          getComments: (int page ) async {
            return getImgComments(widget.imageInfo['id'], page: page);
          },addComment: (String comment, {String? rpId}) async {
          return createCommentImage(widget.imageInfo['id'], comment,rpUid: rpId);
        }),
      ),
    );
  }


  // Widget _buildSliverPanel() {
  //   return Align(
  //     alignment: AlignmentDirectional.bottomCenter,
  //     child: SliverPanel3View(
  //       heightClose: 0,
  //       heightCenter: 330,
  //       heightOpen: 680,
  //       headWidget: headView(),
  //       bodyWidget: (ScrollController sc, ScrollPhysics? physics) {
  //         return BodyView(sc, physics);
  //       },
  //       sliverPanel3Controller: slidingPanel3Controller,
  //       initPanel3state: Panel3State.CLOSE,
  //     ),
  //   );
  // }
  // Widget headView() {
  //   return Container(
  //     height: 108,
  //     decoration: const BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.only(
  //           topLeft: Radius.circular(8),
  //           topRight: Radius.circular(8),
  //         )),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         const SizedBox(
  //           height: 12,
  //         ),
  //         InkWell(
  //           onTap: (){
  //             slidingPanel3Controller.setPanel3State(Panel3State.EXIT);
  //             // LocationPluginUtils.get().then((value) {
  //             //   SGMLogger.info(value);
  //             // });
  //           },
  //           child: Container(
  //             width: double.infinity,
  //             height: 40,
  //             alignment: AlignmentDirectional.center,
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(20),
  //             ),
  //             child: Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Icon(Icons.search , color: Colors.grey.withAlpha(80),size: 20,),
  //                 const SizedBox(
  //                   width: 5,
  //                 ),
  //                 Text(
  //                   'Search',
  //                   style: TextStyle(
  //                       color: Colors.grey.withAlpha(80),
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.w400),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         const SizedBox(
  //           height: 40,
  //           child: Row(
  //             children: [
  //               Icon(Icons.ac_unit , color: Colors.redAccent ,size: 20,),
  //               SizedBox(
  //                 width: 8,
  //               ),
  //               Expanded(
  //                 child: Text(
  //                   '惊喜来袭！！！ 森林公园免门票 快冲...',
  //                   maxLines: 1,
  //                   overflow: TextOverflow.ellipsis,
  //                   style: TextStyle(
  //                       color: Colors.redAccent,
  //                       height: 1.2,
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.w400),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  // Widget BodyView(ScrollController sc ,  ScrollPhysics? physics) {
  //
  //   // return Container(height: 999,width: 380, color: Colors.yellowAccent,);
  //
  //   Widget _itemView(int i) {
  //     return Container(
  //       color: Colors.white,
  //       height: 94,
  //       child: Row(
  //         children: [
  //           const Icon(Icons.add_a_photo_rounded , color: Colors.orange, size: 66,),
  //           const SizedBox(
  //             width: 18,
  //           ),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const Text(
  //                   '森林公园游乐场',
  //                   maxLines: 1,
  //                   overflow: TextOverflow.ellipsis,
  //                   style: TextStyle(
  //                       color: Colors.black,
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w500),
  //                 ),
  //                 const SizedBox(
  //                   height: 8,
  //                 ),
  //                 Text(
  //                   '景点热度🔥 610$i',
  //                   style: TextStyle(
  //                       color: Colors.grey.withAlpha(80),
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.w400),
  //                 ),
  //                 Spacer(),
  //                 // LineCuttingHorizontal(colorLine: color_ededed),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  //
  //   return ListView.builder(
  //     controller: sc,
  //     physics: physics,
  //     padding: EdgeInsets.zero,
  //     itemCount: 19,
  //     itemBuilder: (BuildContext context, int i) {
  //       return _itemView(i);
  //     },
  //   );
  // }
}
