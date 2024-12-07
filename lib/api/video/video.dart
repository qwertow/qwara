import 'package:qwara/utils/dioRequest.dart';
import 'package:qwara/getX/StoreController.dart';

// void request()async {
//   Response response;
//   response=await dio.get('/test?id=128name=dio');
//   print(response.data.tostring());
// // The below request is the same as above.
//   response = await dio.get(
//   '/test',
//   queryParameters:{'id':12,'name':'dio'},
//   );
//   print(response.data.tostring());
// }
// https://api.iwara.tv/videos?sort=trending&page=0&rating=ecchi
//获取视频列表
Future<Map<String, dynamic>> getVideoList({
  String? sort,
  int? page,
  String? rating,
  String? userId,
  int? limit,
  String? exclude,
  Set<String>? tags,
  String? date,
})async {
  print('getVideoList $sort $page $rating $userId $limit $exclude');

  Map<String, dynamic> params = {
    'exclude': exclude,
   'sort': sort,
    'page': page,
    'rating': rating ?? storeController.settings.rating,
    'user': userId,
    'limit': limit,
    "tags": tags?.join('%2C'),
    "date": date
  };
  params.removeWhere((key, value) => value == null || value == '');
  final response=await dio.get(
      '/videos',
      queryParameters: params
  );
  // print(response.data.toString());
  return response.data;
}
//获取视频详情
Future<Map<String, dynamic>> getVideoDetail(String videoId)async {
  print('getVideoDetail  $videoId');
  final response = await dio.get('/video/$videoId');
  // print(response.data.toString());
  return response.data;
}
//获取视频链接
Future<List> getVideoUrls(String fileUrl,String xVersion)async {
  print('getVideoUrl');
  dio.options.headers['X-Version'] = xVersion;
  final response = await dio.get(fileUrl);
  dio.options.headers.remove('X-Version');
  // print(response.data.toString());
  return response.data;
}
//获取订阅视频
Future<Map<String, dynamic>> getSubscribedVideos({ required int page,String? rating })async {
  print('getSubscribedVideos');
  // dio.options.headers['Authorization'] = 'Bearer ${storeController.accessToken}';

  final response=await dio.get(
      '/videos',
      queryParameters: {
        'subscribed': true,
        'page': page-1,
        'rating': rating ?? storeController.settings.rating,
      }
  );
  // print(response.data.toString());
  return response.data;
}
//获取最爱视频
Future<Map> getFavoritesVideos(int page)async {

  final response=await dio.get(
      '/favorites/videos',
      queryParameters: {
        'page': page-1,
      }
  );
  return response.data;
}


//获取类似视频
Future<Map<String, dynamic>> getSimilarVideos(String videoId)async {
  print('getSimilarVideos');
  final response=await dio.get('/video/$videoId/related');
  // print(response.data.toString());
  return response.data;
}