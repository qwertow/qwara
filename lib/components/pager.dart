import 'package:flutter/material.dart';

class Pager extends StatelessWidget {


  const Pager({super.key, required this.currentPage, required this.pageChanged, required this.totalPages, this.leading});
  final int currentPage;
  final Function(int) pageChanged;
  final int totalPages;
  final Widget? leading;
  /// showDialog
  showDialogFunction(context) {
    late String text="";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("转到："),
          content: TextField(
            onChanged: (String valuetext){
              text=valuetext;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("取消"),
            ),
            TextButton(onPressed: () {
              if(int.parse(text)<1){

                text="1";
              }
              if(int.parse(text)>totalPages){
                text=totalPages.toString();
              }

              pageChanged(int.parse(text));
              Navigator.of(context).pop();
            }, child: const Text("确定")),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leading!= null) leading!,
        Expanded(
            child: InkWell(
              onTap: () {
                showDialogFunction(context);
              },
              child: Container(
                // color: Colors.amberAccent,
                alignment:  Alignment.center,
                height: 40,
                // margin: const EdgeInsets.only(left: 20),
                child: Text("Page $currentPage of $totalPages",
                  textAlign: TextAlign.center,),
              ),
            )),
        Row(
          children: [
            IconButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      currentPage>1?Colors.blue[400]:Colors.grey[400],
                    )
                ),
                onPressed: (){
                  if(currentPage>1){
                    pageChanged(currentPage-1);
                  }
                },
                icon: const Icon(Icons.keyboard_arrow_left)
            ),
            IconButton(
                enableFeedback: currentPage==totalPages,
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      currentPage<totalPages?Colors.blue[400]:Colors.grey,
                    )
                ),
                onPressed: (){

                  if(currentPage<totalPages){
                    pageChanged(currentPage+1);
                  }
                },
                icon: const Icon(Icons.keyboard_arrow_right)
            ),
            // const SizedBox(width: 20)
          ],
        )
      ],
    );
  }
}