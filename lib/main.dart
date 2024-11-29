import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qwara/api/user/user.dart';
import 'package:qwara/components/DrawerView.dart';
import 'package:qwara/components/IconTextButton.dart';
import 'package:qwara/getX/StoreController.dart';
import 'package:qwara/pages/home/home.dart';
import 'package:qwara/pages/image/ImagePage.dart';
import 'package:qwara/pages/videosPage//VideosPage.dart';
import 'package:qwara/routers/routers.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:qwara/utils/notificationUtils.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sizer/sizer.dart';
import 'package:lifecycle/lifecycle.dart';

import 'EventBus/EventBus.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化通知帮助类
  NotificationHelper notificationHelper = NotificationHelper();
  await notificationHelper.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final Map routers = routes;

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          navigatorObservers: [defaultLifecycleObserver],
          debugShowCheckedModeBanner: false,
          onGenerateRoute: onGenerateRoute,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MyHomePage(),
        );
      }
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
// final storeController = Get.find<StoreController>();

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final storeController=Get.put(StoreController());
  late Map<String, dynamic> currUser={};
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    currUser=storeController.userInfo ?? {};
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
    refreshAccessToken(true);
    _timer = Timer.periodic(const Duration(hours: 1), (timer) async {
     refreshAccessToken(false);
    });
  }

  Future<void> refreshAccessToken(bool ini) async {
    bool access=await getAccessToken();

    if (access && ini){
      eventBus.fire(UpdateAccessTokenEvent(true));
    }else{
      _checkLoginStatus();
    }
  }

  Future<void> _checkLoginStatus() async {
    // 模拟检查登录状态的异步操作
    bool isLoggedIn = storeController.token != null;

    if (!isLoggedIn && !storeController.isTourist) {
      // 如果用户未登录且非游客，则跳转到登录页面
      Navigator.of(context).pushNamed("/login");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // print('myhome build   ${storeController.accessToken}');
    return Scaffold(
      drawer: const Drawer(
        child: DrawerView(),
      ),
      appBar: AppBar(
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
        backgroundColor: Colors.white,
        title: Text(currUser['user']?['name'] ?? '未登录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            onPressed: () {
              //TODO: settings page
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {
              //TODO: notification page
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              //TODO: search page
            },
          ),
        ],
      ),
      // body: PageView(
      //   controller: _pageController,
      //   onPageChanged: (index) {
      //     setState(() {
      //       _currentIndex = index;
      //     });
      //   },
      //   children: const [
      //     Home(),
      //     VideosPage(),
      //   ],
      // ),
      body: Row(
        children: [
          // 竖直的导航栏
          // if (!isPortrait)
          ScreenTypeLayout.builder(
            mobile: (BuildContext context) => const SizedBox.shrink(),
            tablet: (BuildContext context) => SizedBox(
              width: 80,
              child: Column(
                children: [
                  TextIconButton(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    radius: 50,
                    color: _currentIndex == 0? Colors.grey[350] : null,
                    icon: Icon(Icons.home, size: _currentIndex == 0? 16 : 15),
                    text: const Text("Home", style: TextStyle(fontSize: 12)),
                    type: TextIconButtonType.imageTop,
                    onTap: () {
                      _pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                  ),
                  TextIconButton(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    radius: 50,
                    color: _currentIndex == 1? Colors.grey[350] : null,
                    icon: Icon(Icons.dashboard, size: _currentIndex == 1? 16 : 15),
                    text: const Text("videos", style: TextStyle(fontSize: 12)),
                    type: TextIconButtonType.imageTop,
                    onTap: () {
                      _pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                  ),
                  TextIconButton(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    radius: 50,
                    color: _currentIndex == 2? Colors.grey[350] : null,
                    icon: Icon(Icons.image, size: _currentIndex == 1? 16 : 15),
                    text: const Text("Images", style: TextStyle(fontSize: 12)),
                    type: TextIconButtonType.imageTop,
                    onTap: () {
                      _pageController.animateToPage(
                        2,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                const Home(), // 页面1
                const VideosPage(),
                ImagePage()// 页面2
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ScreenTypeLayout.builder(
        mobile: (BuildContext context) => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          fixedColor: Colors.blue,
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          },
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
              label: "home",
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              label: "videos",
              icon: Icon(Icons.dashboard),
            ),
            BottomNavigationBarItem(
              label: "images",
              icon: Icon(Icons.image),
            ),
          ],
        ),
        tablet: (BuildContext context) => const SizedBox.shrink(),
      ),
    );
  }
}
