import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:qwara/constant.dart';

import '../enum/Enum.dart';

class StoreController extends GetxController {
  final box = GetStorage();
  String get token => box.read(TOKEN_KEY)?? "";
  // set token(String value) => box.write(TOKEN_KEY, value);
  void setToken(String value) => box.write(TOKEN_KEY, value);

  String get accessToken => box.read(ACCESS_TOKEN_KEY);
  // set accessToken(String value) => box.write(ACCESS_TOKEN_KEY, value);
  void setAccessToken(String value) => box.write(ACCESS_TOKEN_KEY, value);

  Clarity get clarityStorage => box.read(CLARITY_KEY) ?? Clarity.low;
  void setClarity(Clarity value) => box.write(CLARITY_KEY, value);
}