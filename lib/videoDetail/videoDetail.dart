import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:qwara/utils/request.dart';
import 'package:flutter/material.dart';
import 'package:qwara/api/video/video.dart';
import 'package:qwara/components/VideoView.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:crypto/crypto.dart';
import 'package:qwara/constant.dart';
import 'package:marquee/marquee.dart';
import 'package:qwara/videoDetail/comment.dart';
import 'package:qwara/videoDetail/profile.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:qwara/components/SlidingPanel3Controller.dart';


class VideoDetail extends StatefulWidget {
  const VideoDetail({
    super.key,
    required this.videoInfo,
  });

  final Map<String, dynamic> videoInfo; // 视频信息

  @override
  State<VideoDetail> createState() => _VideoDetail();
}

class _VideoDetail extends State<VideoDetail> {

  SliverPanel3Controller slidingPanel3Controller = SliverPanel3Controller();

  late Map<String, dynamic> videoDetail={};
  final List videoUrls=[];
  _getVideoDetail(String id) async {
    final res = await getVideoDetail(id);
    return res;
  }

  _getVideoUrls()  async {
    videoDetail=await _getVideoDetail(widget.videoInfo['id']);
    String fileUrl = videoDetail['fileUrl'];
    print("fileUrl: $fileUrl");
    Uri uri = Uri.parse(fileUrl);

    // 获取 expires 参数的值
    String? expiresValue = uri.queryParameters['expires'];
    // print( "expiresValue:${videoDetail["file"]["id"]}" );
    // print("expires: $expiresValue");
    // print("${videoDetail["file"]["id"]}_${expiresValue}_$xVersion");
    var value = sha1.convert(utf8.encode("${videoDetail["file"]["id"]}_${expiresValue}_$xVersion"));
    options.headers['X-Version']=value.toString();

    // print("version: ${value.toString()}");
    final res = await getVideoUrls(fileUrl);

    setState(() {
      videoUrls.clear();
      videoUrls.addAll(res);
    });

    print(res);
    return res;
  }

  @override
  void initState() {

    super.initState();
    _getVideoUrls();
  }
  @override
  Widget build(BuildContext context) {
    final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
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
      body: Stack(
        children: [
          Flex(
            direction: getValueForScreenType(
              context: context,
              mobile: isPortrait ? Axis.vertical : Axis.horizontal,
              tablet: Axis.horizontal,
            ),
            children: [
              _buildVideoSection(isPortrait),
              _buildCommentSection(isPortrait),
            ],
          ),
          _buildSliverPanel(),
        ],
      ),
    );
  }

  Widget _buildVideoProfile() {
    return Profile(
      onAddPlaylist: () {
        slidingPanel3Controller.setPanel3State(Panel3State.CENTER);
      },
      videoInfo: videoDetail,
      fileUrls: videoUrls,
    );
  }

  Widget _buildVideoSection(bool isPortrait) {
    return Expanded(
      flex: 2,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child:
            VideoView(
              urlList: videoUrls,
              height: isPortrait ? null : MediaQuery.of(context).size.height * 0.5,
            ),
          ),
          Flexible(
            child: ScreenTypeLayout.builder(
              mobile: (context) => OrientationLayoutBuilder(
                portrait: (context) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildTabBarView(),
                ),
                landscape: (context) => _buildVideoProfile(),
              ),
              tablet: (context) => _buildVideoProfile(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return ContainedTabBarView(
      tabs: const [
        Center(child: Text('简介')),
        Center(child: Text('评论')),
      ],
      views: [
        _buildVideoProfile(),
        const Comment(),
      ],
      onChange: (index) => print(index),
    );
  }

  Widget _buildCommentSection(bool isPortrait) {
    return Expanded(
      flex: getValueForScreenType(context: context, mobile: (isPortrait ? 0 : 1), tablet: 1),
      child: ScreenTypeLayout.builder(
        mobile: (context) => OrientationLayoutBuilder(
          portrait: (context) => const SizedBox.shrink(),
          landscape: (context) => Comment(),
        ),
        tablet: (context) => Comment(),
      ),
    );
  }

  Widget _buildSliverPanel() {
    return Align(
      alignment: AlignmentDirectional.bottomCenter,
      child: SliverPanel3View(
        heightClose: 0,
        heightCenter: 330,
        heightOpen: 680,
        headWidget: headView(),
        bodyWidget: (ScrollController sc, ScrollPhysics? physics) {
          return BodyView(sc, physics);
        },
        sliverPanel3Controller: slidingPanel3Controller,
        initPanel3state: Panel3State.CLOSE,
      ),
    );
  }
  Widget headView() {
    return Container(
      height: 108,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          )),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 12,
          ),
          InkWell(
            onTap: (){
              slidingPanel3Controller.setPanel3State(Panel3State.EXIT);
              // LocationPluginUtils.get().then((value) {
              //   SGMLogger.info(value);
              // });
            },
            child: Container(
              width: double.infinity,
              height: 40,
              alignment: AlignmentDirectional.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search , color: Colors.grey.withAlpha(80),size: 20,),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Search',
                    style: TextStyle(
                        color: Colors.grey.withAlpha(80),
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 40,
            child: Row(
              children: [
                Icon(Icons.ac_unit , color: Colors.redAccent ,size: 20,),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    '惊喜来袭！！！ 森林公园免门票 快冲...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.redAccent,
                        height: 1.2,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget BodyView(ScrollController sc ,  ScrollPhysics? physics) {

    // return Container(height: 999,width: 380, color: Colors.yellowAccent,);

    Widget _itemView(int i) {
      return Container(
        color: Colors.white,
        height: 94,
        child: Row(
          children: [
            const Icon(Icons.add_a_photo_rounded , color: Colors.orange, size: 66,),
            const SizedBox(
              width: 18,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '森林公园游乐场',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    '景点热度🔥 610$i',
                    style: TextStyle(
                        color: Colors.grey.withAlpha(80),
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                  Spacer(),
                  // LineCuttingHorizontal(colorLine: color_ededed),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: sc,
      physics: physics,
      padding: EdgeInsets.zero,
      itemCount: 19,
      itemBuilder: (BuildContext context, int i) {
        return _itemView(i);
      },
    );
  }
}
