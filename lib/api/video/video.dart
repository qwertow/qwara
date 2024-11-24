import 'package:qwara/utils/dioRequest.dart';


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
Future<Map<String, dynamic>> getVideoList({required String sort, required int page, String rating = 'ecchi'})async {
  print('getVideoList $sort $page $rating');
  final response=await dio.get(
      '/videos',
      queryParameters: {
       'sort': sort,
        'page': page,
        'rating': rating
      }
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
Future<List> getVideoUrls(String filrUrl)async {
  print('getVideoUrl');
  final response = await dio.get(filrUrl);
  // print(response.data.toString());
  return response.data;
}
//获取订阅视频
Future<Map> getSubscribedVideos({required String sort, required int page, String rating = 'ecchi'})async {
  print('getSubscribedVideos');
  final response=await dio.get(
      'https://api.iwara.tv/videos',
      queryParameters: {
        'subscribed': true,
        'page': page,
        'rating': rating
      }
  );
  // print(response.data.toString());
  return response.data;
}