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

  final Map<String, dynamic> _userInfo = storeController.userInfo;

  @override
  Widget build(BuildContext context) {

    return Card(
      // margin: const EdgeInsets.only(bottom: 10),
      // elevation: 9,
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
                if(storeController.token== ""){
                  Get.toNamed('/login');
                }
              },
              child: CircleAvatar(
                radius: 40,
                backgroundImage:_userInfo['user'] == null? null : NetworkImage(
                    'https://i.iwara.tv/image/avatar/${_userInfo['user']?['avatar']['id'] }/${_userInfo['user']?['avatar']['name']}',
                    headers: {
                      'Referer':"https://www.iwara.tv/",
                      // 'Content-Type':'image/jpeg'
                    }
                ),
              ),
            ),
            title: Text(title!),
            subtitle: Text(subtitle!),
          ),
          const Divider(),
          ...?children
        ],
      ),
    );
  }

}