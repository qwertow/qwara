import 'package:qwara/utils/dioRequest.dart';

Future<dynamic> likeVideo(String postId) async {
  var response = await dio.post('/posts/$postId/like');
  return response.data;
}

Future<dynamic> unlikeVideo(String postId) async {
  var response = await dio.post('/posts/$postId/unlike');
  return response.data;
}