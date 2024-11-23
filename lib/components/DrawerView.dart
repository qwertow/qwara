import 'package:flutter/material.dart';
import 'package:qwara/components/ListItem.dart';
import 'package:qwara/components/MyCard.dart';

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
      children: const [
        MyCard(
          title: "qwara",
          subtitle: "@12123",
          children: [
            Row(
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
            )
          ],
        ),
        // const SizedBox(height: 10),
        ListItem(
          lead: Icon(Icons.favorite_border),
          text: Text("最爱"),
        ),
        ListItem(
          lead: Icon(Icons.video_library_outlined),
          text: Text("播单"),
        ),
        ListItem(
          lead: Icon(Icons.download_outlined),
          text: Text("下载"),
        ),
        ListItem(
          lead: Icon(Icons.history_outlined),
          text: Text("历史"),
        ),
        ListItem(
          lead: Icon(Icons.settings_outlined),
          text: Text("设置"),
        )
      ],
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