import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:qwara/constant.dart';

import '../enum/Enum.dart';

class StoreController extends GetxController {
  final box = GetStorage();
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

  bool get detailPageVersion => box.read('ISNEWER') ?? true ;
  Future<void> setDetailPageVersion(bool value) async =>await box.write('ISNEWER', value);

  bool get imgViewVersion => box.read('IMGVIEW') ?? true ;
  Future<void> setImgViewVersion(bool value) async =>await box.write('IMGVIEW', value);

  Map<String, dynamic>? get following=> box.read('FOLLOWING');
  Future<void> setFollowing(Map? value) async => await box.write('FOLLOWING', value);

  Map<String, dynamic>? get friends=> box.read('FRIENDS');
  Future<void> setFriends(Map? value) async =>await box.write('FRIENDS', value);
}

final storeController = Get.find<StoreController>();
