import 'package:flutter/material.dart';
import 'package:qwara/components/ListItem.dart';
import 'package:qwara/components/MyCard.dart';
import 'package:get/get.dart' hide Response;


class DrawerView extends StatefulWidget {
  const DrawerView({super.key,this.url});
  final String? url;
  @override
  State<DrawerView> createState() => _DrawerView();
}

class _DrawerView extends State<DrawerView> {


  @override
  Widget build(BuildContext context) {
    return ListView(
      children:  [
        const MyCard(),
        // const SizedBox(height: 10),
        ListItem(
          lead: const Icon(Icons.favorite_border),
          text: const Text("最爱"),
          onItemTap: (){
            Get.toNamed('/favorites');
          },
        ),
        ListItem(
          lead: const Icon(Icons.video_library_outlined),
          text: const Text("播单"),
          onItemTap:(){
            Get.toNamed('/toPlaylist');
          },
        ),
        const ListItem(
          lead: Icon(Icons.download_outlined),
          text: Text("下载"),
        ),
        const ListItem(
          lead: Icon(Icons.history_outlined),
          text: Text("历史"),
        ),
        ListItem(
          lead: const Icon(Icons.settings_outlined),
          text: const Text("设置"),
          onItemTap: () {
            Get.toNamed('/settings');
          },
        ),
        // TextButton(onPressed: () async {
        //   if (await getAccessToken()){
        //     Get.snackbar("提示", "更新AccessToken成功");
        //     eventBus.fire(UpdateAccessTokenEvent(true));
        //   }else{
        //     Get.snackbar("提示", "更新AccessToken失败,请重新登录");
        //   }
        // }, child: const Text("更新AccessToken")),
        // TextButton(onPressed: (){
        //   logout();
        // }, child: const Text("退出登录 fake")),
        // TextButton(onPressed: () {
        //   Fluttertoast.showToast(msg: "show toast test");
        // }, child: const Text("show toast test"))
      ],
    );
  }

}
