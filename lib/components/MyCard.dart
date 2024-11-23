import 'package:flutter/material.dart';

class MyCard extends StatelessWidget{
  const MyCard({
    super.key,
    this.title,
    this.subtitle,
    this.children
  });

  final String? title;
  final String? subtitle;
  final List<Widget>? children;

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
            leading: const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage("https://www.itying.com/images/flutter/1.png"),
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