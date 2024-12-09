import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:qwara/getX/StoreController.dart';
import 'package:qwara/pages/videoDetail/FullScreen.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:qwara/utils/TimeUtil.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../enum/Enum.dart';
class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  late VideoPlayerController _controller;

  final List<MyDownloadTask> taskData = [];
  @override
  void initState() {
    super.initState();
    _getDV();
    _initController('');
    // LogUtil.d('videoData: ${videoData.map((e) => e.toJson())}');
    // print(videoData.map((e) => e.toJson()));
  }
  _getDV(){
    taskData.clear();
    taskData.addAll(storeController.downloads.reversed);
    print(taskData.map((e) => e.toJson()));
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
        // actions: [
          // IconButton(
          //   icon: const Icon(Icons.help_outline_rounded),
          //   onPressed: () {
          //     Fluttertoast.showToast(msg: '只记录下载文件夹');
          //   },
          // ),
        // ],
      ),
      body: ListView.builder(
        itemCount: taskData.length,
        itemBuilder: (context, index) {
          var task = taskData[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            // color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  onTap: () async {
                    if (isVideoFile('${task.savedDir}/${task.filename}')) {
                      _loadVideo('${task.savedDir}/${task.filename}');
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return FullScreen(controller: _controller,onBack: (){
                          // print('onBack');
                          _controller.dispose();
                        },FpClarity: [getClarity(task.filename!.split('_').reversed.toList()[1])],);
                      }));
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ShowImagePage(imagePath: '${task.savedDir}/${task.filename}'),
                      ));
                    }
                  },
                  leading: SizedBox(
                    width: 100,
                    child: buildMediaWidget("${task.savedDir}/${task.filename}"),
                  ),
                  title: Text(
                    task.filename ?? "unknown",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(formatMilliseconds(task.timeCreated)),
                  trailing: task.status.index==3?IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      Get.dialog(AlertDialog(
                        title: const Text('确认删除'),
                        content: Text('确认删除${task.filename}?'),
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
                              await storeController.removeDownloadTask("${task.savedDir}/${task.filename}",task.taskId);
                              setState(() {
                                _getDV();
                              });
                              Get.back();
                            },
                          ),
                        ],
                      ));
                    },
                  )
                      : IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async {
                      FlutterDownloader.retry(taskId: task.taskId);
                      await storeController.removeDownloadTask("${task.savedDir}/${task.filename}",task.taskId);
                      setState(() {
                        _getDV();
                      });
                    },
                  )
                ),
                Text('  ${task.savedDir}/${task.filename}'),
              ],
            )
          );
        },
      ),
    );
  }
  Future<dynamic> getThumbnailData(String videoPath) async {
    // 从视频中生成缩略图数据
    final thumbnailData = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 1280, // 最大宽度
      quality: 75,     // 缩略图质量
      timeMs: 5000,   // 获取视频的第 5 秒的帧
    );

    return thumbnailData; // 返回缩略图数据
  }
  Widget buildMediaWidget(String filePath) {
    // 检查文件类型（假设 filePath 是文件的路径）
    if (isVideoFile(filePath)) {
      // 如果是视频文件，显示缩略图
      return FutureBuilder(
        future: getThumbnailData(filePath),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.memory(snapshot.data);
          } else if (snapshot.hasError) {
            return const Icon(Icons.error, color: Colors.red, size: 50,);
          } else {
            return const Center(child: CircularProgressIndicator(),);
          }
        },
      );
    } else {
      // 如果是图片文件，直接显示
      return Image.file(
        File(filePath),
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error, color: Colors.red, size: 50,);
        },
      );
    }
  }

// 辅助方法，用于判断文件类型
  bool isVideoFile(String filePath) {
    return filePath.endsWith('.mp4') || filePath.endsWith('.webm'); // 这里根据需要添加更多视频格式
  }
}
class ShowImagePage extends StatelessWidget {
  final String imagePath;

  const ShowImagePage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.file(File(imagePath)),
      ), // 根据路径加载图片
    );
  }
}