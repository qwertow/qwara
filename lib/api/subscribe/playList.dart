import 'package:qwara/utils/dioRequest.dart';

Future<dynamic> getPlayLists(String userId, int page) async {
  final response = await dio.get('/playlists',queryParameters: {
    'page': page-1,
    'user': userId
  });
  return response.data;
}

Future<dynamic> getPlayListByListId(String playlistId,int page) async {
  final response = await dio.get('/playlist/$playlistId',queryParameters: {
    'page': page,
  });
  return response.data;
}

Future<List<Map<String, dynamic>>> getPlayListByVideoId(String videoId) async {
  final response = await dio.get('/light/playlists', queryParameters: {'id': videoId});
  return response.data.cast<Map<String, dynamic>>();
}

Future<dynamic> addVideoToPlayList(String playlistId, String videoId) async {
  final response = await dio.post('/playlist/$playlistId/$videoId');
  return response.data;
}

Future<dynamic> removeVideoFromPlayList(String playlistId, String videoId) async {
  final response = await dio.delete('/playlist/$playlistId/$videoId');
  return response.data;
}

Future<dynamic> createPlayList(String title) async {
  final response = await dio.post('/playlists', data: {'title': title});
  return response.data;
}

Future<dynamic> updatePlayList(String id, String title) async {
  final response = await dio.put('/playlist/$id', data: {'title': title});
  return response.data;
}

// Future<dynamic> deletePlayList(String id) async {
//   final response = await dio.delete('/playlist/$id');
//   return response.data;
// }