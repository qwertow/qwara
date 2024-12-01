import 'package:flutter/material.dart';
import 'package:qwara/api/video/video.dart';
import 'package:qwara/components/Mydropdown.dart';
import 'package:qwara/components/video/VideoList.dart';
import 'package:qwara/components/pager.dart';

import 'package:qwara/enum/Enum.dart';

import 'package:qwara/EventBus/EventBus.dart';
import 'package:qwara/components/exception/TimeoutPage.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}


class _VideosPageState extends State<VideosPage> with AutomaticKeepAliveClientMixin {
  late int totalPages=0;
  late int currentPage=1;
  late SortType _sortType=SortType.date;
  late bool videoListLoadings=false;
  bool timeout=false;

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

  final List<String> categories = ['电影', '综艺', '动漫', '少儿'];
  // final List<String> genres = ['古装', '都市', '言情', '武侠', '战争', '青春'];
  // final List<String> regions = ['内地', '美国', '韩国', '香港', '台湾', '日本'];
  final List<String> years = ['2024', '2023', '2022', '2021', '2020', '2019'];
  @override
  Widget build(BuildContext context) {
    super.build(context);
    const sortTypes = SortType.values;
    return Scaffold(
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
          }, totalPages: totalPages,
          leading: MyDropdownButton<String>(
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
          ),),

        ],
      ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.transparent,
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            }, child: const Icon(Icons.tag)
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      // floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }
}

