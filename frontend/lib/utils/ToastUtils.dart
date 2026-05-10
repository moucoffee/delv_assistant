import 'package:flutter/material.dart';

class Toastutils {
  static bool showLoading = false;

  static void showToast(BuildContext context, String? msg) {
    if(Toastutils.showLoading) return ;
    showLoading = true;

    Future.delayed(Duration(seconds: 1), () => showLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      width: 150,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(40)
      ),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 1),
      content: Text(msg ?? "加载成功", textAlign: TextAlign.center,),
    ));
  }
}