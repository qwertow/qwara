import 'package:get/get.dart';
import 'package:qwara/utils/dioRequest.dart';
import 'package:qwara/getX/StoreController.dart';


Future<void> login({required String username, required String password}) async {
  // await storeController.setToken(null);
  // await storeController.setAccessToken(null);
  print('login username: ${storeController.token}, password: ${storeController.accessToken}');
  dio.options.headers['Authorization'] = null;
  final response=await dio.post('/user/login', data: {
    'email': username,
    'password': password
  });
  if(response.statusCode== 200){
    await storeController.setToken(response.data['token']);
    print('login success');
    if(await getAccessToken()){
      print('get access token success');
      if(await getUserInfo()) {
        print('get user info success');
        Get.offAndToNamed('/home');
      }
    }
    return ;
  }

}

Future<bool> getAccessToken() async {
  dio.options.headers['Authorization'] = 'Bearer ${storeController.token}';
  final response = await dio.post('/user/token');
  print('get access token response: ${response.data}');
  await storeController.setAccessToken(response.data['accessToken']);
  dio.options.headers['Authorization'] = 'Bearer ${storeController.accessToken}';

  if (response.statusCode == 200) {
    return true;
  } else {
    // storeController.setToken(null);
    return false;
  }
}

Future<bool> getUserInfo() async {
  // dio.options.headers['Authorization'] = 'Bearer $accessToken';
  bool success = false;
  int retryCount = 0;
  while (!success) {
    try {
      final response = await dio.get('/user');
      if(response.statusCode == 200){
        await storeController.setUserInfo(response.data);
        success = true; // 请求成功，退出循环
      }
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
  return success;
}


Future<void> logout() async {
  // storeController.setToken(null);
  Get.toNamed('/login');
  return ;
}

Future<Map<String,dynamic>> getUserProfile(String username) async {
  final response = await dio.get('/profile/$username');
  return response.data;
}

//用户评论
Future<Map<String,dynamic>> getUserProfileComment(String userId, int page) async {
  print('getUserProfileComment userId: $userId, page: $page');
  final response = await dio.get('/profile/$userId/comments', queryParameters: {'page': page-1});
  return response.data;
}