import '../../utils/dioRequest.dart';

// https://api.iwara.tv/video/cns2yrfJwODBhV/comments
//
// {"body":"0","rulesAgreement":true}
//
// {"body":"v","parentId":"eb6847cf-801e-4afe-9376-20ff6302bf7f"}
Future<dynamic> createCommentVideo(String videoId, String rpContent, {String? rpUid}) async {
  final response = await dio.post(
    '/video/$videoId/comments',
    data: {
      'body': rpContent,
      if (rpUid == null)'rulesAgreement': true,
      if (rpUid!= null) 'parentId': rpUid,
    },
  );
  return response.data;
}

// https://api.iwara.tv/profile/a197e565-4cc9-4cbb-b706-a8d0e014c941/comments
Future<dynamic> createCommentProfile(String userId, String rpContent, {String? rpUid}) async {
  final response = await dio.post(
    '/profile/$userId/comments',
    data: {
      'body': rpContent,
      if (rpUid == null)'rulesAgreement': true,
      if (rpUid!= null) 'parentId': rpUid,
    },
  );
  return response.data;
}
// https://api.iwara.tv/image/CRw2xd6OvftEdB/comments
Future<dynamic> createCommentImage(String imageId, String rpContent, {String? rpUid}) async {
  final response = await dio.post(
    '/images/$imageId/comments',
    data: {
      'body': rpContent,
      if (rpUid == null)'rulesAgreement': true,
      if (rpUid!= null) 'parentId': rpUid,
    },
  );
  return response.data;
}


// https://api.iwara.tv/profile/72a9e9b6-e61f-4576-9186-d7cbd8169811/comments?parent=f4f4d965-185a-40b5-8be3-03798b097498&page=0
Future<Map<String,dynamic>> getUserProfileComment(String userId, int page, {String? parent}) async {
  print('getUserProfileComment userId: $userId, page: $page');
  final response = await dio.get('/profile/$userId/comments', queryParameters: {
    if (parent!= null) 'parent': parent,
    'page': page-1
  });
  return response.data;
}

//获取视频评论
Future<Map<String, dynamic>> getVideoComments(String videoId, {required int page, String? parent})async {
  print('getVideoCommentsapi');
  final response=await dio.get('/video/$videoId/comments', queryParameters: {
    if (parent!= null) 'parent': parent,
    'page': page-1
  });
  print(response.data.toString());
  return response.data;
}

//获取图片评论
Future<Map<String, dynamic>> getImgComments(String imgId, {required int page, String? parent})async {
  print('getImgComments');
  final response=await dio.get('/image/$imgId/comments', queryParameters: {
    if (parent!= null) 'parent': parent,
    'page': page-1
  });
  print(response.data.toString());
  return response.data;
}

//编辑评论
Future<Map<String, dynamic>> editComment(String commentId, String content) async {
  final response = await dio.put('/comment/$commentId', data: {
    'body': content,
  });
  return response.data;
}

//删除评论
Future<bool> deleteComment(String commentId) async {
  final response = await dio.delete('/comment/$commentId');
  if (response.statusCode == 204) {
    return true;
  } else {
    return false;
  }
}