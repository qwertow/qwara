import 'package:flutter/material.dart';
import 'package:qwara/api/subscribe/playList.dart';
import 'package:qwara/components/video/VideoList.dart';
import 'package:qwara/components/pager.dart';
import 'package:qwara/EventBus/EventBus.dart';
import 'package:qwara/components/exception/TimeoutPage.dart';

class PlayListDetail extends StatefulWidget {
  const PlayListDetail({super.key, required this.playlist});
  final Map playlist;

  @override
  State<PlayListDetail> createState() => _PlayListDetailState();
}


class _PlayListDetailState extends State<PlayListDetail> {
  late int totalPages=0;
  late int currentPage=1;
  late bool _listLoading=false;
  bool timeout=false;

  // 假设有一些示例数据
  late List items = [];

  getData() async {
    setState(() {
      _listLoading=true;
    });
    Map res=await getPlayListByListId(
        widget.playlist["id"],
      currentPage-1,
    );
    setState(() {
      totalPages=(res["count"]/res["limit"]).ceil();
      items.clear();
      items.addAll(res["results"]);
      _listLoading=false;
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
        title: Text(widget.playlist["title"]),
      ),
        body: Column(
          children: [
            Flexible(
                child:!timeout? VideoList(items: items,loading:  _listLoading,)
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
