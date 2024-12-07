
import 'package:flutter/material.dart';
import 'package:qwara/main.dart';
import 'package:qwara/pages/FollowerPage.dart';
import 'package:qwara/pages/login/login.dart';
import 'package:qwara/pages/userInfo/History.dart';
import 'package:qwara/pages/userInfo/PlayList.dart';
import 'package:qwara/pages/userInfo/PlayListDetail.dart';
import 'package:qwara/pages/userInfo/userProfile/UserProfile.dart';
import 'package:qwara/pages/videoDetail/videoDetail.dart';
import 'package:qwara/pages/videosPage/Favorites.dart';

import '../pages/DownLoad.dart';
import '../pages/SearchPage.dart';
import '../pages/Settings.dart';
import '../pages/image/ImageDetail.dart';
import '../pages/image/ImagePage.dart';
import '../pages/videosPage/VideosPage.dart';

final Map routes = {
  "/home":(context)=>const MyHomePage(),
  "/videoPage":(context,{arguments})=>VideosPage(iniSortTag: arguments),
  "/imagePage":(context,{arguments})=>ImagePage(iniSortTag: arguments),
  "/videoDetail":(context,{arguments})=>VideoDetail(videoInfo: arguments),
  "/imageDetail":(context,{arguments})=>ImageDetail(imageInfo: arguments),
  "/login":(context)=> const LoginPage(),
  "/userProfile":(context,{arguments})=>UserProfile(user: arguments),
  "/followPage":(context,{arguments})=>FollowerPage(index: arguments),
  "/toPlaylist":(context)=>const PlayListPage(),
  "/playListDetail":(context,{arguments})=>PlayListDetail(playlist: arguments),
  "/favorites":(context)=>const FavoritesPage(),
  "/search":(context)=>const SearchPage(),
  "/settings":(context)=>const SettingsPage(),
  "/history":(context)=>const History(),
  "/download":(context)=>const DownloadPage(),
};

var onGenerateRoute=(RouteSettings settings){
  final String? name=settings.name;
  final Function? pageContentBuilder=routes[name];
  if(pageContentBuilder!=null){
    if(settings.arguments!=null){
      final Route route=MaterialPageRoute(
          builder: (context){
            return pageContentBuilder(context,arguments:settings.arguments);
          }
      );
      return route;
    }else{
      final Route route=MaterialPageRoute(
          builder: (context){
            return pageContentBuilder(context);
          }
      );
      return route;
    }
  }
  return null;
};
