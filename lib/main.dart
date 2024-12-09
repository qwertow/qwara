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
import 'package:qwara/utils/DownLoadUtil.dart';
import 'package:qwara/utils/notificationUtils.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sizer/sizer.dart';
import 'package:lifecycle/lifecycle.dart';

import 'EventBus/EventBus.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await DownLoadHelper.downloaderInitialize();
  // 初始化通知帮助类
  // NotificationHelper notificationHelper = NotificationHelper();
  // await notificationHelper.initialize();
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{
  // 初始化主题模式
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    // 添加观察者
    WidgetsBinding.instance.addObserver(this);
    // 监听主题切换事件
    eventBus.on<ThemeChangeEvent>().listen((event) {
      if(event.themeMode!= null){
        setState(() {
          _themeMode = event.themeMode!;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // 应用进入后台时执行的逻辑
      print("应用已进入后台");
      // 在这里执行你需要做的事情，例如保存数据或清理资源
      storeController.setHistoryVideos();
    }
    if (state == AppLifecycleState.inactive) {
      print("应用处于空闲状态");
    }
    if (state == AppLifecycleState.hidden) {
      print("应用已被覆盖在后台");
    }
    if (state == AppLifecycleState.detached) {
      // 应用完全关闭时执行的逻辑
      print("应用即将关闭");
      // 在这里执行你需要做的事情，例如保存最后的状态
    }
  }

  @override
  void dispose() {
    // 移除观察者
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
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
            darkTheme: ThemeData(
              brightness: Brightness.dark, // 深色模式
            ),
            // 使用动态的主题模式
            themeMode: _themeMode,
            home: const MyHomePage(), // 传递主题切换的方法
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
    _timer = Timer.periodic(const Duration(minutes: 30), (timer) async {
     refreshAccessToken(false);
    });
  }
  @override
  didUpdateWidget(MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    currUser=storeController.userInfo ?? {};;
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
      Get.offAndToNamed("/login");
      // Navigator.of(context).pushNamed("/login");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    _timer.cancel();
  }

  final List<Map<String, dynamic>> navItems = [
    {
      'label': 'home',
      'icon': Icons.home,
      'index': 0,
    },
    {
      'label': 'videos',
      'icon': Icons.dashboard,
      'index': 1,
    },
    {
      'label': 'images',
      'icon': Icons.image,
      'index': 2,
    },
  ];

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
        // backgroundColor: Colors.white,
        title: Text(currUser['user']?['name'] ?? '未登录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            onPressed: () {
              //TODO: message page
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
              Get.toNamed("/search");
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // 竖直的导航栏
          // if (!isPortrait)
          ScreenTypeLayout.builder(
            mobile: (BuildContext context) => const SizedBox.shrink(),
            tablet: (BuildContext context) => SizedBox(
              width: 70,
              child: Column(
                children: navItems.map((item) {
                  return TextIconButton(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    radius: 50,
                    color: _currentIndex == item['index'] ? Colors.grey[350] : null,
                    icon: Icon(
                      item['icon'],
                      size: _currentIndex == item['index'] ? 16 : 15,
                      color: _currentIndex == item['index'] ? Colors.blue : null,
                    ),
                    text: Text(
                      item['label'],
                      style: TextStyle(
                        fontSize: 12,
                        color: _currentIndex == item['index'] ? Colors.blue : null,
                      ),
                    ),
                    type: TextIconButtonType.imageTop,
                    onTap: () {
                      setState(() {
                        _currentIndex = item['index'];
                        _pageController.animateToPage(
                          item['index'],
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      });
                    },
                  );
                }).toList(),
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
              children: const [
                Home(), // 页面1
                VideosPage(),
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
          items: navItems.map((item) {
            return BottomNavigationBarItem(
              label: item['label'],
              icon: Icon(item['icon']),
            );
          }).toList(),
        ),
        tablet: (BuildContext context) => const SizedBox.shrink(),
      ),
    );
  }
}
