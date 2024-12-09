import 'package:qwara/utils/DirectoryManager.dart';
import 'package:sizer/sizer.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qwara/constant.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:qwara/utils/DownLoadUtil.dart';
import '../../getX/StoreController.dart';

class ImageView extends StatefulWidget {
  const ImageView({super.key, required this.fileList, this.height, this.width});
  final List<Map<String, dynamic>> fileList;
  final double? height;
  final double? width;

  @override
  State<ImageView> createState() => ImageViewState();
}

// {
// "id": "a0d2812f-2012-4682-b3a2-2d4f892ac1d7",
// "type": "image",
// "path": "2024/11/27",
// "name": "a0d2812f-2012-4682-b3a2-2d4f892ac1d7.webm",
// "mime": "video/webm",
// "size": 1934510,
// "width": 1600,
// "height": 900,
// "duration": null,
// "numThumbnails": null,
// "animatedPreview": false,
// "createdAt": "2024-11-27T16:34:28.000Z",
// "updatedAt": "2024-11-27T16:35:07.000Z"
// }
class ImgFile {
  String id;
  String type;
  String path;
  String name;
  String mime;
  int size;
  int width;
  int height;
  int? duration;
  int? numThumbnails;
  bool animatedPreview;
  String createdAt;
  String updatedAt;

  ImgFile({required this.id, required this.type, required this.path, required this.name, required this.mime, required this.size, required this.width, required this.height, required this.duration, required this.numThumbnails, required this.animatedPreview, required this.createdAt, required this.updatedAt});

  factory ImgFile.fromJson(Map<String, dynamic> json) {
    return ImgFile(
        id: json['id'],
        type: json['type'],
        path: json['path'],
        name: json['name'],
        mime: json['mime'],
        size: json['size'],
        width: json['width'] ?? 60.w.toInt(),
        height: json['height'] ?? 30.h.toInt(),
        duration: json['duration'],
        numThumbnails: json['numThumbnails'],
        animatedPreview: json['animatedPreview'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt']
    );
  }
}

class ImageViewState extends State<ImageView>{
  static const String originPrefix="https://i.iwara.tv/image/original/";
  static const String largePrefix="https://i.iwara.tv/image/large/";
  List initFileList = [];
  double? imgWidth;
  double? imgHeight=200;
  int imgIndex = 0;

  bool isNewer = storeController.settings.imgViewVersion;

  late List<double?> _widthList;
  late final List<ImgFile> _fileList=[];
  // int imgLength = 0;

  String getSuffix(String str){
    return str.split("/").last;
  }

  // final List<String> _fileList = [];
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
        return ImgFile.fromJson(e);
      }).toList());
      _widthList = List<double?>.generate(_fileList.length, (index) => 0.0 );
      _widthList[0]=null;
    });

  }

  @override
  void initState() {
    super.initState();
    getFileUrls();
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


  @override
  Widget build(BuildContext context) {
    if(isNewer){
      return ConstrainedBox(constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height*0.5,
      ),
          child: AnimatedSize(duration: const Duration(milliseconds: 250),child: Stack(
            children: [

              Opacity(
                opacity: 0.0,
                child: AspectRatio(
                    aspectRatio:_fileList.isEmpty? (16/9) :  (_fileList[imgIndex].width / _fileList[imgIndex].height),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final mheight = constraints.maxHeight;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          print("ImageViewStat build  $mheight");
                          if (imgHeight!= mheight) {
                            setState(() {
                              imgHeight = mheight; // 更新高度
                            });
                          }
                        });
                        return _fileList.isEmpty? Container() :  Image.network(
                          "$largePrefix${_fileList[imgIndex].id}/${_fileList[imgIndex].name}",
                          fit: BoxFit.fitHeight,
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
                        );
                      },
                    )),
              ),

              SizedBox(
                height: imgHeight,
                child: PageView.builder(
                  itemCount: _fileList.length,
                  onPageChanged: (index){
                    setState(() {
                      imgIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    ImgFile img = _fileList[index];

                    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
                    int dotIndex = img.name.lastIndexOf('.');
                    String fileNameWithTimestamp= img.name ;
                    if (dotIndex!= -1) {
                      fileNameWithTimestamp = "${img.name.substring(0, dotIndex)}_$timestamp${img.name.substring(dotIndex)}";
                    }

                    return InstaImageViewer(
                      imageUrl: "$originPrefix${img.id}/${img.name}",
                      headers: IMG_HEADERS,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: img.width / img.height,
                            child:  Image.network(
                              "$largePrefix${img.id}/${img.name}",
                              fit: BoxFit.fitHeight,
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
                          ),

                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: IconButton(
                              onPressed: () async {
                                downLoadHelper.createDownloadTak(
                                    await DirectoryManager.getPictureDirectory(),
                                    "$originPrefix${img.id}/${img.name}",
                                    fileNameWithTimestamp);
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
                    );
                  },
                ),
              ),
            ],
          )),);
    }else{
      return  Wrap(
        direction: Axis.horizontal,
        children: _fileList.asMap().map((index, img) {
          String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
          int dotIndex = img.name.lastIndexOf('.');
          String fileNameWithTimestamp= img.name ;
          if (dotIndex!= -1) {
            fileNameWithTimestamp = "${img.name.substring(0, dotIndex)}_$timestamp${img.name.substring(dotIndex)}";
          }
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
                  child:AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    alignment: Alignment.center,
                    child: InstaImageViewer(
                      imageUrl: "$originPrefix${img.id}/${img.name}",
                      headers: IMG_HEADERS,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ConstrainedBox(constraints: BoxConstraints(
                            maxWidth: _widthList[index] ?? double.infinity,
                            maxHeight: MediaQuery.of(context).size.height*0.5,
                          ),
                            child: AspectRatio(
                              aspectRatio: img.width / img.height,
                              child: Image.network(
                                "$largePrefix${img.id}/${img.name}",
                                fit: BoxFit.fitHeight,
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
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: IconButton(
                              onPressed: () async {
                                // await beforeDownload(img.id);
                                // if(await downloading("$originPrefix${img.id}/${img.name}", fileNameWithTimestamp)) {
                                //   moveToAlbum(fileNameWithTimestamp);
                                // }
                                downLoadHelper.createDownloadTak(
                                    await DirectoryManager.getPictureDirectory(),
                                    "$originPrefix${img.id}/${img.name}",
                                    fileNameWithTimestamp);

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
                    ),))
          );
        }).values.toList(),
      );
    }
  }
}
