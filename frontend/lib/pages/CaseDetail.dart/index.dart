import 'package:flutter/material.dart';
import 'package:frontend/api/case.dart';
import 'package:frontend/components/CaseDetail/AllDocumentsView.dart';
import 'package:frontend/components/CaseDetail/DetailView.dart';
import 'package:frontend/viewmodels/case.dart' as vm;

class CaseDetail extends StatefulWidget {
  CaseDetail({Key? key}) : super(key: key);

  @override
  _CaseDetailState createState() => _CaseDetailState();
}

class _CaseDetailState extends State<CaseDetail> {
  dynamic _caseId;
  vm.CaseDetail? _caseDetail;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && _caseId == null) {
      _caseId = args;
      _getCaseDetails();
    }
  }

  Future<void> _getCaseDetails() async {
    if (_caseId == null) return;
    try {
      final res = await getCaseDetailAPI(_caseId);
      setState(() {
        _caseDetail = res;
      });
    } catch (e) {
      print("加载详情失败: $e");
    }
  }

  // 构建底部操作栏项
  Widget _buildBottomItem(IconData icon, String label, {bool isSelected = false}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Icon(
          icon,
          size: 28,
          color: isSelected ? Colors.blue : Colors.grey,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.edit_note, color: Colors.blue)),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.blue, // 选中下划线颜色改为蓝色
            labelColor: Colors.blue, // 选中文字颜色改为蓝色
            unselectedLabelColor: Colors.grey, // 未选中文字颜色改为灰色
            tabs: [
              Tab(text: "案件概述"),
              Tab(text: "全部文档"),
            ],
          ),
          backgroundColor: const Color(0xFFF5F7FA),
          title: Text(_caseDetail?.title ?? "案件详情"),
        ),
        body: TabBarView(
          children: [
            DetailView(caseDetail: _caseDetail),
            AllDocumentsContent(),
          ],
        ),
        // 添加底部操作栏
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          height: 70, // 底部栏高度
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomItem(Icons.mic, "录音"),
                _buildBottomItem(Icons.image, "图片"),
                _buildBottomItem(Icons.chat_bubble, "AI对话", isSelected: true),
                _buildBottomItem(Icons.notes, "文本"),
                _buildBottomItem(Icons.upload_file, "文件"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
