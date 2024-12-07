import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:qwara/getX/StoreController.dart';
import 'package:qwara/pages/videoDetail/FullScreen.dart';
import 'package:qwara/utils/TimeUtil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

import '../enum/Enum.dart';
import '../utils/LogUtil.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  late VideoPlayerController _controller;

  final List<DownloadVideo> videoData = [];
  @override
  void initState() {
    super.initState();
    _getDV();
    _initController('');
    // LogUtil.d('videoData: ${videoData.map((e) => e.toJson())}');
    // print(videoData.map((e) => e.toJson()));
  }
  _getDV(){
    videoData.clear();
    videoData.addAll(storeController.downloadVideos.reversed);
  }
  Clarity getClarity(String clarity) {
    switch (clarity) {
      case "360":
        return Clarity.low;
      case "540":
        return Clarity.medium;
      case "source":
        return Clarity.source;
      default:
        return Clarity.low;
    }
  }
  //初始化控制器
  void _initController(String path) {
    _controller = VideoPlayerController.file(File(path))
      ..initialize();
  }

  //加载视频
  Future<void> _loadVideo(String path) async {

    if (!_controller.value.isInitialized) {
      //没有视频在播放
      _initController(path);
    } else {
      // 如果有控制器，我们需要先处理旧的
      final VideoPlayerController oldController = _controller;
      // 为下一帧的结束注册回调
      // 处理一个旧控制器
      // (调用setState后不再使用)
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await oldController.dispose();
      });
      // 通过将其设置为null来确保没有使用该控制器
      setState(() {
        _controller.dispose();
        _initController(path);
      });

    }
    return;
  }
  String getThumbnailUrl(Map<String, dynamic> itm) {
    var customThumbnail ;
    var id ;
    var name ;
    String thumbnailUrl = "";
    try {
      customThumbnail = itm["customThumbnail"];
      // print(customThumbnail.toString());
      id = customThumbnail != null ? customThumbnail["id"] : itm["file"]["id"];
      name = customThumbnail != null ? customThumbnail["name"] : "thumbnail-${itm['thumbnail'].toString().padLeft(2, '0')}.jpg";
      thumbnailUrl = "https://i.iwara.tv/image/thumbnail/$id/$name";

    }catch(e){
      print(e);
    }
    return thumbnailUrl;

  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('下载'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {
              Fluttertoast.showToast(msg: '只记录下载文件夹');
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: videoData.length,
        itemBuilder: (context, index) {
          var video = videoData[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.grey[200],
            child: ListTile(
              onTap: () {
                _loadVideo('${video.localVPath}.mp4');
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return FullScreen(controller: _controller,onBack: (){
                    // print('onBack');
                    _controller.dispose();
                  },FpClarity: [getClarity(video.localVPath.split('_')[-2])],);
                }));
              },
              leading: CachedNetworkImage(
                imageUrl: getThumbnailUrl(video.downloadVInfo),
                fit: BoxFit.fitWidth, // 使宽度填满，并保持高度按比例缩放
                progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                  child: CircularProgressIndicator(
                    value: downloadProgress.progress,
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error,color: Colors.red,size: 50,),
              ),
              title: Text(
                video.localVPath.split('/').last,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(formatDate(video.downloadTime.toString()) ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  Get.dialog(AlertDialog(
                    title: const Text('确认删除'),
                    content: Text('确认删除${video.localVPath.split('/').last}?'),
                    actions: [
                      TextButton(
                        child: const Text('取消'),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                      TextButton(
                        child: const Text('确认'),
                        onPressed: () async {
                          await storeController.removeDownloadVideo(video.localVPath);
                          setState(() {
                            _getDV();
                          });
                          Get.back();
                        },
                      ),
                    ],
                  ));
                },
            ),)
          );
        },
      ),
    );
  }
}
