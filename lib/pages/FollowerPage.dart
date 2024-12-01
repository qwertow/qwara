import 'package:flutter/cupertino.dart';
import 'package:floating_tabbar/lib.dart';
import 'package:qwara/api/subscribe/follow.dart';
import 'package:qwara/pages/generalPage/UserListPage.dart';
import 'package:qwara/getX/StoreController.dart';

class FollowerPage extends StatelessWidget {
  final Map<String,dynamic> currUser=storeController.userInfo ?? {};
  FollowerPage({super.key,this.index=0});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('follower'),
      ),
      body: TopTabBar(
          isScrollable: false,
          initialIndex: index,
          children: [
            TabItem(title: const Text('关注'), onTap: () {},
                tab:UserListPage(getUsers: (page)async {
                  return getFollowing(currUser['user']['id'],page: page);
                })),
            TabItem(title: const Text('粉丝'), onTap: () {},
                tab: UserListPage(getUsers: (page)async {
                  return getFollowers(currUser['user']['id'],page: page);
                })),
            TabItem(title: const Text('好友'), onTap: () {},
                tab: UserListPage(getUsers: (page)async {
                  return getFriends(currUser['user']['id'],page: page);
                })),
          ]),
    );
  }
}