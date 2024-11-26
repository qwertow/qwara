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
  await getAccessToken();
  Get.offAllNamed('/home');
  return ;
}

Future<void> getAccessToken() async {
  dio.options.headers['Authorization'] = 'Bearer ${storeController.token}';
  final response = await dio.post('/user/token');
  storeController.setAccessToken(response.data['accessToken']);

  return ;
}

// Future<void> getUserInfo() async {
//
//   try {
//     final response = await dio.get('/user');
//     storeController.setUserInfo(response.data);
//   }catch (e) {
//     await getAccessToken();
//     getUserInfo();
//   }
//
//   return ;
// }
Future<void> getUserInfo() async {
  bool success = false;
  int retryCount = 0;
  while (!success) {
    try {
      final response = await dio.get('/user');
      storeController.setUserInfo(response.data);
      success = true; // 请求成功，退出循环
    } catch (e) {
      retryCount++;

      // 记录异常日志
      print('获取用户信息失败: $e');

      // 尝试获取新的访问令牌
      await getAccessToken();

      // 可以设置一个最大重试次数，避免无限循环
      if (retryCount >= 30) {
        // 重试次数超过3次，退出循环
        print('获取用户信息失败30: $e');
        break;
      }
    }
  }
}


Future<void> logout() async {
  storeController.setToken('');
  Get.offAllNamed('/login');
  return ;
}

