//清晰度
enum Clarity {
  source("Source"),
  medium("540"),
  low("360");

  final String value;
  const Clarity(this.value);

}
//排序方式
enum SortType {
  date("date", "日期"),
  popularity("popularity", "人气"),
  trending("trending", "流行"),
  view("views", "观看"),
  like("likes", "喜欢");

  final String value;   // 英文参数
  final String label;   // 中文标签

  const SortType(this.value, this.label);
}

enum SearchType {
  video("video", "视频"),
  image("image", "图片"),
  user("user","用户"),
  nothing("nothing","");

  final String value;
  final String label;
  const SearchType(this.value, this.label);
}