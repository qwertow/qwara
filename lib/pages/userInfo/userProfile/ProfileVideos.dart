import 'package:flutter/material.dart';
import 'package:qwara/api/video/video.dart';

import 'package:qwara/components/video/VideoList.dart';
import 'package:qwara/components/pager.dart';

class ProfileVideos extends StatefulWidget {
  const ProfileVideos({super.key, required this.userId});
  final String userId;

  @override
  State<StatefulWidget> createState() => _ProfileVideosState();
}

class _ProfileVideosState extends State<ProfileVideos> with AutomaticKeepAliveClientMixin {
  late int totalPages=0;
  late int currentPage=1;

  late List items = [];
  late bool videoListLoadings=false;

  void getData() async {
    setState(() {
      videoListLoadings=true;
    });
    Map res=await getVideoList(
      page: currentPage-1,
      userId: widget.userId,
      sort: 'date'
    );
    setState(() {
      totalPages=(res["count"]/res["limit"]).ceil();
      items.clear();
      items.addAll(res["results"]);
      videoListLoadings=false;
    });
    // print(res);
  }

  @override
  void initState() {
    super.initState();
    getData();
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Recommend Page'),
      // ),
        body: Column(
          children: [
            Flexible(
                child: VideoList(items: items,loading: videoListLoadings,)
            ),
            Pager(currentPage: currentPage, pageChanged: (page){
              setState(() {
                print("page changed to $page");
                currentPage=page;
              });
              getData();
            }, totalPages: totalPages)
          ],
        )
    );
  }

  @override
  bool get wantKeepAlive => true;
}