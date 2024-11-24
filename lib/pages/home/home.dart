import 'package:flutter/material.dart';
import 'package:qwara/api/video/video.dart';
import 'package:qwara/components/VideoList.dart';
import 'package:qwara/api/user/user.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  late int totalPages=20;
  late int currentPage=1;
  // 假设有一些示例数据
  late List items = [];
  late bool videoListLoadings=false;

  getData() async {
    if(storeController.token==""){
      return;
    }
    setState(() {
      videoListLoadings=true;
    });
    await getUserInfo();
    Map res=await getSubscribedVideos(
      page: currentPage-1,
    );
    setState(() {
      totalPages=(res["count"]/res["limit"]).ceil();
      items.clear();
      items.addAll(res["results"]);
      videoListLoadings=false;
    });
    // print(res);
  }

  pageChanged(int page) {
    getData();
  }

  @override
  void initState() {
    super.initState();

    getData();
  }

  @override
  // 保持页面状态
  bool get wantKeepAlive => true;

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
              setState(() {
                currentPage=int.parse(text);
              });
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
    super.build(context); // 不能忘记调用 super.build() 来保持状态
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Recommend Page'),
      // ),
        body: Column(
          children: [
            Flexible(
                child: VideoList(items: items,loading: videoListLoadings,)
            ),
            Row(
              children: [
                Expanded(
                    child: InkWell(
                      onTap: () {
                        showDialogFunction(context);
                      },
                      child: Container(
                        // color: Colors.amberAccent,
                        alignment:  Alignment.center,
                        height: 40,
                        margin: const EdgeInsets.only(left: 20),
                        child: Text("Page $currentPage of $totalPages",
                          textAlign: TextAlign.center,),
                      ),
                    )),
                Row(
                  children: [
                    IconButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              currentPage>1?Colors.blue:Colors.grey,
                            )
                        ),
                        onPressed: (){
                          if(currentPage>1){
                            setState(() {
                              currentPage--;
                            });
                            pageChanged(currentPage);
                          }
                        },
                        icon: const Icon(Icons.keyboard_arrow_left)
                    ),
                    IconButton(
                        enableFeedback: currentPage==totalPages,
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              currentPage<totalPages?Colors.blue:Colors.grey,
                            )
                        ),
                        onPressed: (){
                          if(currentPage<totalPages){
                            setState(() {
                              currentPage++;
                            });
                            pageChanged(currentPage);
                          }
                        },
                        icon: const Icon(Icons.keyboard_arrow_right)
                    ),
                    const SizedBox(width: 20)
                  ],
                )
              ],
            )
          ],
        )
    );
  }
}
