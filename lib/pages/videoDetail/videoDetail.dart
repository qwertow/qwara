import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:qwara/api/subscribe/follow.dart';
import 'package:qwara/api/subscribe/like.dart';
import 'package:qwara/api/subscribe/playList.dart';
import 'package:qwara/getX/StoreController.dart';
import 'package:flutter/material.dart';
import 'package:qwara/api/video/video.dart';
import 'package:qwara/components/video/VideoView.dart';
import 'package:floating_tabbar/lib.dart';
import 'package:crypto/crypto.dart';
import 'package:qwara/constant.dart';
import 'package:qwara/components/profile.dart';
import 'package:qwara/pages/generalPage/CommentPage.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:get/get.dart';


class VideoDetail extends StatefulWidget {
  const VideoDetail({
    super.key,
    required this.videoInfo,
  });

  final Map<String, dynamic> videoInfo; // 视频信息

  @override
  State<VideoDetail> createState() => _VideoDetail();
}

class _VideoDetail extends State<VideoDetail>  {

  final GlobalKey<VideoViewState> videoViewKey = GlobalKey<VideoViewState>();

  late double? _videoViewHeight=null;

  final ScrollController _profileScrollController = ScrollController(
    initialScrollOffset: 0.01,
  );
  final ScrollController _commentScrollController = ScrollController(
    initialScrollOffset: 0.01
  );
  late ScrollPhysics? _scrollPhysics = null;
  bool pLisTouched = false;
  bool cLisTouched = false;
  bool isHorizontalSlide = false;
  bool isNewer = storeController.detailPageVersion;

  void _changeVideoViewSize(PointerMoveEvent pointerMoveEvent) {
    // 判断滑动方向
    isHorizontalSlide = pointerMoveEvent.delta.dx.abs() > pointerMoveEvent.delta.dy.abs();

    if (isHorizontalSlide) {
      print("水平滑动");
      setState(() {});
      return;
    } else {
      print("垂直滑动");
    }

// 处理播放状态
    if (!(videoViewKey.currentState?.vcInit ?? false) || (videoViewKey.currentState?.isPlaying ?? true)) {
      print("播放状态");
      if(_scrollPhysics != null){
        _scrollPhysics = null; // 可滚动
      }

      if (_videoViewHeight != null) {
        _videoViewHeight = null; // 设置为默认值
      }
      setState(() {});
      return;
    }

    // 获取屏幕高度
    double screenHeight = MediaQuery.of(context).size.height;
    double scrollOffset = 0.0;
// 处理 _videoViewHeight 为 null 的情况
    _videoViewHeight ??= screenHeight * 0.5;
    // print("_videoViewHeighttf: ${_profileScrollController.hasClients} ${_commentScrollController.hasClients}");
    // 获取两个 ScrollController 的 offset 值
    if (_profileScrollController.hasClients && pLisTouched) {
      print("_profileScrollController hasClients ${_profileScrollController.offset}");
      scrollOffset += _profileScrollController.offset;
    }

    if (_commentScrollController.hasClients && cLisTouched) {
      print("_commentScrollController hasClients");
      scrollOffset += _commentScrollController.offset;
    }

    print("scrollOffset: $scrollOffset");
    // 暂停状态
    setState(() {
      if (scrollOffset == 0) {
        print("情况一 暂停，offset==0$_videoViewHeight");
        if(pointerMoveEvent.delta.dy < 0){
          // 上拉
          if(_videoViewHeight == 0 && _scrollPhysics != null){
            _scrollPhysics = null;
          }
          print("上拉 ${_scrollPhysics == null}");
          if((_scrollPhysics != null || _videoViewHeight != null)&& _videoViewHeight != 0){
            _scrollPhysics ??= const NeverScrollableScrollPhysics();
            _videoViewHeight = (_videoViewHeight! + pointerMoveEvent.delta.dy).clamp(0, screenHeight * 0.5);
          }
        }else{
          _scrollPhysics ??= const NeverScrollableScrollPhysics();
          // 下拉
          if(_videoViewHeight == 0){
            _videoViewHeight = null; // 设置为默认值
          }else{
            _videoViewHeight = (_videoViewHeight! + pointerMoveEvent.delta.dy).clamp(0, screenHeight * 0.5);
          }
        }
      } else {
        print("情况二 offset!=0");
        if (pointerMoveEvent.delta.dy < 0) {
          // 上拉
          print("上拉 0001}");
          if(_videoViewHeight! >0 ){
            _scrollPhysics ??= const NeverScrollableScrollPhysics();
            _videoViewHeight = (_videoViewHeight! + pointerMoveEvent.delta.dy).clamp(0, screenHeight * 0.5);
          }
        }else{
          // 下拉
          print("下拉 0001}");
          if(_scrollPhysics != null){
            _scrollPhysics = null; // 可滚动
          }
        }
      }
    });

    // setState(() {});
    return;
  }

