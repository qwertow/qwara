import 'package:flutter/material.dart';

import '../../components/commentList.dart';
import '../../components/pager.dart';

class CommentPage extends StatefulWidget {
  const CommentPage({super.key,this.scrollController, this.scrollPhysics,required this.getComments});
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final Future<Map<String, dynamic>> Function(int) getComments;
  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> with AutomaticKeepAliveClientMixin {
  bool commentsLoading = false;
  List comments = [];
  int currentCommentPage = 1;
  int totalCommentPages =0;
  void _getComments(int page) async {
    setState(() {
      commentsLoading = true;
      print("commentsLoading set to true"); // Debugging output
    });

    final Map<String, dynamic> res = await widget.getComments(page);
    print("getVideoComments");
    print(res);
    setState(() {
      totalCommentPages =(res["count"]/res["limit"]).ceil();
      comments.clear();
      comments.addAll(res['results']);
      commentsLoading = false;
      print("commentsLoading: ${commentsLoading}");
    });

    return ;
  }
  void pageChanged(int page) {
    setState(() {
      currentCommentPage = page;
    });
    _getComments(currentCommentPage);
  }
  @override
  void initState() {
    super.initState();
    _getComments(1);
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        CommentList(commentItems: comments, loading: commentsLoading, scrollPhysics: widget.scrollPhysics, scrollController: widget.scrollController),
        Align(
          alignment: AlignmentDirectional.bottomCenter,
          child: Container(
            color: Colors.white,
            child: Pager(currentPage: currentCommentPage, pageChanged: pageChanged, totalPages:totalCommentPages),
          ),)

      ],
    );
  }


}