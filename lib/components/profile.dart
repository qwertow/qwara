
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qwara/api/img/img.dart';
import 'package:qwara/api/video/video.dart';
import 'package:qwara/components/image/ImgList.dart';
import 'package:qwara/components/SlidingPanel3Controller.dart';
import 'package:qwara/enum/Enum.dart';
import 'package:qwara/utils/DownLoadUtil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:get/get.dart' hide Response;
import 'video/VideoList.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
enum ProfileType {
  video,
  image,
}

class Profile extends StatefulWidget {
  const Profile({super.key,
    required this.info,
    required this.files,
    this.onSetPlaylist,
    this.onDownload,
    this.handleLIke,
    this.handleFollow, this.scrollPhysics, this.scrollController, this.setClipboard, required this.type
  });

  final Map<String, dynamic> info;
  final List files;
  final Future<bool> Function()? onDownload;
  final void Function()? onSetPlaylist;
  final Future<void> Function(bool isLiked)? handleLIke;
  final Future<void> Function(bool isFollowed)? handleFollow;
  final ScrollPhysics? scrollPhysics;
  final ScrollController? scrollController;
  final Function(String url)? setClipboard;
  final ProfileType type;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with AutomaticKeepAliveClientMixin{
  // final Map<String, dynamic> _userInfo = storeController.userInfo ?? {};
  bool isLiked = false;
  bool isFollowed = false;
  bool downloadSuccess = false;
  bool _likeLoading = false;
  bool _followLoading = false;
  bool _isDark = false;

  late Map<String, dynamic> _similars={};
  late Map<String, dynamic> _authors={};


  @override
  void initState() {
    super.initState();
    getAuthorAndSimilar();
  }

  Future<void> getAuthorAndSimilar() async {
    int i = 0;
    while(widget.info.isEmpty){
      await Future.delayed(const Duration(milliseconds: 100), () {
        // print(i);
      });
      i++;
      if (i > 10 * 10) {
        // Fluttertoast.showToast(msg: "url获取超时");
        break;
      }
    }
    Map<String, dynamic> authors = widget.type == ProfileType.video
        ?await getVideoList(exclude: widget.info['id'], limit: 6, userId: widget.info['user']?['id'])
        :await getImgList(exclude: widget.info['id'], limit: 6, userId: widget.info['user']?['id']);
    Map<String, dynamic> similars = widget.type == ProfileType.video
        ?await getSimilarVideos(widget.info['id'])
        :await getSimilarImgs(widget.info['id']);
    setState(() {
      _similars = similars;
      _authors = authors;
    });
  }

  @override
  void didUpdateWidget(Profile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.info.isNotEmpty) {
      setState(() {
        isLiked = widget.info['liked'] ?? false;
        isFollowed = widget.info['user']?['following'] ?? false;
      });
    }
  }

  String getVideoDownloadUrl(Clarity clarity) {
    return "https:${widget.files.firstWhere((element)=>element["name"]==clarity.value)["src"]["download"]}";
  }