  void _changeVideoViewSizeNewer(PointerMoveEvent pointerMoveEvent) {
    if(_scrollPhysics != null){
      _scrollPhysics = null; // 可滚动
    }

    // 判断滑动方向
    isHorizontalSlide = pointerMoveEvent.delta.dx.abs() > pointerMoveEvent.delta.dy.abs();

    if (isHorizontalSlide) {
      print("水平滑动");
      try{
        _commentScrollController.jumpTo(_commentScrollController.offset+0.01);
      }catch(e){
        print(e);
      }
      try{
        _profileScrollController.jumpTo(_profileScrollController.offset+0.01);
      }catch(e){
        print(e);
      }
      setState(() {});
      return;
    } else {
      print("垂直滑动");
    }
// 处理播放状态
    if (!(videoViewKey.currentState?.vcInit ?? false) || (videoViewKey.currentState?.isPlaying ?? true)) {
      print("播放状态");

      if (_videoViewHeight != null) {
        _videoViewHeight = null; // 设置为默认值
      }
      setState(() {});
      return;
    }

    double scrollOffset = 0.0;
    if (_profileScrollController.hasClients && pLisTouched) {
      print("_profileScrollController hasClients ${_profileScrollController.offset}");
      scrollOffset += _profileScrollController.offset;
    }

    if (_commentScrollController.hasClients && cLisTouched) {
      print("_commentScrollController hasClients ${_commentScrollController.offset}");
      scrollOffset += _commentScrollController.offset;
    }

    // 暂停状态
    // if (scrollOffset > 50) {
      setState(() {
        if(pointerMoveEvent.delta.dy < 0){
          // 上拉
          if(scrollOffset > 40.h){
            _videoViewHeight ??= 0;
          }

        }else{
          // 下拉
          if(_videoViewHeight != null && scrollOffset == 0){
            _videoViewHeight = null; // 设置为默认值
          }
        }
      });
    // }


    // setState(() {});
    return;
  }

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
    _getVideoUrls();
    _commentScrollController.addListener(() {
      // print("commentScrollController: ${_commentScrollController.offset}");
      _toucheStatus("comment");
    });
    _profileScrollController.addListener(() {
      // print("profileScrollController: ${_profileScrollController.offset}");
      _toucheStatus("profile");
    });
  }

  late Map<String, dynamic> videoDetail={};
  final List videoUrls=[];
  Future<void> _getVideoDetail(String id) async {
    final res = await getVideoDetail(id);
    try {
      setState(() {
        videoDetail=res;
      });
    }catch (e) {
      print(e);
    }

    // return res;
  }

  _getVideoUrls()  async {
      await _getVideoDetail(widget.videoInfo['id']);
      String fileUrl = videoDetail['fileUrl'];
      print("fileUrl: $fileUrl");
      Uri uri = Uri.parse(fileUrl);

      // 获取 expires 参数的值
      String? expiresValue = uri.queryParameters['expires'];
      var value = sha1.convert(utf8.encode("${videoDetail["file"]["id"]}_${expiresValue}_$xVersion"));

      final res = await getVideoUrls(fileUrl,value.toString());

      try{
        setState(() {
          videoUrls.clear();
          videoUrls.addAll(res);
        });
      }catch(e){
        print(e);
      }

      print(res);
      return res;
  }


  @override
  void dispose() {
    super.dispose();
    _commentScrollController.dispose();
    _profileScrollController.dispose();
  }
  @override
  Widget build(BuildContext context) {
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
          ],
        ),
    );
  }


  Widget _buildVideoProfile() {
    return Profile(
      type: ProfileType.video,
      scrollPhysics: _scrollPhysics,
      // onDownload: _downloadVideo,
      scrollController: _profileScrollController,
      handleFollow: (isFollowed) async {
        if (isFollowed) {
          await unfollowUser(videoDetail['user']["id"]);
        }else {
          await followUser(videoDetail['user']["id"]);
        }
        await _getVideoDetail(widget.videoInfo['id']);
      },
      handleLIke: (isLiked) async {
        if (isLiked) {
          await unlikeVideo(videoDetail['id']);
        }else {
          await likeVideo(videoDetail['id'], storeController.userInfo?["user"] ?? {});
        }
        await _getVideoDetail(widget.videoInfo['id']);
      },
      onSetPlaylist: () {
        _showModalBottomSheet(context);
      },
      info: videoDetail,
      files: videoUrls,
    );
  }
  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return _PlayLists(videoId: widget.videoInfo['id']);
      },
    );
  }
  Widget _buildVideoSection(bool isPortrait) {
    return Expanded(
      flex: 3,
      child: Column(
        children: [
          Container(
            color: Colors.black,
            // height: _videoViewSSize,
            // duration: const Duration(milliseconds: 30000),
            child:
            VideoView(
              key: videoViewKey,
              urlList: videoUrls,
              // width: _videoViewWidth,
              height:_videoViewHeight,
            ),
          ),
          Flexible(
            child: Listener(
              onPointerMove: isNewer ? _changeVideoViewSizeNewer : _changeVideoViewSize,
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
            tab: _buildVideoProfile(),
          ),
          TabItem(
            title: const Text("评论"),
            onTap: () {},
            tab: CommentPage(
              scrollPhysics: _scrollPhysics,
              scrollController: _commentScrollController,
              getComments: (int page ) async {
                return getVideoComments(widget.videoInfo['id'], page: page);
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
              return getVideoComments(widget.videoInfo['id'], page: page);
            },),
        ),
        tablet: (context) => CommentPage(
          getComments: (int page ) async {
            return getVideoComments(widget.videoInfo['id'], page: page);
          },),
      ),
    );
  }

}

class _PlayLists extends StatefulWidget {
  const _PlayLists({required this.videoId});
  final String videoId;

  @override
  State<_PlayLists> createState() => __PlayListsState();
}

class __PlayListsState extends State<_PlayLists> {
  final List<Map<String, dynamic>> _playLists = List.generate(10, (i) {
    return {
      'title': 'title$i',
    };
  });
  TextEditingController playListController = TextEditingController();
  ScrollPhysics? _scrollPhysics = null;
  ScrollController _scrollController = ScrollController();
  bool playListLoading = false;
  bool upLoading = false;
  Future<void> _getPlaylist() async {
    if(!upLoading){
      setState(() {
        playListLoading = true;
      });
    }

    final List<Map<String, dynamic>> res = await getPlayListByVideoId(widget.videoId);
    setState(() {
      _playLists.clear();
      // print('999');
      _playLists.addAll(res);
      // print('888');
      playListLoading = false;
    });
    print(playListLoading);
  }

  Future<void> _addPlayList(String pid, String vId) async {
    setState(() {
      upLoading = true;
    });
    await addVideoToPlayList(pid, vId);
    await _getPlaylist();
    setState(() {
      upLoading = false;
    });
  }
  Future<void> _removePlayList(String pid, String vId) async {
    setState(() {
      upLoading = true;
    });
    await removeVideoFromPlayList(pid, vId);
    await _getPlaylist();
    setState(() {
      upLoading = false;
    });
  }

  Future<void> _createPlayList(String title) async {
    await createPlayList(title);
    await _getPlaylist();
  }
  @override
  void initState() {
    super.initState();
    _getPlaylist();
  }

  Widget _HeadView() {
    return Column(
      children: [
        Divider(
          // height: 2,
          thickness: 5,
          indent: 35.w,
          endIndent: 35.w,
        ),
        Container(
          // color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: playListController,
                  decoration: const InputDecoration(
                    hintText: 'title',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              // const SizedBox(width: 8.0),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Get.dialog(AlertDialog(
                    title: const Text('创建播放列表'),
                    content: Text(playListController.text),
                    // titleTextStyle: const TextStyle(fontSize: 20),
                    actions: [
                      TextButton(
                        child: const Text('取消'),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                      TextButton(
                        child: const Text('创建'),
                        onPressed: () {
                          if (playListController.text.trim().isEmpty) {
                            return;
                          }
                          _createPlayList(playListController.text.trim());
                          Get.back();
                          playListController.clear();
                        },
                      ),
                    ],
                  ));
                },
              ),
            ],
          ),
        )
      ],
    );
  }
  Widget _BodyView() {
    // return Container(height: 999,width: 380, color: Colors.yellowAccent,);

    Widget _itemView(int i) {
      return Card(
        color: Colors.pink[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          title: Text(
            _playLists[i]['title'],
          ),
          trailing: Skeletonizer(
              enabled: upLoading,
              child: Switch(
                value: _playLists[i]['added']?? false,
                onChanged: (bool newValue) {
                  if (newValue) {
                    _addPlayList(_playLists[i]['id'], widget.videoId);
                  }else {
                    _removePlayList(_playLists[i]['id'], widget.videoId);
                  }
                },
              )),
        ),
      );
    }

    return Skeletonizer(
        enabled: playListLoading,
        child: Listener(
          onPointerMove: (PointerMoveEvent event){
            if(event.delta.dy > 0){
              if(_scrollController.hasClients && _scrollController.offset==0){
                setState(() {
                  _scrollPhysics = const NeverScrollableScrollPhysics();
                });
              }
            }else{
              setState(() {
                _scrollPhysics = null;
              });
            }
          },
          child: ListView.builder(
            controller: _scrollController,
            physics: _scrollPhysics,
            itemCount: _playLists.length,
            itemBuilder: (context, index) {
              return _itemView(index);
            },
          ),
        )
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          _HeadView(),
          Flexible(
            child: _BodyView(),
          )
        ],
      ),
    );
  }
}
