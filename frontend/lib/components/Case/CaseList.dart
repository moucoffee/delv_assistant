import 'package:flutter/material.dart';
import 'package:frontend/viewmodels/case.dart' as vm;

class CaseList extends StatefulWidget {
  final List<vm.Case> cases;
  final bool isLoading;
  final bool isSearching; // 新增：是否处于搜索状态

  CaseList({
    Key? key,
    required this.cases,
    required this.isLoading,
    this.isSearching = false,
  }) : super(key: key);

  @override
  _CaseListState createState() => _CaseListState();
}

class _CaseListState extends State<CaseList> {
  // 上部：类型标签和时间
  Widget _getTop(vm.Case item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildTag(item.case_type, Colors.blue.shade50, Colors.blue),
            const SizedBox(width: 8),
            _buildTag(item.status, Colors.green.shade50, Colors.green),
          ],
        ),
        Text(item.create_at,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  // 中部：标题和当事人
  Widget _getCenter(vm.Case item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title, 
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "当事人: ${item.parties}",
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // 下部：材料统计和电话
  Widget _getBottom(vm.Case item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.folder_open, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text("${item.material_count} 份材料",
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(width: 12),
            const Icon(Icons.storage, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(item.total_file_size,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.phone, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(item.phone,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
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
        style: TextStyle(
            color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // 如果数据为空
    if (widget.cases.isEmpty) {
      if (widget.isSearching) {
        // 搜索中无结果，显示空白（返回一个空的 Sliver）
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      } else {
        // 初始状态就没有数据，显示暂无案件
        return const SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("暂无案件数据", style: TextStyle(color: Colors.grey)),
            ),
          ),
        );
      }
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final item = widget.cases[index];
          return GestureDetector(
            onTap: () {
              // 点击跳转到详情页
              Navigator.pushNamed(context, "/casedetail", arguments: item.id);
            },
            child: Container(
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
                  _getTop(item),
                  const SizedBox(height: 12),
                  _getCenter(item),
                  const SizedBox(height: 12),
                  _getBottom(item),
                ],
              ),
            ),
          );
        },
        childCount: widget.cases.length,
      ),
    );
  }
}
