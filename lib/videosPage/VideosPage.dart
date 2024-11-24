import 'package:flutter/material.dart';
import 'package:qwara/api/video/video.dart';
import 'package:qwara/components/Mydropdown.dart';
import 'package:qwara/components/VideoList.dart';

import 'package:qwara/enum/Enum.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}


class _VideosPageState extends State<VideosPage> with AutomaticKeepAliveClientMixin {
  late int totalPages=20;
  late int currentPage=1;
  late SortType _sortType=SortType.date;
  late bool videoListLoadings=false;

  // 假设有一些示例数据
  late List items = [];

  getData() async {
    setState(() {
      videoListLoadings=true;
    });
     Map res=await getVideoList(
      sort: _sortType.value,
      page: currentPage-1,
    );
     setState(() {
       totalPages=(res["count"]/res["limit"]).ceil();
       items.clear();
       items.addAll(res["results"]);
       videoListLoadings=false;
     });
     // print(res);
  }
  sortChanged(SortType sortType) {
    print(sortType.value);
    setState(() {
      _sortType=sortType;
    });
    getData();
  }

  pageChanged(int page) {
    getData();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }
  IconData _getIconForSortType(SortType sortType) {
    switch (sortType) {
      case SortType.date:
        return Icons.date_range;
      case SortType.popularity:
        return Icons.local_fire_department;
      case SortType.trending:
        return Icons.trending_up;
      case SortType.view:
        return Icons.remove_red_eye;
      case SortType.like:
        return Icons.favorite;
      default:
        return Icons.help; // 默认图标
    }
  }
  @override
  // 保持页面状态
  bool get wantKeepAlive => true;

  /// showDialog
  showDialogFunction(context) {
    late String text="";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("转到："),
          content: TextField(
            onChanged: (String valuetext){
              text=valuetext;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("取消"),
            ),
            TextButton(onPressed: () {
              if(int.parse(text)<1){

                text="1";
              }
              if(int.parse(text)>totalPages){
                text=totalPages.toString();
              }
              setState(() {
                currentPage=int.parse(text);
              });
              pageChanged(int.parse(text));
              Navigator.of(context).pop();
            }, child: const Text("确定")),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    const sortTypes = SortType.values;
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Recommend Page'),
      // ),
      body: Column(
        children: [
          Flexible(
            child: VideoList(items: items,loading:  videoListLoadings,)
          ),
          Row(
            children: [

              MyDropdownButton<String>(
                icon: const Icon(Icons.sort),
                value: _sortType.value, // 使用当前排序类型
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    sortChanged(SortType.values.firstWhere((element) => element.value == newValue));
                  }
                },
                items: sortTypes.map((sortType) {
                  return MyDropdownMenuItem<String>(
                    value: sortType.value,
                    child: Row(
                      children: [
                        Icon(_getIconForSortType(sortType), color: Colors.black),
                        const SizedBox(width: 8),
                        Text(sortType.label, style: const TextStyle(color: Colors.black)),
                      ],
                    ),
                  );
                }).toList(),
                dropdownColor: Colors.white, // 设置下拉菜单的背景颜色
                // iconEnabledColor: Colors.blue, // 下拉箭头的颜色
                underline: Container(), // 隐藏下划线
                style: const TextStyle(color: Colors.black), // 字体颜色
              ),


              Expanded(
                  child: InkWell(
                    onTap: () {
                      showDialogFunction(context);
                    },
                    child: Container(
                      // color: Colors.amberAccent,
                      alignment:  Alignment.center,
                      height: 40,
                      margin: const EdgeInsets.only(left: 20),
                      child: Text("Page $currentPage of $totalPages",
                        textAlign: TextAlign.center,),
                    ),
                  )),
              Row(
                children: [
                  IconButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            currentPage>1?Colors.blue:Colors.grey,
                          )
                      ),
                      onPressed: (){
                        if(currentPage>1){
                          setState(() {
                            currentPage--;
                          });
                          pageChanged(currentPage);
                        }
                      },
                      icon: const Icon(Icons.keyboard_arrow_left)
                  ),
                  IconButton(
                      enableFeedback: currentPage==totalPages,
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            currentPage<totalPages?Colors.blue:Colors.grey,
                          )
                      ),
                      onPressed: (){
                        if(currentPage<totalPages){
                          setState(() {
                            currentPage++;
                          });
                          pageChanged(currentPage);
                        }
                      },
                      icon: const Icon(Icons.keyboard_arrow_right)
                  ),
                  const SizedBox(width: 20)
                ],
              )
            ],
          )
        ],
      )
    );
  }
}
