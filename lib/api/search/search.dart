
import 'package:qwara/utils/dioRequest.dart';

Future<Map<String, dynamic>> search(String query,String type,int page) async {
  final response = await dio.get('/search', queryParameters: {
    'query': query,
    'type': type,
    'page': page-1
  });
  return response.data;
}

Future<Map<String, dynamic>> getFilteredTags(String letter ,int page) async {
  final response = await dio.get('/tags?filter=$letter&page=${page-1}');
  return response.data;
}