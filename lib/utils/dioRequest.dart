import 'dart:io';
import 'package:qwara/EventBus/EventBus.dart';
import'package:dio/dio.dart' ;
import 'package:flutter/material.dart';
import 'package:qwara/getX/StoreController.dart';
import 'package:qwara/constant.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';


BaseOptions options = BaseOptions(
    headers : {
      'Authorization':'Bearer ${storeController.accessToken}',
      'Referer' : "https://www.iwara.tv/",
      'Accept': '*/*',
      'Host': 'api.iwara.tv',
      'Connection': 'keep-alive'
    },
    baseUrl : API_URL,
    connectTimeout : const Duration(seconds: 30),
    receiveTimeout : const Duration(seconds: 30),
    sendTimeout : const Duration(seconds: 30)
)
  // ..headers = {
  //   'Authorization': 'Bearer $accessToken',
  //   'Referer' : "https://www.iwara.tv/",
  //   'Accept': '*/*',
  //   'Host': 'api.iwara.tv',
  //   'Connection': 'keep-alive'
  // }..baseUrl = API_URL
;

///创建 dio
Dio dio = Dio(options)
  ..interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
      print("请求拦截器");
      print(options.method);
      print(options.path);
      print(options.queryParameters);
      print(options.data);
      print(options.headers);
      print(options.baseUrl);
      return handler.next(options);
  }, onResponse: (Response response, ResponseInterceptorHandler handler) {
      print("响应拦截器");
      print(response.data);
      return handler.next(response);
  }, onError: (DioException e, ErrorInterceptorHandler handler) {
       print("错误拦截器");
       print(e);

      formatError(e);
      return handler.next(e);
  }));

void formatError(DioException e) {
  switch (e.type) {
    case DioExceptionType.cancel:
      print("请求取消");
      break;
      case DioExceptionType.connectionTimeout:
      print("连接超时");
      eventBus.fire(TimeOutEvent("连接超时"));
      break;
      case DioExceptionType.receiveTimeout:
      print("响应超时");
      eventBus.fire(TimeOutEvent("响应超时"));
      break;
      case DioExceptionType.sendTimeout:
      print("请求超时");
      eventBus.fire(TimeOutEvent("请求超时"));
      break;
      case DioExceptionType.connectionError:
      print("出现异常");
      break;
      default :
      print("未知错误");
      break;
  }

}


///使用dio 下载文件
Future<bool> downLoadFile(String fileUrl,{required String savePath,required String fileName,Function(int received, int total)? receiveProgress}) async{
  /// 申请写文件权限
  // bool isPermiss =  await checkPermissFunction();
  bool isDownload = false;
  // if(isPermiss) {
    ///手机储存目录
    // String savePath = await getPhoneLocalPath();
    // String fileName = "a.mp4";

    ///参数一 文件的网络储存URL
    ///参数二 下载的本地目录文件
    ///参数三 下载监听
    print("开始下载文件 $savePath$fileName");
    Response response = await dio.download(
        fileUrl, "$savePath$fileName", onReceiveProgress: receiveProgress);
    isDownload = response.statusCode == 200;
  // }else{
  //   ///提示用户请同意权限申请
  //   print("请同意权限申请");
  //   Get.snackbar(
  //     "权限申请",
  //     "请同意权限申请，以便应用正常工作。",
  //     snackPosition: SnackPosition.BOTTOM,
  //     duration: const Duration(seconds: 3),
  //     backgroundColor: Colors.red,
  //     colorText: Colors.white,
  //     snackStyle: SnackStyle.FLOATING,
  //   );
  // }
  return isDownload;
}

Future<bool> checkPermissFunction() async {
  // 检查存储权限
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    // 请求权限
    status = await Permission.storage.request();
    print(status);
    if (status.isGranted) {
      return true; // 权限被授予
    } else {
      return false; // 权限被拒绝
    }
  }
  return true; // 权限已被授予
}

Future<String> getPhoneLocalPath() async {
  // 获取应用程序的文档目录
  try{
    Directory? directory = await getExternalStorageDirectory();
    return directory!.path + '/'; // 返回目录路径，确保后面加上斜杠
  }catch(e){
    print("获取外部存储目录失败 $e");
    return "";
  }
}
