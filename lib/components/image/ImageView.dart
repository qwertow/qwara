
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qwara/constant.dart';
import 'package:qwara/getX/StoreController.dart';
import 'package:get/get.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:qwara/utils/DownLoadUtil.dart';

final storeController = Get.find<StoreController>();

class ImageView extends StatefulWidget {
  const ImageView({super.key, required this.fileList, this.height, this.width});
  final List fileList;
  final double? height;
  final double? width;

  @override
  State<ImageView> createState() => ImageViewState();
}

class ImageViewState extends State<ImageView>{
  static const String originPrefix="https://i.iwara.tv/image/original/";
  static const String largePrefix="https://i.iwara.tv/image/large/";
  List initFileList = [];
  double? imgWidth;
  double? imgHeight;
  late List<double?> _widthList;
  // int imgLength = 0;

  String getSuffix(String str){
    return str.split("/").last;
  }

  final PageController _pageController = PageController();

  final List<String> _fileList = [];
  Future<void> getFileUrls() async {
    print("ImageViewState getFileUrls ${initFileList.isEmpty}");
    int i = 0;
    while(initFileList.isEmpty){
      print("ImageViewState getFileUrls ${initFileList.isEmpty}");

      await Future.delayed(const Duration(milliseconds: 100), () {
        print(i);
        initFileList.addAll(widget.fileList);
      });
      i++;
      if (i > 10 * 10) {
        Fluttertoast.showToast(msg: "url获取超时");
        break;
      }
    }

    setState(() {
      _fileList.clear();
      _fileList.addAll(widget.fileList.map((e){
        return "${e['id']}/${e['name']}";
      }).toList());
      // imgLength = ;
      _widthList = List<double?>.generate(_fileList.length, (index) => 0.0 );
      _widthList[0]=null;
    });

  }

  @override
  void initState() {
    super.initState();
    getFileUrls();
    // Timer(const Duration(seconds: 10), () {
    //   //到时回调
    //   _changeHeight();
    // });
  }

  @override
  void didUpdateWidget(covariant ImageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.fileList, initFileList)) {
      getFileUrls();
    }
  }

  @override
  void dispose() {
    super.dispose();
    // _pageController.dispose();
  }
  bool heightChange = true;
  void _changeHeight(){
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        heightChange =!heightChange;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    // print("ImageView build $_fileList ${widget.fileList}");
    // return Row(
    //
    // );
    return  Wrap(
      // alignment: ,
      children: _fileList.asMap().map((index, url) {
        return MapEntry(
            index,
            GestureDetector(
              onHorizontalDragEnd: (details){
                setState(() {

                });
              },
                onHorizontalDragUpdate: (details){
                  if(details.delta.dx>0){
                    //向右滑动
                    if(index>0){
                      if(index!=_widthList.length-1){
                        _widthList[index+1]=0;
                      }

                      _widthList[index]=0;
                      _widthList[index-1]=null;
                    }
                  }else{
                    if(index<_widthList.length-1){
                      if(index!=0){
                        _widthList[index-1]=0;
                      }

                      _widthList[index]=0;
                      _widthList[index+1]=null;
                    }
                  }
                },
                child:AnimatedSize(duration: const Duration(milliseconds: 300),child: InstaImageViewer(
                  imageUrl: originPrefix + url,
                  headers: IMG_HEADERS,
                  child: SizedBox(
                    width: _widthList[index],
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          largePrefix + url,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (ctx, err, stackTrace) => Image.asset(
                            'assets/images/780.jfif', // 默认显示图片
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: IconButton(
                            onPressed: () async {
                              await beforeDownload();
                              if(await downloading(originPrefix + url, widget.fileList[index]['name'])) {
                                moveToAlbum(widget.fileList[index]['name']);
                              }
                            },
                            icon: const Icon(
                              Icons.download,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),))
        );
      }).values.toList(),

    );
    // return CarouselSlider(
    //   options: CarouselOptions(),
    //   items: _fileList.asMap().map((index, url) {
    //     return MapEntry(
    //       index,
    //       Stack(
    //         alignment: Alignment.center,
    //         children: [
    //           AnimatedSize(duration: Duration(milliseconds: 300),child: InstaImageViewer(
    //             imageUrl: originPrefix + url,
    //             headers: IMG_HEADERS,
    //             child: Image.network(
    //               largePrefix + url,
    //               fit: BoxFit.cover,
    //               loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    //                 if (loadingProgress == null) {
    //                   return child;
    //                 }
    //                 return Center(
    //                   child: CircularProgressIndicator(
    //                     value: loadingProgress.expectedTotalBytes != null
    //                         ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
    //                         : null,
    //                   ),
    //                 );
    //               },
    //               errorBuilder: (ctx, err, stackTrace) => Image.asset(
    //                 'assets/images/780.jfif', // 默认显示图片
    //               ),
    //             ),
    //           ),),
    //           Positioned(
    //             bottom: 10,
    //             right: 10,
    //             child: IconButton(
    //               onPressed: () async {
    //                 await beforeDownload();
    //                 if(await downloading(originPrefix + url, widget.fileList[index]['name'])) {
    //                   moveToAlbum(widget.fileList[index]['name']);
    //                 }
    //               },
    //               icon: const Icon(
    //                 Icons.download,
    //                 color: Colors.white,
    //                 size: 30,
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     );
    //   }).values.toList()
    // );
    // return AutoHeightPageView(
    //   // reHeight: heightChange,
    //   pageController: _pageController,
    //   children: _fileList.asMap().map((index, url) {
    //     return MapEntry(
    //       index,
    //         Stack(
    //           alignment: Alignment.center,
    //           children: [
    //             InstaImageViewer(
    //               imageUrl: originPrefix + url,
    //               headers: IMG_HEADERS,
    //               child: Image.network(
    //                 largePrefix + url,
    //                 fit: BoxFit.cover,
    //                 loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    //                   if (loadingProgress == null) {
    //                     return child;
    //                   }
    //                   return Center(
    //                     child: CircularProgressIndicator(
    //                       value: loadingProgress.expectedTotalBytes != null
    //                           ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
    //                           : null,
    //                     ),
    //                   );
    //                 },
    //                 errorBuilder: (ctx, err, stackTrace) => Image.asset(
    //                   'assets/images/780.jfif', // 默认显示图片
    //                 ),
    //               ),
    //             ),
    //             Positioned(
    //               bottom: 10,
    //               right: 10,
    //               child: IconButton(
    //                 onPressed: () async {
    //                   await beforeDownload();
    //                   if(await downloading(originPrefix + url, widget.fileList[index]['name'])) {
    //                     moveToAlbum(widget.fileList[index]['name']);
    //                   }
    //                 },
    //                 icon: const Icon(
    //                   Icons.download,
    //                   color: Colors.white,
    //                   size: 30,
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //     );
    //   }).values.toList(), // 将 MapEntry 的值转换为 List
    // );
  }
}
