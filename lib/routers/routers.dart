
import 'package:flutter/material.dart';
import 'package:qwara/main.dart';
import 'package:qwara/pages/FollowerPage.dart';
import 'package:qwara/pages/login/login.dart';
import 'package:qwara/pages/userInfo/PlayList.dart';
import 'package:qwara/pages/userInfo/PlayListDetail.dart';
import 'package:qwara/pages/userInfo/userProfile/UserProfile.dart';
import 'package:qwara/pages/videoDetail/videoDetail.dart';
import 'package:qwara/pages//videosPage//VideosPage.dart';
import 'package:qwara/pages/videosPage/Favorites.dart';

import '../pages/image/ImageDetail.dart';

final Map routes = {
  "/home":(context)=>const MyHomePage(),
  "/recommend":(context)=>const VideosPage(),
  "/videoDetail":(context,{arguments})=>VideoDetail(videoInfo: arguments),
  "/imageDetail":(context,{arguments})=>ImageDetail(imageInfo: arguments),
  "/login":(context)=> const LoginPage(),
  "/userProfile":(context,{arguments})=>UserProfile(user: arguments),
  "/followPage":(context,{arguments})=>FollowerPage(index: arguments),
  "/toPlaylist":(context)=>const PlayListPage(),
  "/playListDetail":(context,{arguments})=>PlayListDetail(playlist: arguments),
  "/favorites":(context)=>const FavoritesPage(),
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
