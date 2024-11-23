import'package:dio/dio.dart';
import 'package:qwara/getX/StoreController.dart';
import 'package:get/get.dart';
import 'package:qwara/constant.dart';

final storeController = Get.find<StoreController>();
final token = storeController.token;

BaseOptions options = BaseOptions()
  ..headers = {
    'Authorization': 'Bearer $token',
  }..baseUrl = API_URL
;

///创建 dio
Dio dio = Dio(options);