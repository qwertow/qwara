import 'package:flutter/material.dart';
import 'package:qwara/api/video/video.dart';
import 'package:qwara/components/Mydropdown.dart';
import 'package:qwara/components/video/VideoList.dart';
import 'package:qwara/components/pager.dart';
import 'package:qwara/enum/Enum.dart';
import 'package:qwara/EventBus/EventBus.dart';
import 'package:qwara/components/exception/TimeoutPage.dart';
import 'package:qwara/pages/generalPage/TagSort.dart';
import 'package:sizer/sizer.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key, this.iniSortTag});
  final String? iniSortTag;

  @override
  State<VideosPage> createState() => _VideosPageState();
}


class _VideosPageState extends State<VideosPage> with AutomaticKeepAliveClientMixin {
  bool _isDark = false;
  late int totalPages=0;
  late int currentPage=1;
  late SortType _sortType=SortType.date;
  late bool videoListLoadings=false;
  late  FilterS _filterS = FilterS(
    selectedTags: {},
  );

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
       tags: _filterS.selectedTags,
       date:_filterS.date,
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
    if(widget.iniSortTag!=null){
      _filterS.selectedTags?.add(widget.iniSortTag!);
    }

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

  @override
  Widget build(BuildContext context) {
    _isDark = Theme.of(context).brightness == Brightness.dark;
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
            leading: Row(
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
                          Icon(_getIconForSortType(sortType)),
                          const SizedBox(width: 8),
                          Text(sortType.label),
                        ],
                      ),
                    );
                  }).toList(),
                  underline: Container(), // 隐藏下划线
                  style: TextStyle(color: _isDark? Colors.white : Colors.black), // 字体颜色

                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.tag),
                      onPressed: () {
                        // 点击事件
                        _showModalBottomSheet(context);
                      },
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Visibility(
                        visible: _filterS.selectedTags?.isNotEmpty ?? false,
                          child: Container(
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            '${_filterS.selectedTags?.length}',  // 显示的数字
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )),
                    ),
                  ],
                )
              ],
            ),
          ),

        ],
      )
    );
  }
  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 允许底部弹窗根据内容调整高度
      builder: (BuildContext context) {
        return SizedBox(
          height: 70.h,
          child: TagSort(onSelected: (filters){
            setState(() {
              _filterS=filters;
            });
            getData();
          }, iniFilterS: _filterS,),
        );
      },
    );
  }
}


