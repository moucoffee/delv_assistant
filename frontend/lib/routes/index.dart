import 'package:flutter/material.dart';
import 'package:frontend/pages/CaseDetail.dart/index.dart';
import 'package:frontend/pages/Main/index.dart';

Widget getRootWidget() {
  return MaterialApp(
    initialRoute: "/",
    routes: getRootRoutes(),
  );
}

Map<String, Widget Function(BuildContext)> getRootRoutes () {
  return {
    "/" : (context) => MainPage(),
    "/casedetail" : (context) => CaseDetail(),
  }; 
}