
import 'dart:async';

import 'package:flutter/services.dart';

class DirectoryManager {
  static const MethodChannel _channel = MethodChannel('com.qwer/storage');

  static Future<String> getDCIMDirectory() async {
    final String path = await _channel.invokeMethod('getDCIMPath');
    print(path);
    return "$path/qwara";
  }

  static Future<String> getPictureDirectory() async {
    final String path = await _channel.invokeMethod('getpicturesPath');
    print(path);
    return "$path/qwara";
  }

  static Future<String> getMoviesDirectory() async {
    final String path = await _channel.invokeMethod('getmoviesPath');
    print(path);
    return "$path/qwara";
  }

  static Future<void> scanFile(String filePath) async {
    await _channel.invokeMethod('scanFile',{'filePath': filePath});
  }
}
