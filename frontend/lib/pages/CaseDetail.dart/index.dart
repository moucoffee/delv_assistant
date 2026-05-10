import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/api/case.dart';
import 'package:frontend/components/CaseDetail/AllDocumentsView.dart';
import 'package:frontend/components/CaseDetail/DetailView.dart';
import 'package:frontend/utils/ToastUtils.dart';
import 'package:frontend/viewmodels/case.dart' as vm;

class CaseDetail extends StatefulWidget {
  CaseDetail({Key? key}) : super(key: key);

  @override
  _CaseDetailState createState() => _CaseDetailState();
}

class _CaseDetailState extends State<CaseDetail> {
  dynamic _caseId;
  vm.CaseDetail? _caseDetail;

  // 底部导航栏选中状态
  int _selectedBottomIndex = 2;

  // 分类选项
  final List<Map<String, String>> _categories = [
    {"key": "case", "label": "案件材料"},
    {"key": "evidence", "label": "举证材料"},
    {"key": "payment", "label": "付款记录"},
    {"key": "notice", "label": "法院通知"},
  ];

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

  // 弹出分类选择对话框
  Future<String?> _showCategoryPicker() async {
    String? selectedCategory = _categories[0]["key"];

    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
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
                  // 顶部标题栏
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
                        "材料归档",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, selectedCategory),
                        child: const Text(
                          "保存",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "归档分类",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 分类列表
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: _categories.map((cat) {
                        final isSelected = selectedCategory == cat["key"];
                        return ListTile(
                          title: Text(cat["label"] ?? ""),
                          trailing: isSelected
                              ? const Icon(Icons.check, color: Colors.blue)
                              : null,
                          onTap: () {
                            setModalState(() {
                              selectedCategory = cat["key"];
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  //弹出文本录入对话框
  Future<void> _showTextInputDialog() async {
    String inputText = "";
    String selectedCategory = _categories[0]["key"] ?? "case";

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
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
                    // 顶部标题栏
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "取消",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Text(
                          "文字录入",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (inputText.trim().isEmpty) return;
                            Navigator.pop(context);
                            await _createMaterial(
                              name: "文本记录",
                              category: selectedCategory,
                              content: inputText,
                            );
                          },
                          child: const Text(
                            "保存",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 文本输入框
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
                        onChanged: (val) {
                          inputText = val;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 底部分类选择
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
                            value: selectedCategory,
                            items: _categories.map((cat) {
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
                                setModalState(() {
                                  selectedCategory = val;
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
        },
      ),
    );
  }

  //创建材料
  Future<void> _createMaterial({
    required String name,
    required String category,
    String? fileUrl,
    String? content,
    String fileSize = "0B",
  }) async {
    if (_caseId == null) return;

    try {
      await createMaterialAPI({
        "case_id": _caseId,
        "category": category,
        "name": name,
        "file_url": fileUrl,
        "content": content,
        "file_size": fileSize,
      });

      if (mounted) {
        Toastutils.showToast(context, "材料保存成功");
        await _getCaseDetails();
      }
    } catch (e) {
      if (mounted) {
        Toastutils.showToast(context, "材料保存失败: ${e}");
      }
    }
  }

  //处理文件上传按钮点击
  Future<void> _handleFileUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    //选分类
    final category = await _showCategoryPicker();
    if (category == null) return;

    //上传文件
    try {
      PlatformFile file = result.files.first;
      MultipartFile? multipartFile;

      if (file.bytes != null) {
        // Web 端支持
        multipartFile = MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
        );
      } else if (file.path != null) {
        // 移动端支持
        multipartFile = await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        );
      }

      if (multipartFile == null) return;

      final fileUrl = await uploadFileAPI(multipartFile);

      //创建材料
      await _createMaterial(
        name: file.name,
        category: category,
        fileUrl: fileUrl,
        fileSize: "${(file.size / 1024).toStringAsFixed(1)}KB",
      );
    } catch (e) {
      if (mounted) {
        Toastutils.showToast(context, "上传失败: ${e}");
      }
    }
  }

  //处理图片按钮点击（与文件类似，只选择图片）
  Future<void> _handleImageUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result == null) return;

    final category = await _showCategoryPicker();
    if (category == null) return;

    try {
      PlatformFile file = result.files.first;
      MultipartFile? multipartFile;

      if (file.bytes != null) {
        multipartFile = MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
        );
      } else if (file.path != null) {
        multipartFile = await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        );
      }

      if (multipartFile == null) return;

      final fileUrl = await uploadFileAPI(multipartFile);

      await _createMaterial(
        name: file.name,
        category: category,
        fileUrl: fileUrl,
        fileSize: "${(file.size / 1024).toStringAsFixed(1)}KB",
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("图片上传失败: $e")));
      }
    }
  }

  // 构建底部操作栏项
  Widget _buildBottomItem(
    IconData icon,
    String label, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: isSelected ? Colors.blue : Colors.grey),
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
              icon: const Icon(Icons.edit_note, color: Colors.blue),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.blue, 
            labelColor: Colors.blue, 
            unselectedLabelColor: Colors.grey, 
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
                _buildBottomItem(
                  Icons.mic,
                  "录音",
                  isSelected: _selectedBottomIndex == 0,
                  onTap: () {
                    setState(() {
                      _selectedBottomIndex = 0;
                    });
                    Toastutils.showToast(context, "录音开发中...");
                  },
                ),
                _buildBottomItem(
                  Icons.image,
                  "图片",
                  isSelected: _selectedBottomIndex == 1,
                  onTap: () {
                    setState(() {
                      _selectedBottomIndex = 1;
                    });
                    _handleImageUpload();
                  },
                ),
                _buildBottomItem(
                  Icons.chat_bubble,
                  "AI对话",
                  isSelected: _selectedBottomIndex == 2,
                  onTap: () {
                    setState(() {
                      _selectedBottomIndex = 2;
                    });
                    Toastutils.showToast(context, "AI对话开发中...");
                  },
                ),
                _buildBottomItem(
                  Icons.notes,
                  "文本",
                  isSelected: _selectedBottomIndex == 3,
                  onTap: () {
                    setState(() {
                      _selectedBottomIndex = 3;
                    });
                    _showTextInputDialog();
                  },
                ),
                _buildBottomItem(
                  Icons.upload_file,
                  "文件",
                  isSelected: _selectedBottomIndex == 4,
                  onTap: () {
                    setState(() {
                      _selectedBottomIndex = 4;
                    });
                    _handleFileUpload();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
