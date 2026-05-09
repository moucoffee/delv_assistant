import 'package:flutter/material.dart';

class AllDocumentsContent extends StatefulWidget {
  AllDocumentsContent({Key? key}) : super(key: key);

  @override
  _AllDocumentsContentState createState() => _AllDocumentsContentState();
}

class _AllDocumentsContentState extends State<AllDocumentsContent> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("全部文档"),);
  }
}