import 'package:flutter/material.dart';
import 'package:frontend/pages/CaseDetail.dart/index.dart';
import 'package:frontend/pages/Login/index.dart';
import 'package:frontend/pages/Main/index.dart';
import 'package:frontend/pages/Splash/index.dart';
import 'package:get/get.dart';

class RouteName {
  static const String SPLASH = "/splash";
  static const String MAIN = "/";
  static const String CASE_DETAIL = "/casedetail";
  static const String LOGIN = "/login";
}

Widget getRootWidget() {
  return GetMaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: RouteName.SPLASH,
    routes: getRootRoutes(),
  );
}

Map<String, Widget Function(BuildContext)> getRootRoutes () {
  return {
    RouteName.SPLASH: (context) => SplashPage(),
    RouteName.MAIN : (context) => MainPage(),
    RouteName.CASE_DETAIL : (context) => CaseDetail(),
    RouteName.LOGIN : (context) => LoginPage()
  }; 
}
