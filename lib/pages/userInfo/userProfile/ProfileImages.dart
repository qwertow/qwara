import 'package:flutter/material.dart';
import 'package:qwara/api/img/img.dart';
import 'package:qwara/components/image/ImgList.dart';

import '../../../components/pager.dart';

class ProfileImages extends StatefulWidget {
  const ProfileImages({super.key, required this.userId});
  final String userId;
  @override
  State<StatefulWidget> createState() => _ProfileImagesState();
}

class _ProfileImagesState extends State<ProfileImages> with AutomaticKeepAliveClientMixin {
  late int totalPages=0;
  late int currentPage=1;

  late bool videoListLoadings=false;

  // 假设有一些示例数据
  late List items = [];

  getData() async {
    setState(() {
      videoListLoadings=true;
    });
    Map res=await getImgList(
        page: currentPage-1,
        userId: widget.userId,
        sort: 'date',
        rating: "all"
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
  // 保持页面状态
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
          children: [
            Flexible(
                child: ImgList(items: items,loading:  videoListLoadings,)
            ),
            Pager(currentPage: currentPage, pageChanged: (page){
              setState(() {
                print("page changed to $page");
                currentPage=page;
              });
              getData();
            }, totalPages: totalPages)
          ],
        );
  }
}
