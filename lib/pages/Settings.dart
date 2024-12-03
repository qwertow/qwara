import 'package:flutter/material.dart';
import 'package:qwara/constant.dart';
import 'package:qwara/EventBus/EventBus.dart';
import 'package:qwara/getX/StoreController.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Settings _settings = storeController.settings;
  // String themeMode = '跟随系统';
  // String grade = 'ecchi';
  // bool dynamicColor = false;
  // bool workMode = false;
  // bool autoPlay = false;
  // bool loopPlay = false;
  // bool newerDetailVideo = true;
  // bool newerDetailImage = true;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: ListView(
        children: <Widget>[
          const ListTile(
            title: Text('常规', style: TextStyle(color: Colors.blue)),
          ),
          ListTile(
            leading: const Icon(Icons.filter_b_and_w),
            title: const Text('分级'),
            subtitle: const Text('控制非订阅内容'),
            trailing: DropdownButton<String>(
              value: _settings.rating,
              onChanged: (String? newValue) {
                setState(() {
                  _settings.rating = newValue!;
                });
              },
              items: <String>['all', 'general', 'ecchi']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.file_copy),
            title: const Text('下载文件夹位置'),
            subtitle: const Text('/storage/emulated/0/Android/data/com.qwer.qwara/files/'),
            onTap: () {
            },
          ),
          const ListTile(
            title: Text('外观', style: TextStyle(color: Colors.blue)),
          ),
          ListTile(
            leading: const Icon(Icons.nightlight_round),
            title: const Text('暗色模式'),
            subtitle: const Text('控制APP是否处于深色模式'),
            trailing: DropdownButton<ThemeMode>(
              value: _settings.themeMode,
              onChanged: (ThemeMode? newValue) {
                eventBus.fire(ThemeChangeEvent(newValue));
                setState(() {
                  _settings.themeMode = newValue!;
                });
              },
              items: <ThemeMode>[ThemeMode.system, ThemeMode.light, ThemeMode.dark]
                  .map<DropdownMenuItem<ThemeMode>>((ThemeMode value) {
                String displayText;
                switch (value) {
                  case ThemeMode.light:
                    displayText = '浅色模式'; // 对应的中文
                    break;
                  case ThemeMode.dark:
                    displayText = '深色模式'; // 对应的中文
                    break;
                  case ThemeMode.system:
                  default:
                    displayText = '跟随系统'; // 对应的中文
                    break;
                }
                return DropdownMenuItem<ThemeMode>(
                  value: value,
                  child: Text(displayText),
                );
              }).toList(),
            ),
          ),
          // SwitchListTile(
          //   title: Text('动态色彩'),
          //   subtitle: Text('根据壁纸调整动态材质颜色'),
          //   value: dynamicColor,
          //   onChanged: (bool value) {
          //     setState(() {
          //       dynamicColor = value;
          //     });
          //   },
          //   secondary: Icon(Icons.color_lens),
          // ),
          // SwitchListTile(
          //   title: Text('工作模式'),
          //   subtitle: Text('视频静音全屏播放'),
          //   value: workMode,
          //   onChanged: (bool value) {
          //     setState(() {
          //       workMode = value;
          //     });
          //   },
          //   secondary: Icon(Icons.work),
          // ),
          SwitchListTile(
            title: Text('使用新的视频详情页动态效果'),
            subtitle: Text('旧效果做的不和我意，但保留了'),
            value: _settings.detailPageVersion,
            onChanged: (bool value) {
              setState(() {
                _settings.detailPageVersion = value;
              });
            },
            secondary: const Icon(Icons.dynamic_feed_rounded),
          ),
          SwitchListTile(
            title: Text('使用新的图片详情页动态效果'),
            subtitle: Text('旧效果做的不和我意，但保留了'),
            value: _settings.imgViewVersion,
            onChanged: (bool value) {
              setState(() {
                _settings.imgViewVersion = value;
              });
            },
            secondary: const Icon(Icons.dynamic_feed_rounded),
          ),
          const ListTile(
            title: Text('播放器设置', style: TextStyle(color: Colors.blue)),
          ),
          SwitchListTile(
            title: Text('自动播放'),
            subtitle: Text('自动开始缓冲和播放视频'),
            value: _settings.autoPlay,
            onChanged: (bool value) {
              setState(() {
                _settings.autoPlay = value;
              });
            },
            secondary: Icon(Icons.play_arrow),
          ),
          SwitchListTile(
            title: Text('循环播放'),
            subtitle: Text('播放结束后自动重新开始播放'),
            value: _settings.loopPlay,
            onChanged: (bool value) {
              setState(() {
                _settings.loopPlay = value;
              });
            },
            secondary: Icon(Icons.loop),
          ),
          const ListTile(
            title: Text('关于', style: TextStyle(color: Colors.blue)),
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: NetworkImage('https://i.iwara.tv/image/avatar/d31936d0-c8c1-4551-851e-5659ada96641/d31936d0-c8c1-4551-851e-5659ada96641.jpg',
              headers: IMG_HEADERS),
            ),
            title: const Text('开发者主页'),
            subtitle: const Text('点击查看作者主页'),
            onTap: () {
              // 打开开发者主页
              Navigator.pushNamed(context, '/userProfile',arguments: {
                "id": 'e395780d-fbe9-4017-a2cc-c613e682eafd',
                "username": 'qwer2926',
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('源代码'),
            subtitle: const Text('GitHub'),
            onTap: () {
              // 打开GitHub
            },
          ),
        ],
      ),
    );
  }
}
