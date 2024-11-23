import 'package:flutter/material.dart';

class ListItem extends StatelessWidget{
  const ListItem({
        super.key,
        this.lead,
        this.trail,
        this.text,
        this.onItemTap
      });
  final Icon? lead;
  final Text? text;
  final Icon? trail;
  final Function? onItemTap;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              if (onItemTap != null) {
                onItemTap!();
              }
            },
            child: ListTile(
              leading: lead,
              title: text,
              trailing: trail,
            ),
          )
          ,
          const Divider()
        ],)
    );
  }

}