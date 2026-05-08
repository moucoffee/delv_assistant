import 'package:flutter/material.dart';

class MyTitle extends StatefulWidget {
  MyTitle({Key? key}) : super(key: key);

  @override
  _MyTitleState createState() => _MyTitleState();
}

class _MyTitleState extends State<MyTitle> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      alignment: Alignment.centerLeft,
       child: Text("案件管理", style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w700
       ),),
    );
  }
}