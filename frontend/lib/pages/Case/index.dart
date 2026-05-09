import 'package:flutter/material.dart';
import 'package:frontend/api/case.dart';
import 'package:frontend/components/Case/CaseList.dart';
import 'package:frontend/components/Case/Search.dart';
import 'package:frontend/components/Case/Title.dart';
import 'package:frontend/viewmodels/case.dart' as vm;

class CaseView extends StatefulWidget {
  CaseView({Key? key}) : super(key: key);

  @override
  _CaseViewState createState() => _CaseViewState();
}

class _CaseViewState extends State<CaseView> {
  List<vm.Case> _allCases = []; // 存储所有原始数据
  List<vm.Case> _displayCases = []; // 存储当前显示的过滤数据
  bool _isLoading = true;
  bool _isSearching = false; // 新增：记录当前是否正在搜索

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // 统一请求数据
  Future<void> _fetchData() async {
    try {
      final data = await getCaseListAPI();
      setState(() {
        _allCases = data;
        _displayCases = data;
        _isLoading = false;
      });
    } catch (e) {
      print("获取数据失败: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 搜索过滤逻辑
  void _onSearchChanged(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        _displayCases = _allCases;
        _isSearching = false; // 关键字为空，重置搜索状态
      } else {
        _isSearching = true; // 开启搜索状态
        _displayCases = _allCases.where((item) {
          final titleMatch = item.parties.toLowerCase().contains(keyword.toLowerCase());
          final partiesMatch = item.parties.toLowerCase().contains(keyword.toLowerCase());
          final typeMatch = item.case_type.toLowerCase().contains(keyword.toLowerCase());
          return titleMatch || partiesMatch || typeMatch;
        }).toList();
      }
    });
  }

  List<Widget> _getScrollChidren() {
    return [
      SliverToBoxAdapter(child: MyTitle()),
      SliverToBoxAdapter(child: SizedBox(height: 10)),
      SliverToBoxAdapter(
        child: MySearch(onChanged: _onSearchChanged),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 10)),
      CaseList(
        cases: _displayCases,
        isLoading: _isLoading,
        isSearching: _isSearching, // 传递搜索状态
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: CustomScrollView(slivers: _getScrollChidren()),
    );
  }
}
