import 'package:flutter/material.dart';
import 'package:frontend/viewmodels/case.dart' as vm;

class DetailView extends StatefulWidget {
  final vm.CaseDetail? caseDetail; // 接收数据

  DetailView({Key? key, this.caseDetail}) : super(key: key);

  @override
  _DetailViewState createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  // 构造单行信息项（标签 + 值）
  Widget _buildItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E5E5)),
      ],
    );
  }

  // 构造双列信息项（如案件类型和案件状态并排）
  Widget _buildTwoColumnItem(String label1, String value1, String label2, String value2) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label1,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value1,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label2,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value2,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E5E5)),
      ],
    );
  }

  // 构造材料统计区域
  Widget _buildMaterialStats(Map<String, dynamic> stats) {
    final items = [
      {"title": "案件材料", "count": stats["case"]?.toString() ?? "0"},
      {"title": "举证材料", "count": stats["evidence"]?.toString() ?? "0"},
      {"title": "付款记录", "count": stats["payment"]?.toString() ?? "0"},
      {"title": "法院通知", "count": stats["notice"]?.toString() ?? "0"},
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 12),
            child: Text(
              "材料统计",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              return Expanded(
                child: Column(
                  children: [
                    // 图标占位，后续可替换为 Image.asset
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.folder, color: Colors.blue, size: 18), // 临时图标
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item["count"] ?? "0",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item["title"] ?? "",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.caseDetail == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = widget.caseDetail!;

    return Column(
      children: [
        // 1. 上方可滚动的案件详情主体
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题行（带图标占位）
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        // 标题图标占位
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.description, color: Colors.blue, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "案件详情",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E5E5)),
                  // 案件信息主体部分
                  _buildItem("案件标题", data.title ?? ""),
                  _buildItem("当事人", data.parties ?? ""),
                  _buildItem("联系电话", data.phone ?? ""),
                  _buildTwoColumnItem("案件类型", data.case_type ?? "", "案件状态", data.status ?? ""),
                  _buildItem("案件金额", data.amount ?? ""),
                  _buildItem("案件说明", data.description ?? ""),
                ],
              ),
            ),
          ),
        ),
        
        // 2. 固定在中间/底部的材料统计区域
        _buildMaterialStats(data.material_stats ?? {}),
      ],
    );
  }
}
