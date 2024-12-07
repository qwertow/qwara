import 'package:intl/intl.dart';

String formatDuration(int milliseconds) {
  // 将毫秒转换为秒
  double totalSeconds = milliseconds / 1000;

  // 计算分钟和秒
  int minutes = (totalSeconds / 60).round();
  int seconds = (totalSeconds % 60).round();

  // 使用 sprintf 或其他格式化方法确保输出格式为分钟:秒，且秒数始终是两位数
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

String formatDate(String dateString) {
  DateTime dateTime = DateTime.parse(dateString); // 将日期字符串解析为 DateTime 对象
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime); // 格式化日期
}