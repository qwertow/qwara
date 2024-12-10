import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:qwara/constant.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import '../enum/Enum.dart';

final box = GetStorage();

final List<HistoryVideo> _historyVideos = [];

class StoreController extends GetxController {
  Settings settings=Settings();

  String? get token => box.read(TOKEN_KEY);
  Future<void> setToken(String? value) async =>await  box.write(TOKEN_KEY, value);

  String? get accessToken =>box.read(ACCESS_TOKEN_KEY);
  Future<void> setAccessToken(String? value) async =>await  box.write(ACCESS_TOKEN_KEY, value);

  Clarity? get clarityStorage => Clarity.values.firstWhere((e) => e.value == box.read(CLARITY_KEY), orElse: () => Clarity.low);
  Future<void> setClarity(Clarity value) async =>await box.write(CLARITY_KEY, value.value);

  Map<String, dynamic>? get userInfo => box.read(USER_INFO_KEY);
  Future<void> setUserInfo(Map<String, dynamic>? value) async =>await box.write(USER_INFO_KEY, value);

  bool get isTourist => box.read("TouristLogin") ?? false;
  Future<void> setIsTourist(bool value) async =>await box.write("TouristLogin", value);

  Map<String, dynamic>? get following=> box.read('FOLLOWING');
  Future<void> setFollowing(Map? value) async => await box.write('FOLLOWING', value);

  Map<String, dynamic>? get friends=> box.read('FRIENDS');
  Future<void> setFriends(Map? value) async =>await box.write('FRIENDS', value);

  // List<HistoryVideo> get historyVideos => box.read('HISTORY_VIDEOS') ?? <HistoryVideo>[];
  List<HistoryVideo> get historyVideos => (box.read('HISTORY_VIDEOS') ?? []).map((e) => HistoryVideo.fromJson(e)).cast<HistoryVideo>().toList();
  Future<void> setHistoryVideo(HistoryVideo value) async {
    if(_historyVideos.isNotEmpty){
      if(_historyVideos.last.historyVInfo?["id"]==value.historyVInfo?["id"]){
        return;
      }
    }
    _historyVideos.add(value);
  }
  Future<void> setHistoryVideos() async {
    if(_historyVideos.isEmpty){
      return;
    }
    List<HistoryVideo> tempHistoryVideos = List.from(historyVideos);
    if(tempHistoryVideos.isNotEmpty){
      if(tempHistoryVideos.last.historyVInfo?["id"]==_historyVideos.first.historyVInfo?["id"]){
        tempHistoryVideos.removeLast();
      }
    }
    tempHistoryVideos.addAll(_historyVideos);
    if(settings.maxHistoryRecords!=null){
      if(tempHistoryVideos.length>settings.maxHistoryRecords!){
        tempHistoryVideos.removeRange(0, tempHistoryVideos.length-settings.maxHistoryRecords!);
      }
    }
    _historyVideos.clear();
    await box.write('HISTORY_VIDEOS', tempHistoryVideos.map((e) => e.toJson()).toList());
  }
  Future<void> clearHistoryVideos() async {
    await box.write('HISTORY_VIDEOS', []);
  }


  List<MyDownloadTask> get downloads => (box.read('DOWNLOADS') ?? []).map((e) => MyDownloadTask.fromJson(e)).cast<MyDownloadTask>().toList();
  Future<void> setDownloads() async {
    List<MyDownloadTask> tempDownloads = List.from(downloads);
    List<DownloadTask>? nowDownloads = await FlutterDownloader.loadTasksWithRawQuery(query: "SELECT * FROM task WHERE status = 3 ");
    FlutterDownloader.loadTasksWithRawQuery(query: "DELETE FROM task WHERE status = 3");
    tempDownloads.addAll((nowDownloads ?? []).map((e) => MyDownloadTask.fromDownloadTask(e)).toList());
    if(settings.maxDownloadRecords!=null){
      if(tempDownloads.length>settings.maxDownloadRecords!){
        tempDownloads.removeRange(0, tempDownloads.length-settings.maxDownloadRecords!);
      }
    }
    await box.write('DOWNLOADS', tempDownloads.map((e) => e.toJson()).toList());
  }
  Future<void> removeDownloadTask(String path,String taskId) async {
    // 尝试删除文件
    try {
      final file = File('$path.mp4');
      if (await file.exists()) {
        await file.delete();
        print("文件已删除: $path");
      } else {
        print("文件不存在: $path");
      }
    } catch (e) {
      print("删除文件时出错: $e");
    }
    List<MyDownloadTask> tempDownloads = List.from(downloads);
    tempDownloads.removeWhere((element) => element.taskId == taskId);
    await box.write('DOWNLOADS', tempDownloads.map((e) => e.toJson()).toList());
  }
}

