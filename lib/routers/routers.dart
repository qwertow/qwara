
import 'package:flutter/material.dart';
import 'package:qwara/login/login.dart';
import 'package:qwara/videoDetail/videoDetail.dart';

import '../home/home.dart';
import '../videosPage//VideosPage.dart';

final Map routes = {
  "/home":(context)=>Home(),
  "/recommend":(context)=>VideosPage(),
  "/detail":(context,{arguments})=>VideoDetail(videoInfo: arguments),
  "/login":(context)=> const LoginPage(),
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
