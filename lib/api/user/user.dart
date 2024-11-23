import 'package:qwara/getX/StoreController.dart';
import 'package:get/get.dart';
import 'package:qwara/utils/request.dart';

final storeController = Get.find<StoreController>();

Future<void> login({required String username, required String password}) async {
  final response=await dio.post('/user/login', data: {
    'email': username,
    'password': password
  });
  storeController.setToken(response.data['token']);
  // return response.data;
}

Future<void> getAccessToken() async {
  final response = await dio.post('/user/token');
  storeController.setAccessToken(response.data['accessToken']);
  // return response.data["accessToken"];
}

