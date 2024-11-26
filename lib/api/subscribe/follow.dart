import 'package:qwara/utils/dioRequest.dart';

Future<dynamic> followUser(String userId) async {
  final response = await dio.post('/user/$userId/followers');
  return response.data;
}

Future<void> unfollowUser(String userId) async {
  await dio.delete('/user/$userId/followers');
  return ;
}