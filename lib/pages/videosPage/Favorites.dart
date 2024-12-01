import 'package:flutter/material.dart';
import 'package:qwara/api/video/video.dart';
import 'package:qwara/components/video/VideoList.dart';
import 'package:qwara/components/pager.dart';

import 'package:qwara/EventBus/EventBus.dart';
import 'package:qwara/components/exception/TimeoutPage.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}


class _FavoritesPageState extends State<FavoritesPage> {
  late int totalPages=0;
  late int currentPage=1;
  late bool videoListLoadings=false;
  bool timeout=false;

  // 假设有一些示例数据
  late List items = [];

  getData() async {
    setState(() {
      videoListLoadings=true;
    });
    Map res=await getFavoritesVideos(
      currentPage-1,
    );
    setState(() {
      totalPages=(res["count"]/res["limit"]).ceil();
      items.clear();
      items.addAll(res["results"].map((e)=> e["video"]).toList());
      videoListLoadings=false;
    });
    // print(res);
  }
  @override
  void initState() {
    super.initState();
    eventBus.on<TimeOutEvent>().listen((event) {
      setState(() {
        timeout=true;
      });
    });
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
        body: Column(
          children: [
            Flexible(
                child:!timeout? VideoList(items: items,loading:  videoListLoadings,)
                    :TimeoutPage(
                  onRetry: (){
                    setState(() {
                      timeout=false;
                    });
                    getData();
                  },
                )
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
}
