import 'package:flutter/material.dart';
import 'package:qwara/api/subscribe/follow.dart';
import 'package:qwara/constant.dart';
import 'package:qwara/getX/StoreController.dart';
import 'package:get/get.dart' hide Response;


class MyCard extends StatefulWidget {
  const MyCard({
    super.key,
    this.title,
    this.subtitle,
    this.children,
  });

  final String? title;
  final String? subtitle;
  final List<Widget>? children;

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  final Map<String, dynamic> _userInfo = storeController.userInfo ?? {};

  String _userId = '';

  Map _follower = {};
  Map _following = {};
  Map _friends = {};

  @override
  void initState() {
    super.initState();
    _userId = _userInfo['user']?['id'] ?? '';
    _getFollow();
  }

  @override
  dispose() {
    super.dispose();
  }

  Future<void> _getFollow() async {
    _following=storeController.following ?? await getFollowing(_userId,limit: 6);
    _friends= storeController.friends ?? await getFriends(_userId);
    setState(() {});
    _follower=await getFollowers(_userId,limit: 6);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      // color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: InkWell(
              onTap: () {
                if (storeController.token == null) {
                  Get.toNamed('/login');
                } else {
                  Get.toNamed('/userProfile', arguments: _userInfo['user'] ?? {});
                }
              },
              child: CircleAvatar(
                radius: 40,
                child: ClipOval(
                  child: Image.network(
                    'https://i.iwara.tv/image/avatar/${_userInfo['user']?['avatar']['id']}/${_userInfo['user']?['avatar']['name']}',
                    headers: IMG_HEADERS,
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                      // 显示默认图片，并确保是圆形
                      return Image.asset(
                        'assets/images/default-avatar.jpg',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
            ),
            title: Text(_userInfo['user']?['name'] ?? '未登录'),
            subtitle: Text("@${_userInfo['user']?['username'] ?? '未登录'}"),
          ),
          const Divider(),
          Container(
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: InfoCard(
                    name: "关注",
                    num: _following['count']?? 0,
                    onTapFunction: (){
                      Get.toNamed('/followPage',arguments: 0);
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InfoCard(
                    name: "粉丝",
                    num: _follower['count']?? 0,
                    onTapFunction: (){
                      Get.toNamed('/followPage',arguments: 1);
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InfoCard(
                    name: "好友",
                    num: _friends['count']?? 0,
                    onTapFunction: (){
                      Get.toNamed('/followPage',arguments: 2);
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

}


class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    this.num=0,
    this.name='null', this.onTapFunction,
  });
  final int? num;
  final String? name;
  final Function()? onTapFunction;
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: const Color(0xCDBCBCFF),
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.only(left: 2,right: 2),
        // height: 50,
        child: InkWell(
          onTap: onTapFunction,
          child: ListTile(
            title: Text(num.toString()),
            subtitle: Text(name as String),
          ),
        )
    );
  }
}