import 'package:flutter/material.dart';
import 'package:qwara/api/img/img.dart';
import 'package:qwara/api/video/video.dart';
import 'package:qwara/components/exception/TimeoutPage.dart';
import 'package:qwara/components/image/ImgList.dart';
import 'package:qwara/components/video/VideoList.dart';
import 'package:qwara/EventBus/EventBus.dart';
import 'package:qwara/components/pager.dart';
import 'package:qwara/getX/StoreController.dart';
import '../../components/Mydropdown.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  bool _isDark = false;
  late int totalPages_video=0;
  late int currentPage_video=1;
  late int totalPages_img=0;
  late int currentPage_img=1;
  // 假设有一些示例数据
  late List videoItems = [];
  late List<Map<String, dynamic>> imgItems = [];
  late bool videoListLoadings=false;
  late bool imgListLoadings=false;
  bool timeout=false;

  bool _isVideo=true;

  void getData() async {
    if(storeController.token==null){
      return;
    }
    Map<String, dynamic> res;
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
        imgItems.addAll(res["results"].cast<Map<String, dynamic>>());
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
    eventBus.on<TimeOutEvent>().listen((event) {
      setState(() {
        timeout=true;
      });
    });
  }


  @override
  // 保持页面状态
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
        body: Column(
          children: [
            Flexible(
                child: !timeout ? _isVideo ? VideoList(items: videoItems,loading: videoListLoadings):ImgList(items: imgItems, loading: imgListLoadings) :  TimeoutPage(
                  onRetry: (){
                    setState(() {
                      timeout=false;
                    });
                    getData();
                  },
                )
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
                          Icon(Icons.video_library_outlined),
                          SizedBox(width: 8),
                          Text('视频'),
                        ],
                      ),
                    ),
                    MyDropdownMenuItem<bool>(
                      value: false,
                      child: Row(
                        children: [
                          Icon(Icons.image_outlined),
                          SizedBox(width: 8),
                          Text('图片')
                        ],
                      ),
                    )
                  ],
                  underline: Container(), // 隐藏下划线
                  style: TextStyle(color: _isDark? Colors.white : Colors.black), // 字体颜色
                ))
          ],
        )
    );
  }
}
