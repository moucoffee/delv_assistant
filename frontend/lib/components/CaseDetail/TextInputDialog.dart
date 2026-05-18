//文本录入对话框
import 'package:flutter/material.dart';

class TextInputDialog extends StatefulWidget {
  final List<Map<String, String>> categories;
  final Function(String, String) onSave;

  const TextInputDialog({
    Key? key,
    required this.categories,
    required this.onSave,
  }) : super(key: key);

  @override
  _TextInputDialogState createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  String _inputText = "";
  String _selectedCategory = "";

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categories[0]["key"] ?? "case";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F7FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "取消",
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ),
                  const Text(
                    "文字录入",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_inputText.trim().isNotEmpty) {
                        widget.onSave(_inputText, _selectedCategory);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "保存",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  autofocus: true,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "请输入文本内容...",
                  ),
                  onChanged: (val) => _inputText = val,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "归档分类",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    DropdownButton<String>(
                      value: _selectedCategory,
                      items: widget.categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat["key"],
                          child: Text(
                            cat["label"] ?? "",
                            style: const TextStyle(color: Colors.blue),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCategory = val;
                          });
                        }
                      },
                      underline: Container(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
