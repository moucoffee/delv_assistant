//编辑案件对话框
import 'package:flutter/material.dart';
import 'package:frontend/viewmodels/case.dart' as vm;

class EditCaseDialog extends StatefulWidget {
  final vm.CaseDetail caseDetail;
  final Function(Map<String, dynamic>) onSave;

  const EditCaseDialog({
    Key? key,
    required this.caseDetail,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditCaseDialogState createState() => _EditCaseDialogState();
}

class _EditCaseDialogState extends State<EditCaseDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _partiesController;
  late final TextEditingController _phoneController;
  late final TextEditingController _caseTypeController;
  late final TextEditingController _statusController;
  late final TextEditingController _amountController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.caseDetail.title);
    _partiesController = TextEditingController(text: widget.caseDetail.parties);
    _phoneController = TextEditingController(text: widget.caseDetail.phone);
    _caseTypeController = TextEditingController(text: widget.caseDetail.case_type);
    _statusController = TextEditingController(text: widget.caseDetail.status);
    _amountController = TextEditingController(text: widget.caseDetail.amount);
    _descController = TextEditingController(text: widget.caseDetail.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _partiesController.dispose();
    _phoneController.dispose();
    _caseTypeController.dispose();
    _statusController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final data = {
      "title": _titleController.text,
      "parties": _partiesController.text,
      "phone": _phoneController.text,
      "case_type": _caseTypeController.text,
      "status": _statusController.text,
      "amount": double.tryParse(_amountController.text) ?? 0.0,
      "description": _descController.text,
    };
    widget.onSave(data);
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
                    "编辑案件",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      _handleSave();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "保存",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEditField("案件标题", _titleController),
                        const SizedBox(height: 16),
                        _buildEditField("当事人", _partiesController),
                        const SizedBox(height: 16),
                        _buildEditField("联系电话", _phoneController),
                        const SizedBox(height: 16),
                        _buildEditField("案件类型", _caseTypeController),
                        const SizedBox(height: 16),
                        _buildEditField("案件状态", _statusController),
                        const SizedBox(height: 16),
                        _buildEditField(
                          "案件金额",
                          _amountController,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        _buildEditField(
                          "案件说明",
                          _descController,
                          maxLines: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
