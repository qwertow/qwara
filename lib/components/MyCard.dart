import 'package:flutter/material.dart';
import 'package:qwara/getX/StoreController.dart';
import 'package:get/get.dart' hide Response;

final storeController = Get.find<StoreController>();

class MyCard extends StatelessWidget{
  MyCard({
    super.key,
    this.title,
    this.subtitle,
    this.children
  });

  final String? title;
  final String? subtitle;
  final List<Widget>? children;

  final Map<String, dynamic> _userInfo = storeController.userInfo ?? {};

  @override
  Widget build(BuildContext context) {

    return Card(
      color: Colors.white,
      // shadowColor: Colors.blueGrey,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: InkWell(
              onTap: (){
                if(storeController.token== null){
                  Get.toNamed('/login');
                }else{
                  Get.toNamed('/userProfile',arguments: _userInfo['user'] ?? {});
                }
              },
              child: CircleAvatar(
                radius: 40,
                child: ClipOval(
                  child: Image.network(
                    'https://i.iwara.tv/image/avatar/${_userInfo['user']?['avatar']['id'] }/${_userInfo['user']?['avatar']['name']}',
                    headers: const {
                      'Referer': "https://www.iwara.tv/",
                    },
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
            subtitle: Text("@${_userInfo['user']?['name'] ?? '未登录'}"),
          ),
          const Divider(),
          Container(
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: InfoCard(
                    name: "粉丝",
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InfoCard(
                    name: "关注",
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InfoCard(
                    name: "好友",
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
    this.name='null',
    this.onItemTap,
  });
  final int? num;
  final String? name;
  final Function? onItemTap;
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
          onTap: () {
            if (onItemTap != null) {
              onItemTap!();
            }
          },
          child: ListTile(
            title: Text(num.toString()),
            subtitle: Text(name as String),
          ),
        )
    );
  }
}