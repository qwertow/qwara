import 'package:flutter/material.dart';
import 'package:qwara/api/img/img.dart';
import 'package:qwara/components/image/ImgList.dart';
import '../../components/Mydropdown.dart';
import '../../components/pager.dart';
import '../../enum/Enum.dart';
class ImagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> with AutomaticKeepAliveClientMixin {
  late int totalPages=0;
  late int currentPage=1;
  late SortType _sortType=SortType.date;
  late bool videoListLoadings=false;

  // 假设有一些示例数据
  late List items = [];

  getData() async {
    setState(() {
      videoListLoadings=true;
    });
    Map res=await getImgList(
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
    super.build(context);
    const sortTypes = SortType.values;
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Recommend Page'),
      // ),
        body: Column(
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
              ),)
          ],
        )
    );
  }
}
