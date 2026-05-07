import 'package:flutter/material.dart';

class CaseView extends StatefulWidget {
  CaseView({Key? key}) : super(key: key);

  @override
  _CaseViewState createState() => _CaseViewState();
}

class _CaseViewState extends State<CaseView> {
  @override
  Widget build(BuildContext context) {
    return Center(
       child: Text("案件"),
    );
  }
}