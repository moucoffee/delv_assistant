import 'package:flutter/material.dart';

class ToolsView extends StatefulWidget {
  ToolsView({Key? key}) : super(key: key);

  @override
  _ToolsViewState createState() => _ToolsViewState();
}

class _ToolsViewState extends State<ToolsView> {
  @override
  Widget build(BuildContext context) {
    return Center(
       child: Text("工具")
    );
  }
}