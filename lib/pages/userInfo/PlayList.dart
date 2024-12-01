import 'package:flutter/material.dart';
import 'package:qwara/api/subscribe/playList.dart';
import 'package:qwara/components/MyCard.dart';
import 'package:qwara/components/PlayLists.dart';

import '../../components/pager.dart';

class PlayListPage extends StatefulWidget {
  const PlayListPage({super.key});
  @override
  State<PlayListPage> createState() => _PlayListPageState();
}

class _PlayListPageState extends State<PlayListPage> with AutomaticKeepAliveClientMixin {
  bool loading = false;
  List lists = [];
  int currentPage = 1;
  int totalPages =0;
  Map<String, dynamic> currUer=storeController.userInfo ?? {};

  void _getLists(int page) async {
    setState(() {
      loading = true;
    });

    final Map<String, dynamic> res = await getPlayLists(currUer['user']['id'], page);
    print(res);
    setState(() {
      totalPages =(res["count"]/res["limit"]).ceil();
      lists.clear();
      lists.addAll(res['results']);
      loading = false;
    });

    return ;
  }
  void pageChanged(int page) {
    setState(() {
      currentPage = page;
    });
    _getLists(currentPage);
  }
  @override
  void initState() {
    super.initState();
    _getLists(1);
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Playlists"),
      ),
      body: Column(
        children: [
          Flexible(child: PlayLists(items: lists, loading: loading)),
          Pager(currentPage: currentPage, pageChanged: pageChanged, totalPages:totalPages),
        ],
      ),
    );
  }


}