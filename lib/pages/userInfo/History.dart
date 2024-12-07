import 'package:flutter/material.dart';
import 'package:qwara/components/video/VideoList.dart';
import 'package:qwara/getX/StoreController.dart';
import 'package:qwara/utils/TimeUtil.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  bool loading = false;
  List<HistoryVideo> items = [];
  @override
  void initState() {
    super.initState();
    getHistory();
  }
  getHistory() async {
    setState(() {
      loading = true;
    });
    await storeController.setHistoryVideos();
    print(storeController.historyVideos);
    setState(() {
      items = storeController.historyVideos.reversed.toList();
      // print(items);
      loading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VideoList(items: items.map((item) => item.historyVInfo).toList(),
          loading: loading,
        customBottomChild: (context,index){
          if(items.isEmpty){
            return null;
          }
          return Text("  ${formatDate(items[index].viewTime.toString())}");
        }
      ),
    );
  }
}