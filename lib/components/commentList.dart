import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:qwara/api/comment/comment.dart';
import 'package:qwara/getX/StoreController.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:get/get.dart' hide Response;

class CommentList extends StatelessWidget {
    CommentList({
     super.key,
     this.scrollPhysics,
     this.scrollController,
     required this.commentItems,
     required this.loading, this.rpF, this.delF});
  final ScrollPhysics? scrollPhysics;
  final ScrollController? scrollController;
  final List commentItems;
  final bool loading;
  final void Function(String id,String name)? rpF;
  final void Function(Future<bool>)? delF;
  final Map currUser=storeController.userInfo?['user'] ?? {};
  // @override
  // bool get wantKeepAlive => true;
   String formatDate(String dateString) {
     DateTime dateTime = DateTime.parse(dateString); // 将日期字符串解析为 DateTime 对象
     return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime); // 格式化日期
   }

  @override
  Widget build(BuildContext context) {
    final List _items = loading ? List.generate(10, (index) => {
      'user': {"name": BoneMock.name,"username": BoneMock.fullName,"avatar": null,
        "body": '123',"updatedAt": BoneMock.time}}
    ) : commentItems;

    return Skeletonizer(
      enabled: loading,
      child: ListView.builder(
        controller: scrollController,
        physics: scrollPhysics,
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final comment = _items[index];
          print(currUser['id']);
          print(comment['user']['id']);
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  trailing:currUser['id'] == comment['user']['id'] ? TextButton(onPressed: () async {
                    // Map temp = {...(comment as Map)};
                    // _items.removeAt(index);
                    // if(!await deleteComment(comment['id'])){
                    //   _items.insert(index, temp);
                    // };
                    delF?.call(deleteComment(comment['id']));
                  }, child: const Text('删除', style: TextStyle(color: Colors.red))): null,
                  leading: InkWell(
                    onTap: () {
                      Get.toNamed('/userProfile', arguments: comment['user']);
                    },
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 20,
                        child: ClipOval(
                          child: Skeleton.replace(child: Image.network(
                            'https://i.iwara.tv/image/avatar/${comment['user']?['avatar']?['id'] }/${comment['user']?['avatar']?['name']}',
                            headers: const {
                              'Referer': "https://www.iwara.tv/",
                            },
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                              // 显示默认图片，并确保是圆形
                              return Image.asset(
                                'assets/images/default-avatar.jpg',
                                fit: BoxFit.cover,
                              );
                            },
                          )),
                        ),
                      ),
                    ),
                  ),
                  title: Text(comment['user']['name']!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                  subtitle: Text(
                    "@${comment['user']['username']!}",
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ),
                Padding(padding: const EdgeInsets.only(left: 16,right: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const SizedBox(height: 8),
                      Text(comment['body'] ?? ''),
                      // const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatDate(comment['updatedAt'] ?? '1970-01-01 00:00:00'), style: const TextStyle(fontSize: 10)),
                          TextButton(
                            onPressed: (){
                              rpF?.call(comment['id'],comment['user']['name']);
                            },
                            child: const Text('回复', style: TextStyle(color: Colors.red)),
                          ),
                          // const SizedBox(width: 10),
                        ],
                      )
                    ],
                  ),)

              ],
            ),
          );
        },
      ),
    );
  }
}

