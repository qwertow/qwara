import 'package:flutter/material.dart';
import 'package:qwara/api/img/img.dart';
import 'package:qwara/api/video/video.dart';
import 'package:qwara/components/image/ImgList.dart';
import 'package:qwara/components/video/VideoList.dart';
import 'package:qwara/api/user/user.dart';
import 'package:qwara/EventBus/EventBus.dart';
import 'package:qwara/components/pager.dart';

import '../../components/Mydropdown.dart';
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  late int totalPages_video=0;
  late int currentPage_video=1;
  late int totalPages_img=0;
  late int currentPage_img=1;
  // 假设有一些示例数据
  late List videoItems = [];
  late List imgItems = [];
  late bool videoListLoadings=false;
  late bool imgListLoadings=false;

  bool _isVideo=true;

  void getData() async {
    if(storeController.token==null){
      return;
    }
    Map res;
    if(_isVideo){
      setState(() {
        videoListLoadings=true;
      });
      res=await getSubscribedVideos(
        page: currentPage_video,
      );
      setState(() {
        totalPages_video=(res["count"]/res["limit"]).ceil();
        videoItems.clear();
        videoItems.addAll(res["results"]);
        videoListLoadings=false;
      });
    }else{
      setState(() {
        imgListLoadings=true;
      });
      res=await getSubscribedImgs(
        page: currentPage_img,
      );
      setState(() {
        totalPages_img=(res["count"]/res["limit"]).ceil();
        imgItems.clear();
        imgItems.addAll(res["results"]);
        print("sssssssss$imgItems");
        imgListLoadings=false;
      });
    }

    // print(res);
  }

  @override
  void initState() {
    super.initState();
    getData();
    eventBus.on<UpdateAccessTokenEvent>().listen((event) {
      getData();
    });
  }

  @override
  // 保持页面状态
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: Column(
          children: [
            Flexible(
                child: _isVideo? VideoList(items: videoItems,loading: videoListLoadings):ImgList(items: imgItems, loading: imgListLoadings)
            ),
            Pager(currentPage: _isVideo? currentPage_video:currentPage_img, totalPages: _isVideo? totalPages_video:totalPages_img,
                pageChanged: (page){
                  setState(() {
                    print("page changed to $page");
                    if(_isVideo){
                      currentPage_video=page;
                    }else{
                      currentPage_img=page;
                    }
                  });
                  getData();
                }, leading: MyDropdownButton<bool>(
                  icon: const Icon(Icons.sort),
                  value: _isVideo,
                  onChanged: (bool? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _isVideo=newValue;
                        print("sort changed to $newValue");
                      });
                      getData();
                    }
                  },
                  items: const [
                    MyDropdownMenuItem<bool>(
                      value: true,
                      child: Row(
                        children: [
                          Icon(Icons.video_library_rounded, color: Colors.black),
                          SizedBox(width: 8),
                          Text('视频', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                    MyDropdownMenuItem<bool>(
                      value: false,
                      child: Row(
                        children: [
                          Icon(Icons.image_rounded, color: Colors.black),
                          SizedBox(width: 8),
                          Text('图片', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    )
                  ],
                  dropdownColor: Colors.white, // 设置下拉菜单的背景颜色
                  // iconEnabledColor: Colors.blue, // 下拉箭头的颜色
                  underline: Container(), // 隐藏下划线
                  style: const TextStyle(color: Colors.black), // 字体颜色
                ))
          ],
        )
    );
  }
}