class Settings {

  ThemeMode get themeMode {
    final mode = box.read("THEME_MODE"); // 从存储中读取主题模式
    switch (mode) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      case "system":
      default:
        return ThemeMode.system;
    }
  }

  set themeMode(ThemeMode value) {
    switch (value) {
      case ThemeMode.light:
        box.write("THEME_MODE", "light");
        break;
      case ThemeMode.dark:
        box.write("THEME_MODE", "dark");
        break;
      case ThemeMode.system:
        box.write("THEME_MODE", "system");
        break;
      default:
        box.write("THEME_MODE", "system");
    }
  }

  bool get loopPlay => box.read("LOOP_PLAY") ?? false;

  set loopPlay(bool value) {
    box.write("LOOP_PLAY", value);
  }

  bool get autoPlay => box.read("AUTO_PLAY") ?? false;

  set autoPlay(bool value) {
    box.write("AUTO_PLAY", value);
  }

  String get rating => box.read("GRADE") ?? "ecchi";

  set rating(String? value) {
    box.write("GRADE", value);
  }

  bool get detailPageVersion => box.read('ISNEWER') ?? true ;
  set detailPageVersion(bool value) {
    box.write('ISNEWER', value);
  }

  bool get imgViewVersion => box.read('IMGVIEW') ?? true ;
  set imgViewVersion(bool value) {
    box.write('IMGVIEW', value);
  }

  int? get maxDownloadRecords => box.read('MAX_DOWNLOAD_RECORDS');
  set maxDownloadRecords(int? value) {
    box.write('MAX_DOWNLOAD_RECORDS', value);
  }

  int? get maxHistoryRecords => box.read('MAX_HISTORY_RECORDS');
  set maxHistoryRecords(int? value) {
    box.write('MAX_HISTORY_RECORDS', value);
  }

  Settings();
}

class HistoryVideo{
  Map<String, dynamic>? historyVInfo;
  DateTime viewTime;
  HistoryVideo(this.historyVInfo, this.viewTime);

  factory HistoryVideo.fromJson(Map<String, dynamic> json) {
    return HistoryVideo(json['historyVInfo'], DateTime.parse(json['viewTime']));
  }

  Map<String, dynamic> toJson() => {
    'historyVInfo': historyVInfo,
    'viewTime': viewTime.toIso8601String(),
  };
}

class MyDownloadTask extends DownloadTask {
  MyDownloadTask({required super.taskId, required super.status, required super.progress, required super.url, required super.filename, required super.savedDir, required super.timeCreated, required super.allowCellular});

  factory MyDownloadTask.fromJson(Map<String, dynamic> json) {
    return MyDownloadTask(
      taskId: json['taskId'],
      status: DownloadTaskStatus.fromInt(json['status']),
      progress: json['progress'],
      url: json['url'],
      filename: json['filename'],
      savedDir: json['savedDir'],
      timeCreated: json['timeCreated'],
      allowCellular: json['allowCellular'],
    );
  }

  factory MyDownloadTask.fromDownloadTask(DownloadTask task) {
    return MyDownloadTask(
      taskId: task.taskId,
      status: task.status,
      progress: task.progress,
      url: task.url,
      filename: task.filename,
      savedDir: task.savedDir,
      timeCreated: task.timeCreated,
      allowCellular: task.allowCellular,
    );
  }

  Map<String, dynamic> toJson() => {
    'taskId': taskId,
   'status': statusAsInt,
    'progress': progress,
    'url': url,
    'filename': filename,
   'savedDir': savedDir,
    'timeCreated': timeCreated,
    'allowCellular': allowCellular,
  };
  // 将状态转换为整数值
  int get statusAsInt {
    switch (status) {
      case DownloadTaskStatus.undefined:
        return 0;
      case DownloadTaskStatus.enqueued:
        return 1;
      case DownloadTaskStatus.running:
        return 2;
      case DownloadTaskStatus.complete:
        return 3;
      case DownloadTaskStatus.failed:
        return 4;
      case DownloadTaskStatus.canceled:
        return 5;
      case DownloadTaskStatus.paused:
        return 6;
    }
  }
}

final storeController = Get.find<StoreController>();
