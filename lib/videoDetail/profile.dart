import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwara/components/SlidingPanel3Controller.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, required this.videoInfo, required this.fileUrls, this.onAddPlaylist});

  final Map<String, dynamic> videoInfo;
  final List fileUrls;
  // final Function onDownload;
  final void Function()? onAddPlaylist;
  // final Function onLIke;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isExpanded = false; // 控制展开状态
  SliverPanel3Controller slidingPanel3Controller = SliverPanel3Controller();
  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString); // 将日期字符串解析为 DateTime 对象
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime); // 格式化日期
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
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.download),
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
                  leading: const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage('https://picsum.photos/200'),
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

