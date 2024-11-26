import 'package:qwara/utils/dioRequest.dart';

Future<dynamic> likeVideo(String videoId,Map<String, dynamic> userInfo) async {
  var response = await dio.post('/video/$videoId/like',
      data: {
        'user': userInfo,
        "createdAt": DateTime.now().toUtc().toIso8601String()
      }
  );
  return response.data;
}

Future<void> unlikeVideo(String videoId) async {
  await dio.delete('/video/$videoId/like');
  return ;
}