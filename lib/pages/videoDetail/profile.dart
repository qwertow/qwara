import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwara/components/SlidingPanel3Controller.dart';
import 'package:qwara/enum/Enum.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:r_album/r_album.dart';

import 'package:qwara/utils/dioRequest.dart';

class Profile extends StatefulWidget {
  const Profile({super.key,
    required this.videoInfo,
    required this.fileUrls,
    this.onAddPlaylist,
    this.onDownload
  });

  final Map<String, dynamic> videoInfo;
  final List fileUrls;
  final Future<bool> Function()? onDownload;
  final void Function()? onAddPlaylist;
  // final Function onLIke;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final Map<String, dynamic> _userInfo = storeController.userInfo;
  bool downloadSccuess = false;
  void _downSccuessCallback() {

  }
  ///当前进度进度百分比  当前进度/总进度 从0-1
  double currentProgress =0.0;
  Future<bool> _downloadVideo(String definition) async {

    return await downLoadFile("https:${widget.fileUrls.firstWhere((element)=>element["name"]==definition)["src"]["download"]}",
        savePath: await getPhoneLocalPath(),
        fileName: "${widget.videoInfo['title']}.mp4",
        receiveProgress: (received, total) {
          if (total != -1) {
            ///当前下载的百分比例
            print((received / total * 100).toStringAsFixed(0) + "%");
            // CircularProgressIndicator(value: currentProgress,) 进度 0-1
            currentProgress = received / total;
            // setState(() {
            //
            // });
          }
        }
    );
  }
  bool isExpanded = false; // 控制展开状态
  SliverPanel3Controller slidingPanel3Controller = SliverPanel3Controller();
  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString); // 将日期字符串解析为 DateTime 对象
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime); // 格式化日期
  }
  /// showDialog
  showDialogFunction(context, Clarity clarity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            height: 200,
            width: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("保存到"),
                TextButton(onPressed: () async {
                  Navigator.pop(context);
                  downloadSccuess = await _downloadVideo(clarity.value);
                  if(downloadSccuess) {
                    _downSccuessCallback();
                  }
                }, child: const Text("下载文件夹")),
                TextButton(onPressed: () async {
                  Navigator.pop(context);
                  downloadSccuess = await _downloadVideo(clarity.value);
                  if(downloadSccuess) {
                    String originalFilePath = "${await getPhoneLocalPath()}${widget.videoInfo['title']}.mp4";
                    bool? createAlbum = await RAlbum.createAlbum("qwara");
                    if(createAlbum ?? false) {
                      await RAlbum.saveAlbum(
                          "qwara", [originalFilePath],["${widget.videoInfo['title']}.mp4"]);
                      // 删除原始文件
                      File originalFile = File(originalFilePath);
                      if (await originalFile.exists()) {
                        await originalFile.delete();
                        print("原始文件已删除：$originalFilePath");
                      } else {
                        print("文件不存在：$originalFilePath");
                      }
                    }
                    _downSccuessCallback();
                  }
                }, child: const Text("相册"))
              ],
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    // print("bbbbbbbbb${widget.videoInfo['body']}");
    return Skeletonizer(
        enabled: widget.videoInfo.isEmpty,
        child: ListView(
          children: [
            //视频信息
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      widget.videoInfo['title'] ?? '视频标题',
                      maxLines: isExpanded ? null : 1, // 根据状态调整显示行数
                      overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis, // 根据状态调整溢出行为
                    ),
                    subtitle: Text(formatDate(widget.videoInfo['updatedAt'] ?? '1970-01-01 00:00:00')),
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
                                  if(widget.videoInfo['body']!= null)
                                    Text(widget.videoInfo['body']),
                                  // Text("这里是完整的内容和其他组件..."), // 你可以在这里添加任何其他组件
                                  // 例如：其他信息或图片等
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

                      Row(  // 创建一个新的 Row 包裹分享和收藏按钮
                        children: [
                          IconButton(
                            onPressed: () {
                              widget.onAddPlaylist!();
                              // slidingPanel3Controller.setPanel3State(Panel3State.CENTER);
                            },
                            icon: const Icon(Icons.playlist_add_outlined),
                          ),
                          TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(Colors.grey[300]),
                            ),
                            onPressed: () {},
                            child: const Text('like'),
                          ),
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
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage:widget.videoInfo['user'] == null? null : NetworkImage(
                        'https://i.iwara.tv/image/avatar/${widget.videoInfo['user']?['avatar']['id'] }/${widget.videoInfo['user']?['avatar']['name']}',
                      headers: {
                        'Referer':"https://www.iwara.tv/",
                        // 'Content-Type':'image/jpeg'
                      }
                    ),
                  ),
                  title: Text(widget.videoInfo['user']?['name'] ?? '作者名称'),
                  subtitle: Text("@${widget.videoInfo['user']?['username'] ?? '作者用户名'}"),
                  trailing: TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.grey[300]),
                      ),
                      onPressed: () {},
                      child: const Text('关注')),
                )
            ),
            //tags
            Row(
              children: [
                TextButton(onPressed: () {}, child: const Text('标签  456')),
                TextButton(onPressed: () {}, child: const Text('标签')),
                TextButton(onPressed: () {}, child: const Text('标签')),
              ],
            ),
            //作者作品列表

            //类似作品



            Text("这里是完整的内容和其他组件..."), // 你可以在这里添加任何其他组件
            Text("这里是完整的内容和其他组件..."), // 你可以在这里添加任何其他组件
            Text("这里是完整的内容和其他组件..."), // 你可以在这里添加任何其他组件
            Text("这里是完整的内容和其他组件..."), // 你可以在这里添加任何其他组件
            Text("这里是完整的内容和其他组件..."), // 你可以在这里添加任何其他组件
            Text("这里是完整的内容和其他组件..."), // 你可以在这里添加任何其他组件
            Text("这里是完整的内容和其他组件..."), // 你可以在这里添加任何其他组件
            Text("这里是完整的内容和其他组件..."), // 你可以在这里添加任何其他组件
            Text("这里是完整的内容和其他组件..."), // 你可以在这里添加任何其他组件
            Text("这里是完整的内容和其他组件..."), // 你可以在这里添加任何其他组件
          ],

        )
    );
  }
}

