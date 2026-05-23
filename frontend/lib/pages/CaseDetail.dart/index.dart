import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/api/case.dart';
import 'package:frontend/api/file.dart';
import 'package:frontend/components/CaseDetail/AllDocumentsView.dart';
import 'package:frontend/components/CaseDetail/DetailView.dart';
import 'package:frontend/components/CaseDetail/BottomNavigation.dart';
import 'package:frontend/components/CaseDetail/EditCaseDialog.dart';
import 'package:frontend/components/CaseDetail/CategoryPicker.dart';
import 'package:frontend/components/CaseDetail/TextInputDialog.dart';
import 'package:frontend/components/CaseDetail/ChatDialog.dart';
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
  int _selectedBottomIndex = 2;

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

  Future<void> _updateCase(Map<String, dynamic> data) async {
    if (_caseId == null) return;
    try {
      final res = await updateCaseAPI(_caseId, data);
      setState(() {
        _caseDetail = res;
      });
      if (mounted) {
        Toastutils.showToast(context, "保存成功");
      }
    } catch (e) {
      if (mounted) {
        Toastutils.showToast(context, "保存失败: ${e}");
      }
    }
  }

  Future<void> _deleteCase() async {
    if (_caseId == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("确认删除"),
        content: const Text("删除后将无法恢复，确定要删除这个案件吗？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("删除", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await deleteCaseAPI(_caseId);
      if (mounted) {
        Toastutils.showToast(context, "删除成功");
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Toastutils.showToast(context, "删除失败: ${e}");
      }
    }
  }

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

  Future<String?> _showCategoryPicker() async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CategoryPicker(categories: _categories),
    );
  }

  Future<void> _showEditDialog() async {
    if (_caseDetail == null) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EditCaseDialog(
        caseDetail: _caseDetail!,
        onSave: _updateCase,
      ),
    );
  }

  Future<void> _showTextInputDialog() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TextInputDialog(
        categories: _categories,
        onSave: (text, category) async {
          await _createMaterial(
            name: "文本记录",
            category: category,
            content: text,
          );
        },
      ),
    );
  }

  Future<void> _handleFileUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
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
        Toastutils.showToast(context, "上传失败: ${e}");
      }
    }
  }

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

  Future<void> _showChatDialog() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChatDialog(caseId: _caseId is int ? _caseId as int : null),
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
            //删除
            IconButton(
              onPressed: _deleteCase,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
            IconButton(
              onPressed: _showEditDialog,
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
        bottomNavigationBar: BottomNavigation(
          selectedIndex: _selectedBottomIndex,
          onItemTap: (index) {
            setState(() {
              _selectedBottomIndex = index;
            });
          },
          onMicTap: () => Toastutils.showToast(context, "录音开发中..."),
          onImageTap: _handleImageUpload,
          onChatTap: _showChatDialog,
          onTextTap: _showTextInputDialog,
          onFileTap: _handleFileUpload,
        ),
      ),
    );
  }
}
