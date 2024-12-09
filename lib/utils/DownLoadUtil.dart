
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:qwara/getX/StoreController.dart';
import 'package:qwara/utils/DirectoryManager.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

class DownLoadHelper {
   static final ReceivePort _port = ReceivePort();

  static Future<void>  downloaderInitialize()async {
    print("初始化下载器");
    await FlutterDownloader.initialize(
        debug: false, // optional: set to false to disable printing logs to console (default: true)
        ignoreSsl: true // option: set to false to disable working with http links (default: false)
    );
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) async {
      String id = data[0];
      DownloadTaskStatus status =  DownloadTaskStatus.values[data[1]];
      int progress = data[2];
      // print("下载进度00: $id, $status, $progress");
      if (status == DownloadTaskStatus.complete || status == DownloadTaskStatus.failed) {
        _downCallback(status == DownloadTaskStatus.complete);
        // 下载完成后的处理逻辑
        final tasks = await FlutterDownloader.loadTasksWithRawQuery(query: "SELECT * FROM task WHERE task_id='$id'");
        print("下载完成: $id");
        print(tasks);
        print(tasks?[0].savedDir);
        print(tasks?[0].filename);
        DirectoryManager.scanFile("${tasks?[0].savedDir}/${tasks?[0].filename}");
        storeController.setDownloads();

      }
    });
    await FlutterDownloader.registerCallback(_downloadCallback);

  }
  @pragma('vm:entry-point')
  static void _downloadCallback(String id, int status, int progress) {
    // print("下载进度: $id, $status, $progress");
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  Future<int> _getFileSize(String url) async {
    var request = await HttpClient().headUrl(Uri.parse(url));
    var response = await request.close();
    return int.parse(response.headers['content-length']?.first ?? '0');
  }

   // DownloadWorker   649
  Future<String?> createDownloadTak(String saveTo,String link, String title, {String? suffix}) async {
    _beforeDownload();
    Directory savedDir = Directory(saveTo);
    if (!savedDir.existsSync()) {
      savedDir.createSync(recursive: true);
    }

    print("开始下载：${await _getFileSize(link)}");
    Fluttertoast.showToast(msg: "开始下载");

    String _fileName = title;
    _fileName += suffix ?? "";

    final taskId = await FlutterDownloader.enqueue(
      fileName: _fileName,
      url: link,
      headers: {}, // optional: header send with url (auth token etc)
      savedDir: savedDir.path,
      showNotification: true, // show download progress in status bar (for Android)
      openFileFromNotification: true, // click on notification to open downloaded file (for Android)
    );
    // _downloadingMap[_fileName] = taskId;
    return taskId;
  }
}

final DownLoadHelper downLoadHelper = DownLoadHelper();


enum DownloadStatus {
  waiting,
  downloading,
  success,
  error,
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

Future<bool> _beforeDownload() async {

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
  return true;
}
//
void _downCallback(bool success) {
  if(success) {
    showDownSnackBar( "下载完成", type: DownloadStatus.success);
  }else {
    showDownSnackBar( "下载失败", type: DownloadStatus.error);
  }
}

