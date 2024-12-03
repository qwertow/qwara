import 'package:flutter/material.dart';

import '../../components/commentList.dart';
import '../../components/pager.dart';

class CommentPage extends StatefulWidget {
  const CommentPage({super.key,this.scrollController, this.scrollPhysics,required this.getComments, required this.addComment});
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final Future<Map<String, dynamic>> Function(int) getComments;
  final Future<void> Function(String comment,{String? rpId}) addComment;
  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> with AutomaticKeepAliveClientMixin,TickerProviderStateMixin {
  bool commentsLoading = false;
  List comments = [];
  int currentCommentPage = 1;
  int totalCommentPages =0;
  String? rpId;
  String? rpName;
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
      print("commentsLoading: $commentsLoading");
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

  double? rpWidth = 0;
  double? pageWidth = null;
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Flexible(child: CommentList(
            commentItems: comments,
            loading: commentsLoading,
            scrollPhysics: widget.scrollPhysics,
            scrollController: widget.scrollController,
            rpF:(id,name){
              setState(() {
                rpId = id;
                rpName = name;
                rpWidth = null;
                pageWidth=0;
              });
            },
            delF: (success)async{
              setState(() {
                commentsLoading = true;
              });
              await success;
              _getComments(currentCommentPage);
            },
        )),
        Visibility(visible: rpId!= null, child: Text("Reply to $rpName",style: const TextStyle(color: Colors.black,fontSize: 16))),
        Wrap(
          direction: Axis.horizontal,
          children: [
            AnimatedSize(duration: const Duration(milliseconds: 300),child:replyComment(rpWidth)),
            AnimatedSize(duration: const Duration(milliseconds: 300),child: SizedBox(
              width: pageWidth,
              // height: 50,
              // color: Colors.red,
              child: Pager(currentPage: currentCommentPage, pageChanged: pageChanged, totalPages:totalCommentPages,
                leading: IconButton(onPressed: (){
                  setState(() {
                    rpWidth = null;
                    pageWidth=0;
                  });
                }, icon:const Icon(Icons.message_outlined,color: Colors.black),style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.amberAccent),
                ),),),
            ),)
          ],
        )
      ],
    );
  }
  Widget replyComment(double? rpW) {
    TextEditingController _controller = TextEditingController();
    return SizedBox(
      // color: Colors.red,
      height: rpW,
      width: rpW,
      child: Row(
        children: [
          IconButton(onPressed: (){
            setState(() {
              rpWidth = 0;
              pageWidth = null;
              rpId = null;
              rpName = null;
            });
          }, icon:const Icon(Icons.close,color: Colors.black),style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.amberAccent),
          ),),
          Expanded(child: TextField(
            minLines: 1,
            maxLines: 10,
            controller: _controller,
          )),
          IconButton(onPressed: () async {
            print(_controller.text);
            setState(() {
              commentsLoading = true;
              currentCommentPage = totalCommentPages;
            });
            await widget.addComment(_controller.text,rpId: rpId);
            _getComments(currentCommentPage);
          }, icon:const Icon(Icons.send,color: Colors.black),style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.amberAccent),
          ),),
        ],
      ),
    );
  }

}