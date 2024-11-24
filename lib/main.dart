import 'package:flutter/material.dart';
import 'package:qwara/components/DrawerView.dart';
import 'package:qwara/components/IconTextButton.dart';
import 'package:qwara/getX/StoreController.dart';
import 'package:qwara/pages/home/home.dart';
import 'package:qwara/pages/videosPage//VideosPage.dart';
import 'package:qwara/routers/routers.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:responsive_builder/responsive_builder.dart';

void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final Map routers = routes;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: onGenerateRoute,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'namenamenamenamename'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final storeController=Get.put(StoreController());
  @override
  void initState() {
    super.initState();
    // _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 模拟检查登录状态的异步操作
    bool isLoggedIn = storeController.token.isNotEmpty;

    if (!isLoggedIn) {
      // 如果用户未登录，则跳转到登录页面
      Navigator.of(context).pushNamed("/login");

    }
  }

  Future<bool> _isUserLoggedIn() async {
    // 这里可以检查实际的登录状态，比如访问本地存储或者接口
    await Future.delayed(const Duration(seconds: 2)); // 假装进行了一些耗时的操作
    return true; // 这里返回false表示用户未登录
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(widget.title),
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
              children: const [
                Home(), // 页面1
                VideosPage(), // 页面2
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
          ],
        ),
        tablet: (BuildContext context) => const SizedBox.shrink(),
      ),
    );
  }
}
