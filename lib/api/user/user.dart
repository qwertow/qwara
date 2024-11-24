import 'package:qwara/getX/StoreController.dart';
import 'package:get/get.dart';
import 'package:qwara/utils/dioRequest.dart';

final storeController = Get.find<StoreController>();

Future<void> login({required String username, required String password}) async {
  final response=await dio.post('/user/login', data: {
    'email': username,
    'password': password
  });
  storeController.setToken(response.data['token']);

  return ;
}

Future<void> getAccessToken() async {
  dio.options.headers['Authorization'] = 'Bearer ${storeController.token}';
  final response = await dio.post('/user/token');
  storeController.setAccessToken(response.data['accessToken']);
  Get.offAllNamed('/home');
  return ;
}

Future<void> getUserInfo() async {
  // print(storeController.token);
  // print(storeController.accessToken);
  // dio.options.headers['Authorization'] = 'Bearer ${storeController.accessToken}';
  final response = await dio.get('/user');
  print(storeController.token);
  print(storeController.accessToken);
  print(response.data);
  storeController.setUserInfo(response.data);
  return ;
}

Future<void> logout() async {
  storeController.setToken('');
  return ;
}

