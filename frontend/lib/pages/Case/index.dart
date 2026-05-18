import 'package:flutter/material.dart';
import 'package:frontend/api/case.dart';
import 'package:frontend/components/Case/CaseList.dart';
import 'package:frontend/components/Case/Search.dart';
import 'package:frontend/components/Case/Title.dart';
import 'package:frontend/utils/ToastUtils.dart';
import 'package:frontend/viewmodels/case.dart' as vm;

class CaseView extends StatefulWidget {
  CaseView({Key? key}) : super(key: key);

  @override
  _CaseViewState createState() => _CaseViewState();
}

class _CaseViewState extends State<CaseView> {
  List<vm.Case> _allCases = [];
  List<vm.Case> _displayCases = [];
  bool _isLoading = true;
  bool _isSearching = false;
  bool _isCreating = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _partiesController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _caseTypeController = TextEditingController(text: "刑事案件");
  final TextEditingController _statusController = TextEditingController(text: "新建");
  final TextEditingController _amountController = TextEditingController(text: "0");
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _partiesController.dispose();
    _phoneController.dispose();
    _caseTypeController.dispose();
    _statusController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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

  void _onSearchChanged(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        _displayCases = _allCases;
        _isSearching = false;
      } else {
        _isSearching = true;
        _displayCases = _allCases.where((item) {
          final titleMatch = item.parties.toLowerCase().contains(keyword.toLowerCase());
          final partiesMatch = item.parties.toLowerCase().contains(keyword.toLowerCase());
          final typeMatch = item.case_type.toLowerCase().contains(keyword.toLowerCase());
          return titleMatch || partiesMatch || typeMatch;
        }).toList();
      }
    });
  }

  Future<void> _createCase() async {
    bool isValid = true;
    
    if (_titleController.text.isEmpty) {
      isValid = false;
    }
    if (_partiesController.text.isEmpty) {
      isValid = false;
    }
    if (_phoneController.text.isEmpty || !RegExp(r"^1[3-9]\d{9}$").hasMatch(_phoneController.text)) {
      isValid = false;
    }
    if (_caseTypeController.text.isEmpty) {
      isValid = false;
    }
    
    if (!isValid) {
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final caseData = vm.CaseCreate(
        title: _titleController.text,
        parties: _partiesController.text,
        phone: _phoneController.text,
        case_type: _caseTypeController.text,
        status: _statusController.text,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      );

      await createCaseAPI(caseData);
      
      Toastutils.showToast(context, "创建成功");
      
      Navigator.pop(context);
      
      _clearForm();
      
      _fetchData();
    } catch (e) {
      Toastutils.showToast(context, e.toString().replaceFirst("DioException: ", ""));
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _partiesController.clear();
    _phoneController.clear();
    _caseTypeController.text = "刑事案件";
    _statusController.text = "新建";
    _amountController.text = "0";
    _descriptionController.clear();
  }

  void _showCreateDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "创建案件",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _CustomInputField(
                    label: "案件标题",
                    controller: _titleController,
                    placeholder: "请输入案件标题",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "案件标题不能为空";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _CustomInputField(
                    label: "当事人",
                    controller: _partiesController,
                    placeholder: "请输入当事人",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "当事人不能为空";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _CustomInputField(
                    label: "联系电话",
                    controller: _phoneController,
                    placeholder: "请输入联系电话",
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "联系电话不能为空";
                      }
                      if (!RegExp(r"^1[3-9]\d{9}$").hasMatch(value)) {
                        return "手机格式不正确";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _CustomInputField(
                    label: "案件类型",
                    controller: _caseTypeController,
                    placeholder: "请输入案件类型",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "案件类型不能为空";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _CustomInputField(
                    label: "案件状态",
                    controller: _statusController,
                    placeholder: "请输入案件状态",
                  ),
                  const SizedBox(height: 16),
                  _CustomInputField(
                    label: "案件金额",
                    controller: _amountController,
                    placeholder: "请输入案件金额",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _CustomInputField(
                    label: "案件说明",
                    controller: _descriptionController,
                    placeholder: "请输入案件说明（可选）",
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: _isCreating ? null : _createCase,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF3B82F6),
                            Color(0xFF60A5FA),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isCreating
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                "创建",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
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
        isSearching: _isSearching,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: CustomScrollView(slivers: _getScrollChidren()),
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: GestureDetector(
            onTap: _showCreateDialog,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF3B82F6),
                    Color(0xFF60A5FA),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomInputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _CustomInputField({
    required this.label,
    required this.controller,
    required this.placeholder,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  _CustomInputFieldState createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<_CustomInputField> {
  String? _errorText;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(widget.controller.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _errorText != null ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0),
            ),
          ),
          child: TextField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            onChanged: (_) => _onTextChanged(),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: const TextStyle(fontSize: 16),
          ),
        ),
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              _errorText!,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}
