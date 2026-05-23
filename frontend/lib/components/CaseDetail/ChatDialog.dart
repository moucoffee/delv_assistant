import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:frontend/api/chat.dart';
import 'package:frontend/api/file.dart';
import 'package:frontend/viewmodels/chat.dart' as vm;
import 'package:frontend/utils/ToastUtils.dart';

class ChatDialog extends StatefulWidget {
  final int? caseId;

  const ChatDialog({
    Key? key,
    this.caseId,
  }) : super(key: key);

  @override
  _ChatDialogState createState() => _ChatDialogState();
}

class _ChatDialogState extends State<ChatDialog> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<vm.ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isStreaming = false;
  bool _isUploading = false;
  String _streamingContent = "";
  List<String> _selectedFileUrls = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await getChatMessagesAPI(caseId: widget.caseId);
      setState(() {
        _messages = messages;
      });
      _scrollToBottom();
    } catch (e) {
      Toastutils.showToast(context, e.toString());
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleFileUpload() async {
    if (_isUploading) return;
    
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      _isUploading = true;
    });

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
      
      setState(() {
        _selectedFileUrls.add(fileUrl);
      });
      
      Toastutils.showToast(context, "文件上传成功");
    } catch (e) {
      Toastutils.showToast(context, "文件上传失败: $e");
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _selectedFileUrls.isEmpty) return;
    if (_isLoading || _isStreaming) return;

    setState(() {
      _isLoading = true;
      _isStreaming = true;
      _streamingContent = "";
    });

    _messageController.clear();
    final fileUrls = List<String>.from(_selectedFileUrls);
    setState(() {
      _selectedFileUrls.clear();
    });

    try {
      final request = vm.ChatRequest(
        message: text,
        case_id: widget.caseId,
        file_urls: fileUrls.isNotEmpty ? fileUrls : null,
      );

      await for (final chunk in sendChatMessageStreamAPI(request)) {
        setState(() {
          _streamingContent += chunk;
        });
        _scrollToBottom();
      }
    } catch (e) {
      Toastutils.showToast(context, e.toString());
    } finally {
      setState(() {
        _isLoading = false;
        _isStreaming = false;
        _streamingContent = "";
      });
      _loadMessages();
    }
  }

  Widget _buildMessageBubble(vm.ChatMessage message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF3B82F6) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          message.content,
          style: TextStyle(
            fontSize: 16,
            color: isUser ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }

  Widget _buildStreamingBubble() {
    if (_streamingContent.isEmpty) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          _streamingContent,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFiles() {
    if (_selectedFileUrls.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE2E8F0)),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _selectedFileUrls.asMap().entries.map((entry) {
          final index = entry.key;
          final fileUrl = entry.value;
          final fileName = fileUrl.split('/').last;
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.attach_file, size: 16, color: const Color(0xFF64748B)),
                const SizedBox(width: 4),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 150),
                  child: Text(
                    fileName,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFileUrls.removeAt(index);
                    });
                  },
                  child: const Icon(Icons.close, size: 16, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputArea() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSelectedFiles(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                GestureDetector(
                  onTap: _isUploading || _isLoading ? null : _handleFileUpload,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isUploading ? const Color(0xFF94A3B8) : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.attach_file,
                            color: Color(0xFF64748B),
                            size: 24,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "输入消息...",
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      suffixIcon: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                    enabled: !_isLoading,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _isLoading ? null : _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isLoading ? const Color(0xFF94A3B8) : const Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "关闭",
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ),
                    const Text(
                      "AI 助手",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 60),
                  ],
                ),
              ),
              Expanded(
                child: _messages.isEmpty && !_isStreaming
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: const Color(0xFFCBD5E1),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "开始聊天吧！",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: _messages.length + (_isStreaming ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length) {
                            return _buildStreamingBubble();
                          }
                          return _buildMessageBubble(_messages[index]);
                        },
                      ),
              ),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
