import 'package:qwara/utils/dioRequest.dart';

Future<dynamic> followUser(String userId) async {
  final response = await dio.post('/api/subscribe/follow', data: {'userId': userId});
  return response.data;
}

Future<dynamic> unfollowUser(String userId) async {
  final response = await dio.post('/api/subscribe/unfollow', data: {'userId': userId});
  return response.data;
}