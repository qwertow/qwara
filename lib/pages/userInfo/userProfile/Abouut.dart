import 'package:flutter/material.dart';
import 'package:qwara/components/image/ImgList.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../api/img/img.dart';
import '../../../api/video/video.dart';
import '../../../components/video/VideoList.dart';

class About extends StatefulWidget {
  const About({super.key, required this.data, this.userId});
  final Map<String, dynamic> data;
  final String? userId;
  @override
  State<About> createState() => _AboutState();
}
class _AboutState extends State<About> with AutomaticKeepAliveClientMixin {
  bool isExpanded = false; // 控制展开状态
  late Map<String, dynamic> userData = {};
  Map _newVideo = {};
  Map _newImage = {};
  bool _Loading = false;
  @override
  void initState() {
    super.initState();

    getNew();
  }
  // @override
  // void didUpdateWidget(About oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //
  // }
  Future<void> getNew() async {
    setState(() {
      _Loading = true;
    });
    int i = 0;
    while(userData.isEmpty){
      await Future.delayed(const Duration(milliseconds: 100), () {
        userData=widget.data;
      });
      i++;
      if (i > 10 * 10) {
        Fluttertoast.showToast(msg: "data获取超时");
        break;
      }
    }
    Map<String, dynamic> newVideo = await getVideoList(rating: "all",limit: 8,userId: userData['user']?['id']);
    Map<String, dynamic> newImage = await getImgList(rating: "all",limit: 8,userId: userData['user']?['id']);
    setState(() {
      _newVideo = newVideo;
      _newImage = newImage;
      _Loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          // height: 200,
          child: Column(
            children: [
              Text(
                userData['body'] ?? '该用户是个神秘人，不喜欢被人围观。',
                maxLines: isExpanded ? null : 5, // 根据状态调整显示行数
                overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis, // 根据状态调整溢出行为,
                style: const TextStyle(color: Colors.black),
                // textAlign: TextAlign.center,
              ),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Text(isExpanded ? '收起' : '展开'),
                // style: OutlinedButton.styleFrom(primary: Colors.purple),
              ),

            ],
          ),
        ),
        // newVideoList
        const Text('最新视频'),
        VideoList(items: _newVideo['results']??[], loading: _Loading,scrollPhysics: const NeverScrollableScrollPhysics(),shrink: true,),
        const Text('最新图片'),
        ImgList(items: _newImage['results']??[], loading: _Loading,scrollPhysics: const NeverScrollableScrollPhysics(),shrink: true,)
      ],
    );
  }
  Widget newVideoList(BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot){
    return VideoList(items: snapshot.data?['results']??[], loading: false,scrollPhysics: const NeverScrollableScrollPhysics(),shrink: true,);
  }

  @override
  bool get wantKeepAlive => true;

}
