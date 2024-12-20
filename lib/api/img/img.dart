
//获取图片列表
import '../../utils/dioRequest.dart';
import 'package:qwara/getX/StoreController.dart';

Future<Map<String, dynamic>> getImgList({
  String? sort,
  int? page,
  String? rating,
  String? userId,
  int? limit,
  String? exclude,
  Set<String>? tags,
  String? date,
})async {
  print('getImgList $sort $page $rating $userId $limit $exclude');
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
      '/images',
      queryParameters: params
  );
// print(response.data.toString());
  return response.data;
}

//获取图片详情
Future<Map<String, dynamic>> getImgDetail(String imgId)async {
  final response = await dio.get('/image/$imgId');
  // print(response.data.toString());
  return response.data;
}

//获取类似图片
Future<Map<String, dynamic>> getSimilarImgs(String imgId)async {
  print('getSimilarImgs');
  final response=await dio.get('/image/$imgId/related');
  // print(response.data.toString());
  return response.data;
}

//获取订阅的图片列表
Future<Map<String, dynamic>> getSubscribedImgs({ required int page, String? rating ,int limit = 24 })async {
  print('getSubscribedImgs $page $rating $limit');
  // dio.options.headers['Authorization'] = 'Bearer ${storeController.accessToken}';

  final response=await dio.get(
      '/images',
      queryParameters: {
        'subscribed': true,
        'page': page-1,
        'rating': rating ?? storeController.settings.rating,
        // 'limit': limit
      }
  );
  // print(response.data.toString());
  return response.data;
}