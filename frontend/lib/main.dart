import 'package:flutter/cupertino.dart';
import 'package:frontend/routes/index.dart';
import 'package:frontend/stores/UserController.dart';
import 'package:get/get.dart';

void main(List<String> args) {
  Get.put(UserController());
  runApp(getRootWidget());
}
