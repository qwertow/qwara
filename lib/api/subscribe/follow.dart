import 'package:qwara/utils/dioRequest.dart';
import 'package:qwara/getX/StoreController.dart';

Future<dynamic> followUser(String userId) async {
  // dio.options.headers['Authorization'] = 'Bearer $accessToken';
  final response = await dio.post('/user/$userId/followers');
  if (response.statusCode == 201) {
    await storeController.setFollowing(null);
  }
  return response.data;
}

Future<void> unfollowUser(String userId) async {
  final response=await dio.delete('/user/$userId/followers');
  if (response.statusCode == 204) {
    await storeController.setFollowing(null);
  }
  return ;
}


// {
// "count": 0,
// "limit": 6,
// "page": 0,
// "results": []
// }
// Future<Map>  getFollowers(String userId,{limit=6,page=0}) async {
//   // dio.options.headers['Authorization'] = 'Bearer $accessToken';
//   Map? data =  storeController.followers ??(await dio.get('/user/$userId/followers',queryParameters: {'limit':limit,'page':page})).data;
//   return data;
// }
Future<Map<String, dynamic>> getFollowers(String userId, {int? limit, int page = 1}) async {
    // 发起网络请求
    final response = await dio.get(
      '/user/$userId/followers',
      queryParameters: {
        'limit': limit,
        'page': page-1,
      },
    );
    return response.data;
}

Future<Map<String, dynamic>> getFollowing(String userId, {int? limit, int page = 1}) async {
  print('getFollowing');
    final response = await dio.get(
      '/user/$userId/following',
      queryParameters: {
        'limit': limit,
        'page': page-1,
      },
    );
    storeController.following ?? await storeController.setFollowing(response.data);
    return response.data ;
}

Future<Map<String, dynamic>> getFriends(String userId, {int page = 1}) async {

    final response = await dio.get(
      '/user/$userId/friends',
      queryParameters: {
        'page': page-1,
      },
    );
    storeController.friends ?? await storeController.setFriends(response.data);
      return {
        "count": response.data["count"],
        "limit": response.data["limit"],
        "page": response.data["page"],
        "results": response.data["results"].map((e) => {'user': e}).toList(),
      };
}
