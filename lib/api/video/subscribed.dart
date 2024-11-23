import 'package:qwara/utils/request.dart';

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