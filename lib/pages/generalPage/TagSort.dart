import 'package:flutter/material.dart';
import 'package:floating_tabbar/lib.dart';
import 'package:qwara/api/search/search.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:extended_wrap/extended_wrap.dart';

class FilterS{
  Set<String>? selectedTags; // 用于存储选中的标签
  String selectedLetter; // 用于存储选中的字母
  int? selectedYear; // 用于存储选中的年份
  int? selectedMonth; // 用于存储选中的月份

  FilterS({required this.selectedTags, this.selectedLetter='A', this.selectedYear, this.selectedMonth});

  String? get date => selectedYear == null ? null : '$selectedYear${selectedMonth != null ? '-$selectedMonth' : ''}';
}

class TagSort extends StatefulWidget {
  const TagSort({super.key, required this.onSelected, required this.iniFilterS});
  final FilterS iniFilterS; // 初始的筛选条件
  final Function(FilterS) onSelected; // 用于返回选中的标签、字母、年份、月份

  @override
  State<TagSort> createState() => _TagSortState();
}

class _TagSortState extends State<TagSort> {
  int currentYear = DateTime.now().year;
  List<int> years = List.generate(10, (index) => DateTime.now().year - index);
  List<int> months = List.generate(12, (index) => index + 1);
  FilterS filterS = FilterS(
    selectedLetter: 'A',
    selectedTags: {},
    selectedYear: null,
    selectedMonth: null,
  );

  bool filterExtended=false;
  bool tagLoading = true; // 用于控制标签列表的加载动画
  // final tags = <String>[
  //   // 假设这是从A-Z, 0-9筛选出的标签
  //   'c4d', 'calliope_mori', 'cameltoe', 'candace', 'car', 'cat_ears', 'cbt',
  //   'cecelia', 'ceres_fauna', 'ch4nge', 'charastudio'
  // ];
  int itemsPerPage = 1;
  int currentPage = 1;
  List filteredTags = List.generate(32, (index){
    return {'id': 'tag$index'};
  });
  int pageCount = 1;
  Future<void> _getFilteredTags() async{
    setState(() {tagLoading = true;});
    final res =await getFilteredTags(filterS.selectedLetter, currentPage);
    setState(() {
      filteredTags = res['results'];
      itemsPerPage = res['limit'];
      pageCount = (res['count'] / itemsPerPage).ceil();
      tagLoading = false;
    });
    return ;
  }


  @override
  void initState() {
    super.initState();
    // print('TagSort initState');
    filterS = widget.iniFilterS;
    _getFilteredTags();
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        const SizedBox(height: 10),
        Divider(
          indent: 30.w,
          endIndent: 30.w,
          thickness: 5,
        ),
        Flexible(child: TopTabBar(
            isScrollable: false,
            children: [
              TabItem(title: const Text('tag'), onTap: () {},
                  tab: _buildTagSelector()),
              TabItem(title: const Text('date'), onTap: () {},
                  tab: _buildDateSelector())
            ])
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: (){
              setState(() {
                filterS = FilterS(selectedLetter: 'A', selectedTags: {}, selectedYear: null, selectedMonth: null);
              });
            }, child: const Text('清空')),
            TextButton(onPressed: (){
              widget.onSelected(filterS);
              Navigator.pop(context);
            }, child: const Text('完成'))
          ],
        )
      ],
    );
  }

  Widget _buildTagSelector() {
    return  Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSize(duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: ExtendedWrap(
            overflowWidget: IconButton(onPressed: (){
              setState(() {
                filterExtended=!filterExtended;
              });
            }, icon: filterExtended?Icon(Icons.expand_less): Icon(Icons.arrow_drop_down_circle)),
            maxLines: filterExtended ? 100:2,
            spacing: 10.0,
            children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.split('').map((char) {
              return ChoiceChip(
                label: Text(char),
                selected: filterS.selectedLetter == char,
                onSelected: (bool selected) {
                  if (selected) {
                    setState(() {
                      filterS.selectedLetter = char;
                      _getFilteredTags();
                      // currentPage = 1; // 重置为第一页
                    });
                  }
                },
              );
            }).toList(),
          ),),
          // const SizedBox(height: 20),
          Expanded(
            child: Skeletonizer(
              enabled: tagLoading,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10.0, // 控制选项之间的间距
                    children: filteredTags.map((tag) {// 这里需要维护选中状态
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value:  filterS.selectedTags?.contains(tag['id']) ?? false , // 这里需要维护选中状态
                            onChanged: (bool? selected) {
                              print('选择了 $selected');

                              setState(() {
                                if (selected != null) {
                                  if (selected) {
                                    filterS.selectedTags?.add(tag['id']); // 添加到已选集合
                                  } else {
                                    filterS.selectedTags?.remove(tag['id']); // 从已选集合移除
                                  }
                                }
                              });
                              print('当前选择 ${filterS.selectedTags}');
                              print('当前选择 ${tag['id']}');
                              print('当前选择 ${filterS.selectedTags?.contains(tag['id'])}');
                            },
                          ),
                          Text(
                            tag['id'],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                )),
          ),

          // const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pageCount, (index) {
              return IconButton(
                icon: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: currentPage == index + 1 ? Colors.blue : Colors.black,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    currentPage = index + 1;
                    _getFilteredTags();
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return  Column(
      children: [
        // 年份部分
        const SizedBox(height: 20),
        const Text(
          '选择年份:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 10.0, // 控制选项之间的间距
          children: years.map((year) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<int>(
                  toggleable: true,
                  value: year,
                  groupValue: filterS.selectedYear,
                  onChanged: (value) {
                    setState(() {
                      filterS.selectedYear = value; // 更新选中的年份
                      if(filterS.selectedYear==DateTime.now().year){
                        setState(() {
                          months = List.generate(DateTime.now().month, (index) => index + 1);
                        });
                      }else{
                        setState(() {
                          months = List.generate(12, (index) => index + 1);
                        });
                      }
                    });
                  },
                ),
                Text(year.toString()),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        // 月份部分
        const Text(
          '选择月份:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 10.0, // 控制选项之间的间距
          children: months.map((month) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<int>(
                  toggleable: true,
                  value: month,
                  groupValue: filterS.selectedMonth,
                  onChanged: (value) {
                    setState(() {
                      filterS.selectedMonth = value; // 更新选中的月份
                    });
                  },
                ),
                Text(month.toString()),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}