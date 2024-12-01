import 'package:flutter/material.dart';
import 'package:qwara/components/UserList.dart';

import '../../components/pager.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key, required this.getUsers});
  final Future<Map<String, dynamic>> Function(int) getUsers;
  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> with AutomaticKeepAliveClientMixin {
  bool loading = false;
  List users = [];
  int currentPage = 1;
  int totalPages =0;

  void _getUsers(int page) async {
    setState(() {
      loading = true;
      print("commentsLoading set to true"); // Debugging output
    });

    final Map<String, dynamic> res = await widget.getUsers(page);
    print("getVideoComments");
    print(res);
    setState(() {
      totalPages =(res["count"]/res["limit"]).ceil();
      users.clear();
      users.addAll(res['results']);
      loading = false;
    });

    return ;
  }
  void pageChanged(int page) {
    setState(() {
      currentPage = page;
    });
    _getUsers(currentPage);
  }
  @override
  void initState() {
    super.initState();
    _getUsers(1);
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Flexible(child: UserList(items: users, loading: loading)),
        Pager(currentPage: currentPage, pageChanged: pageChanged, totalPages:totalPages),
      ],
    );
  }


}