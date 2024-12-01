import 'package:flutter/material.dart';
import 'package:qwara/api/user/user.dart';
import 'package:floating_tabbar/lib.dart';
import 'package:qwara/pages/generalPage/CommentPage.dart';
import 'package:qwara/pages/userInfo/userProfile/Abouut.dart';
import 'package:qwara/pages/userInfo/userProfile/ProFileVideos.dart';
import 'package:qwara/pages/userInfo/userProfile/ProfileImages.dart';
import 'package:sizer/sizer.dart';
import 'package:qwara/getX/StoreController.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../api/subscribe/follow.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late Map<String, dynamic> userData={};
  Map<String, dynamic> currUser=storeController.userInfo ?? {};
  bool isExpanded = false; // 控制展开状态
  bool _followLoading = false; // 关注按钮loading状态
  Future<void> getUserData() async {
    Map<String, dynamic> res = await getUserProfile(widget.user['username']);
    setState(() {
      userData = res;
    });
    return ;
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    print('https://i.iwara.tv/image/avatar/${userData['header']?['id']}/${userData['header']?['name']}');
    return  Scaffold(
      // backgroundColor: Colors.black,
      // appBar: AppBar(
      //   backgroundColor: Colors.black,
      //   elevation: 0,
      // ),
      body: Column(
        children: [
          // 大背景图
          Stack(
            children: [
              SizedBox(
                height: 20.h,
                child: Image.network(
                  // fit: BoxFit.contain,
                  'https://i.iwara.tv/image/profileHeader/${userData['header']?['id']}/${userData['header']?['name']}',
                  headers: const {
                    'Referer': "https://www.iwara.tv/",
                  },
                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                    // 显示默认图片
                    return Image.asset('assets/images/default-background.jpg', fit: BoxFit.cover);
                  },
                ),
              ),
              Positioned(
                left: 16,
                bottom: 0,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 36,
                    child: ClipOval(
                      child: Image.network(
                        'https://i.iwara.tv/image/avatar/${userData['user']?['avatar']?['id']}/${userData['user']?['avatar']?['name']}',
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
                      ),
                    ),
                  ),

                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 用户名和标签
          Text(
            userData['user']?['name'] ?? '未知用户',
            style: const TextStyle(color: Colors.purple, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "@${userData['user']?['username']}",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          // 按钮
          if(userData['user']?['id']!= currUser['user']['id'])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Skeletonizer(enabled: _followLoading,child: OutlinedButton(
                onPressed: () async {
                  setState(() {
                    _followLoading = true;
                  });
                  if (userData['user']?['following']??false) {
                    await unfollowUser(userData['user']["id"]);
                  }else {
                    await followUser(userData['user']["id"]);
                  }
                  await getUserData();
                  setState(() {
                    _followLoading = false;
                  });
                },
                child: Text((userData['user']?['following']??false)?'取消关注':'关注'),
                // style: OutlinedButton.styleFrom(primary: Colors.white),
              )),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {},
                child: Text((userData['user']?['friend']??false)?'好友':'加好友'),
                // style: OutlinedButton.styleFrom(primary: Colors.white),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {},
                child: const Text('信息'),
                // style: OutlinedButton.styleFrom(primary: Colors.white),
              ),
            ],
          ),
          Flexible(child: TopTabBar(
              isScrollable: false,
              children: [
                TabItem(title: const Text('关于'), onTap: () {},
                  tab:About(data: userData),),
                TabItem(title: const Text('视频'), onTap: () {},
                    tab: ProfileVideos(userId: widget.user['id'])),
                TabItem(title: const Text('图片'), onTap: () {},
                    tab: ProfileImages(userId: widget.user['id'])),
                TabItem(title: const Text('评论'), onTap: () {},
                    tab: CommentPage(getComments: (page)async{
                      return getUserProfileComment(widget.user['id'], page);
                    })),
              ]))
        ],
      ),
    );
  }

}
