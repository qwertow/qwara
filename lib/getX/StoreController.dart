import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:qwara/constant.dart';

import '../enum/Enum.dart';

final box = GetStorage();

class StoreController extends GetxController {
  Settings settings=Settings();

  String? get token => box.read(TOKEN_KEY);
  Future<void> setToken(String? value) async =>await  box.write(TOKEN_KEY, value);

  String? get accessToken =>box.read(ACCESS_TOKEN_KEY);
  Future<void> setAccessToken(String? value) async =>await  box.write(ACCESS_TOKEN_KEY, value);

  Clarity? get clarityStorage => Clarity.values.firstWhere((e) => e.value == box.read(CLARITY_KEY), orElse: () => Clarity.low);
  Future<void> setClarity(Clarity value) async =>await box.write(CLARITY_KEY, value.value);

  Map<String, dynamic>? get userInfo => box.read(USER_INFO_KEY);
  Future<void> setUserInfo(Map<String, dynamic> value) async =>await box.write(USER_INFO_KEY, value);

  bool get isTourist => box.read("TouristLogin") ?? false;
  Future<void> setIsTourist(bool value) async =>await box.write("TouristLogin", value);

  Map<String, dynamic>? get following=> box.read('FOLLOWING');
  Future<void> setFollowing(Map? value) async => await box.write('FOLLOWING', value);

  Map<String, dynamic>? get friends=> box.read('FRIENDS');
  Future<void> setFriends(Map? value) async =>await box.write('FRIENDS', value);

}

class Settings {

  ThemeMode get themeMode {
    final mode = box.read("THEME_MODE"); // 从存储中读取主题模式
    switch (mode) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      case "system":
      default:
        return ThemeMode.system;
    }
  }

  set themeMode(ThemeMode value) {
    switch (value) {
      case ThemeMode.light:
        box.write("THEME_MODE", "light");
        break;
      case ThemeMode.dark:
        box.write("THEME_MODE", "dark");
        break;
      case ThemeMode.system:
        box.write("THEME_MODE", "system");
        break;
      default:
        box.write("THEME_MODE", "system");
    }
  }

  bool get loopPlay => box.read("LOOP_PLAY") ?? false;

  set loopPlay(bool value) {
    box.write("LOOP_PLAY", value);
  }

  bool get autoPlay => box.read("AUTO_PLAY") ?? false;

  set autoPlay(bool value) {
    box.write("AUTO_PLAY", value);
  }

  String get rating => box.read("GRADE") ?? "ecchi";

  set rating(String? value) {
    box.write("GRADE", value);
  }

  bool get detailPageVersion => box.read('ISNEWER') ?? true ;
  set detailPageVersion(bool value) {
    box.write('ISNEWER', value);
  }

  bool get imgViewVersion => box.read('IMGVIEW') ?? true ;
  set imgViewVersion(bool value) {
    box.write('IMGVIEW', value);
  }

  Settings();
}

final storeController = Get.find<StoreController>();
