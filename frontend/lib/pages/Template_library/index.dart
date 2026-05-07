import 'package:flutter/material.dart';

class TemplateLibraryView extends StatefulWidget {
  TemplateLibraryView({Key? key}) : super(key: key);

  @override
  _TemplateLibraryViewState createState() => _TemplateLibraryViewState();
}

class _TemplateLibraryViewState extends State<TemplateLibraryView> {
  @override
  Widget build(BuildContext context) {
    return Center(
       child: Text("模版库"),
    );
  }
}