import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class Comment extends StatefulWidget {
  const Comment({super.key, this.scrollPhysics, this.scrollController});
  final ScrollPhysics? scrollPhysics;
  final ScrollController? scrollController;

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> with AutomaticKeepAliveClientMixin{
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Container(
      // height: 200,
      margin: getValueForScreenType(
          context: context,
          mobile: isPortrait ?EdgeInsets.zero :EdgeInsets.only(top: MediaQuery.of(context).padding.top,left: 5.0),
          tablet: EdgeInsets.only(top: MediaQuery.of(context).padding.top,left: 5.0)
      ),
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Column(
        children: [
          const Text(
            '评论区',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView(
              physics: widget.scrollPhysics,
              controller: widget.scrollController,
              children: const [
                ListTile(title: Text('评论1')),
                ListTile(title: Text('评论2')),
                ListTile(title: Text('评论3')),
                ListTile(title: Text('评论1')),
                ListTile(title: Text('评论2')),
                ListTile(title: Text('评论3')),
                ListTile(title: Text('评论1')),
                ListTile(title: Text('评论2')),
                ListTile(title: Text('评论3')),
                ListTile(title: Text('评论1')),
                ListTile(title: Text('评论2')),
                ListTile(title: Text('评论3')),
                ListTile(title: Text('评论1')),
                ListTile(title: Text('评论2')),
                ListTile(title: Text('评论3')),
                ListTile(title: Text('评论1')),
                ListTile(title: Text('评论2')),
                ListTile(title: Text('评论3')),
                ListTile(title: Text('评论1')),
                ListTile(title: Text('评论2')),
                ListTile(title: Text('评论3')),
                ListTile(title: Text('评论1')),
                ListTile(title: Text('评论2')),
                ListTile(title: Text('评论3')),
                ListTile(title: Text('评论1')),
                ListTile(title: Text('评论2')),
                ListTile(title: Text('评论3')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}