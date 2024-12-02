import 'package:flutter/material.dart';
import 'package:qwara/api/search/search.dart';
import 'package:qwara/components/UserList.dart';
import 'package:qwara/components/image/ImgList.dart';
import 'package:qwara/components/pager.dart';
import 'package:qwara/components/video/VideoList.dart';
import 'package:qwara/enum/Enum.dart';
import 'package:sizer/sizer.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late int totalPages=0;
  late int currentPage=1;
  bool _loading = false;
  Future<void> _pageChanged(int page) async {
    currentPage=page;
    await _search();
    setState(() {});
  }
  final List<Map<String, dynamic>> _results = [];
  SearchType _searchType = SearchType.video;
  SearchType _srvT=SearchType.nothing;
  Future<void> _search() async {
      setState(() {
        _srvT=_searchType;
        _loading = true;
      });
      Map<String, dynamic> res = await search(_searchController.text, _searchType.value, currentPage);
      setState(() {
        _results.clear();
        _results.addAll(res['results'].cast<Map<String, dynamic>>());
        totalPages=(res["count"]/res["limit"]).ceil();
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
          scrolledUnderElevation: 0.0,
        title: const Text('Search Page'),
      ),
      body: Column(
          children: [
            const SizedBox(height: 16.0),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Row(
                children: [
                  DropdownButton<SearchType>(
                    value: _searchType,
                    icon: const Icon(Icons.arrow_drop_down),
                    underline: const SizedBox(),
                    onChanged: (SearchType? newValue) {
                      // Handle change
                      setState(() {
                        _searchType = newValue!;
                      });
                    },
                    items: <SearchType>[SearchType.video, SearchType.image, SearchType.user]
                        .map<DropdownMenuItem<SearchType>>((SearchType value) {
                      return DropdownMenuItem<SearchType>(
                        value: value,
                        child: Text(value.label),
                      );
                    }).toList(),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _search();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: _buildSearchContent(_srvT,_results,_loading),
            ),
            Pager(currentPage: currentPage, pageChanged: _pageChanged, totalPages: totalPages)
          ],
        ),
    );
  }
  Widget _buildSearchContent(SearchType searchType,List<Map<String, dynamic>> i,bool l) {
    switch (searchType) {
      case SearchType.video:
        return VideoList(items: i, loading: l);
      case SearchType.image:
        return ImgList(items: i, loading: l);
      case SearchType.user:
        return UserList(items: i.map((e) => {'user':e}).toList(),  loading: l);
      default:
        return const Text('Search for something');
    }
  }
}