import 'package:flutter/material.dart';
import 'package:frontend/api/case.dart';
import 'package:frontend/viewmodels/case.dart' as vm;

class CaseList extends StatefulWidget {
  CaseList({Key? key}) : super(key: key);

  @override
  _CaseListState createState() => _CaseListState();
}

class _CaseListState extends State<CaseList> {
  List<vm.Case> _cases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await getCaseListAPI();
      setState(() {
        _cases = data;
        _isLoading = false;
      });
    } catch (e) {
      print("加载数据失败: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_cases.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("暂无案件数据", style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final item = _cases[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildTag(item.case_type, Colors.blue.shade50, Colors.blue),
                        const SizedBox(width: 8),
                        _buildTag(item.status, Colors.green.shade50, Colors.green),
                      ],
                    ),
                    Text(item.create_at, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.parties, // 暂时用当事人作为标题
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text("当事人: ${item.parties}", style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.folder_open, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text("${item.material_count} 份材料", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(width: 12),
                        const Icon(Icons.storage, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(item.total_file_size, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(item.phone, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        childCount: _cases.length,
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
