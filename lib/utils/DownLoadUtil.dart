
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:qwara/utils/dioRequest.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:r_album/r_album.dart';
import 'notificationUtils.dart';

final NotificationHelper _notificationHelper = NotificationHelper();

enum DownloadStatus {
  waiting,
  downloading,
  success,
  error,
}

Future<void> moveToAlbum(String title, {String? suffix}) async {
  String _fileName = title;
  _fileName += suffix ?? "";
  String originalFilePath = "${await getPhoneLocalPath()}$_fileName";

  bool? createAlbum = await RAlbum.createAlbum("qwara");
  if(createAlbum ?? false) {
    await RAlbum.saveAlbum(
        "qwara", [originalFilePath],[_fileName]);
    // 删除原始文件
    File originalFile = File(originalFilePath);
    if (await originalFile.exists()) {
      await originalFile.delete();
      print("原始文件已删除：$originalFilePath");
    } else {
      print("文件不存在：$originalFilePath");
    }
  }
}

void showDownSnackBar( String message, {DownloadStatus? type}) {
  switch(type) {
    case DownloadStatus.error:
      Get.snackbar("错误", message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        titleText: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
      );
      break;
    case DownloadStatus.success:
      Get.snackbar("成功", message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        titleText: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
      );
      break;
    default:
      Get.snackbar("提示", message,
        snackPosition: SnackPosition.BOTTOM,
      );
      break;
  }
}

///当前进度进度百分比  当前进度/总进度 从0-1
Future<bool> downloading(String url ,String title, {String? suffix}) async {
  Fluttertoast.showToast(msg: "开始下载");

  String _fileName = title;
  _fileName += suffix ?? "";
  return await downLoadFile(url,
      savePath: await getPhoneLocalPath(),
      fileName: _fileName,
      receiveProgress: (received, total) {
        if (total != -1) {
          ///当前下载的百分比例
          print((received / total * 100).toStringAsFixed(0) + "%");
          // CircularProgressIndicator(value: currentProgress,) 进度 0-1
          _notificationHelper.showNotification(
            title: '下载',
            body: _fileName,
            details: AndroidNotificationDetails("downloadChannelId01",_fileName,
              progress: received,
              maxProgress: total,
              showProgress: true,
            ),
          );
        }
      }
  );
}
Future<void> beforeDownload() async {
  if(await Permission.notification.isDenied){
    Get.snackbar(
      "权限申请",
      "请同意通知申请，以便应用显示下载进度'}。",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackStyle: SnackStyle.FLOATING,
    );
    Permission.notification.request();
  }
}

void downCallback(bool success) {
  if(success) {
    showDownSnackBar( "下载完成", type: DownloadStatus.success);
  }else {
    showDownSnackBar( "下载失败", type: DownloadStatus.error);
  }
}