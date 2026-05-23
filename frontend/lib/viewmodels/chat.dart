import 'package:flutter/material.dart';

class ChatMessage {
  String id;
  String user_id;
  String? case_id;
  String role; // user, assistant
  String content;
  String? file_urls;
  String created_at;

  ChatMessage({
    required this.id,
    required this.user_id,
    this.case_id,
    required this.role,
    required this.content,
    this.file_urls,
    required this.created_at,
  });

  bool get isUser => role == "user";
  bool get isAssistant => role == "assistant";

  factory ChatMessage.fromJSON(Map<String, dynamic> json) {
    return ChatMessage(
      id: json["id"]?.toString() ?? "",
      user_id: json["user_id"]?.toString() ?? "",
      case_id: json["case_id"]?.toString(),
      role: json["role"]?.toString() ?? "user",
      content: json["content"]?.toString() ?? "",
      file_urls: json["file_urls"]?.toString(),
      created_at: json["created_at"]?.toString() ?? "",
    );
  }
}

class ChatRequest {
  String message;
  int? case_id;
  List<String>? file_urls;

  ChatRequest({
    required this.message,
    this.case_id,
    this.file_urls,
  });

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "case_id": case_id,
      "file_urls": file_urls,
    };
  }
}