  bool isExpanded = false; // 控制展开状态
  SliverPanel3Controller slidingPanel3Controller = SliverPanel3Controller();
  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString); // 将日期字符串解析为 DateTime 对象
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime); // 格式化日期
  }
  /// showDialog
  showDialogFunction(context, Clarity clarity) {
    beforeDownload();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(10),
            width: 50.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("保存到"),
                OutlinedButton(onPressed: () async {
                  await beforeDownload();
                  Navigator.pop(context);
                  downloadSuccess = await downloading(getVideoDownloadUrl(clarity),widget.info['title'],suffix: ".mp4");
                  downCallback(downloadSuccess);
                }, child: const Text("下载文件夹")),
                OutlinedButton(onPressed: () async {
                  await beforeDownload();
                  Navigator.pop(context);
                  downloadSuccess = await downloading(getVideoDownloadUrl(clarity),widget.info['title'],suffix: ".mp4");;
                  if(downloadSuccess) {
                    moveToAlbum(widget.info['title'],suffix: ".mp4");
                  }
                  downCallback(downloadSuccess);
                }, child: const Text("相册")),
                OutlinedButton(onPressed: () async {
                  Navigator.pop(context);
                  Clipboard.setData(ClipboardData(text: getVideoDownloadUrl(clarity)));
                  showDownSnackBar( "下载链接已复制到剪贴板", type: DownloadStatus.success);
                }, child: const Text("复制下载链接")),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    _isDark = Theme.of(context).brightness == Brightness.dark;

    super.build(context);
    // print("bbbbbbbbb${widget.videoInfo['body']}");
    final _Info = widget.info.isEmpty? {
      'fake': true,
      "title": "视频标题",
      "body": "视频简介",
      "user": {
        "name": "作者名称",
        "username": "作者用户名",
        "avatar": {
          "id": "作者id",
          "name": "作者头像文件名"
        }
      },
      "tags": [
        {"id": "标签1"},
        {"id": "标签2"},
        {"id": "标签3"},
      ],
      "numViews": 1000,
      "numLikes": 100,
      "updatedAt": "2022-01-01 00:00:00"
    } : {...widget.info, 'fake': false};
    return Skeletonizer(
        enabled: widget.info.isEmpty,
        child: ListView(
          physics: widget.scrollPhysics,
          controller: widget.scrollController,
          children: [
            //作品信息
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      _Info['title'] ?? '视频标题',
                      maxLines: isExpanded ? null : 1, // 根据状态调整显示行数
                      overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis, // 根据状态调整溢出行为
                    ),
                    subtitle: Row(
                      children: [
                        Text(formatDate(_Info['updatedAt'] ?? '1970-01-01 00:00:00')),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.visibility,size: 12,),
                            Text("${_Info['numViews'] ?? 0}"),
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 5,),
                            const Icon(Icons.favorite,size: 12,),
                            Text("${_Info['numLikes'] ?? 0}"),
                          ],
                        )
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded; // 切换状态
                        });
                      },
                      icon: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up // 如果展开，使用向上的箭头
                            : Icons.keyboard_arrow_down_rounded, // 否则使用向下的箭头
                      ),
                    ),
                  ),
                  AnimatedSize(
                    curve: Curves.easeInOut,
                    duration: const Duration(milliseconds: 300), // 动画持续时间
                    child: SizedBox(
                      height: isExpanded ? null : 0, // 根据状态调整高度
                      child: Column(
                        children: [
                          if (isExpanded) // 如果是展开状态，则显示额外内容
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  if(_Info['body']!= null)
                                    Linkify(
                                        text: _Info['body'],
                                        onOpen: (link) async {
                                          final Uri _url = Uri.parse(link.url);
                                          if (!await launchUrl(_url) ){
                                            throw Exception('Could not launch $_url');
                                          }
                                        },
                                        // options: const LinkifyOptions(humanize: false),
                                    )
                                    // Text(_Info['body']),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 使子元素之间的空间均分
                    children: [
                      if(widget.type == ProfileType.video)
                      PopupMenuButton<Clarity>(
                        offset: const Offset(0, 40),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: const Icon(Icons.download),
                        ),
                        onSelected: (clarity) async {
                          showDialogFunction(context, clarity);
                        },
                        itemBuilder: (context) {
                          return Clarity.values.map((clarity) {
                            return PopupMenuItem<Clarity>(
                              value: clarity,
                              child: Text(clarity.value, style: const TextStyle(color: Colors.black)),
                            );
                          }).toList();
                        },
                      ),
                      const SizedBox.shrink(),
                      Row(  // 创建一个新的 Row 包裹分享和收藏按钮
                        children: [
                          if(widget.type == ProfileType.video)
                          IconButton(
                            onPressed: () {
                              widget.onSetPlaylist!();
                              // slidingPanel3Controller.setPanel3State(Panel3State.CENTER);
                            },
                            icon: const Icon(Icons.playlist_add_outlined),
                          ),
                          Skeletonizer(enabled: _likeLoading, child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(isLiked ? Colors.blue : _isDark ? Colors.white10 : Colors.grey[300]),
                            ),
                            onPressed: () async {
                              setState(() {
                                _likeLoading = true;
                              });
                              await widget.handleLIke?.call(isLiked);
                              setState(() {
                                _likeLoading = false;
                              });
                            },
                            child: Text(isLiked ? 'unlike': 'like'),
                          )),
                          const SizedBox(
                            width: 20,
                          )
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            //作者信息
            Card(
                child: ListTile(
                  leading: InkWell(
                    onTap: () {
                      Get.toNamed('/userProfile', arguments: _Info['user']);
                    },
                    child: CircleAvatar(
                      radius: 26,
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
                  ),
                  title: Text(_Info['user']?['name'] ?? '作者名称'),
                  subtitle: Text("@${_Info['user']?['username'] ?? '作者用户名'}"),
                  trailing: Skeletonizer(enabled: _followLoading, child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(isFollowed ? Colors.blue : _isDark ? Colors.white10 : Colors.grey[300]),
                      ),
                      onPressed: () async {
                        setState(() {
                          _followLoading = true;
                        });
                        await widget.handleFollow?.call(isFollowed);
                        setState(() {
                          _followLoading = false;
                        });
                      },
                      child: Text(isFollowed ? '已关注': '关注'))),
                )
            ),
            //tags
            Wrap(
              runSpacing: -10,
              spacing: 5,
              children: [..._Info['tags']?.map((tag) => TextButton(onPressed: () {
                  Get.toNamed('/home', arguments: {
                    "index":widget.type == ProfileType.video? 1:2,
                    "tagId": tag['id'],
                  });
              }, style: ButtonStyle(
                minimumSize: WidgetStatePropertyAll(Size(50, 0)),
                maximumSize: WidgetStatePropertyAll(Size(1000, 30)),
                  backgroundColor: WidgetStateProperty.all(_isDark ? Colors.white10 : Colors.grey[200]),
              ),
                  child: Text(tag['id'],style: const TextStyle(fontSize: 12,height: 1),)
              ))],
            ),
            //作者作品列表
            const Text("作者作品列表"),
            _buildList(_authors['results']?.cast<Map<String, dynamic>>()),


            //类似作品
            const Text("类似作品"),
            _buildList(_similars['results']?.cast<Map<String, dynamic>>()),

          ],
        )
    );
  }
  Widget _buildList(List<Map<String, dynamic>>? data) {
    return widget.type == ProfileType.video
        ?VideoList(
      items: data ?? [],
      loading: false,crossAxisCountTablet: 3,
      scrollPhysics: const NeverScrollableScrollPhysics(),shrink: true,)
        : ImgList(
      items: data ?? [],
      loading: false,crossAxisCountTablet: 3,
      scrollPhysics: const NeverScrollableScrollPhysics(),shrink: true,
    );
  }
  @override
  bool get wantKeepAlive => true;
}

