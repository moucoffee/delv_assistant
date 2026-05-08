import 'package:flutter/material.dart';
import 'package:frontend/components/Case/CaseList.dart';
import 'package:frontend/components/Case/Search.dart';
import 'package:frontend/components/Case/Title.dart';

class CaseView extends StatefulWidget {
  CaseView({Key? key}) : super(key: key);

  @override
  _CaseViewState createState() => _CaseViewState();
}

class _CaseViewState extends State<CaseView> {
  List<Widget> _getScrollChidren() {
    return [
      SliverToBoxAdapter(child: MyTitle()),
      SliverToBoxAdapter(child: SizedBox(height: 10)),
      SliverToBoxAdapter(child: MySearch()),
      SliverToBoxAdapter(child: SizedBox(height: 10)),
      CaseList(), // 直接放入 SliverList，不需要 SliverToBoxAdapter 包装
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16), // 左右各留 16 像素
      child: CustomScrollView(slivers: _getScrollChidren()),
    );
  }
}
