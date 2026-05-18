import 'package:flutter/material.dart';

class Case {
  String id;
  String user_id;
  String title;
  String case_type;
  String status;
  String create_at;
  String parties;
  String material_count;
  String total_file_size;
  String phone;

  Case({
    required this.id,
    required this.user_id,
    required this.title,
    required this.case_type,
    required this.status,
    required this.create_at,
    required this.parties,
    required this.material_count,
    required this.total_file_size,
    required this.phone,
  });

  factory Case.fromJSON(Map<String, dynamic> json) {
    return Case(
      id: json["id"]?.toString() ?? "",
      user_id: json["user_id"]?.toString() ?? "",
      title: json["title"]?.toString() ?? "",
      case_type: json["case_type"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "",
      create_at: json["created_at"]?.toString() ?? "", // 修改为 created_at
      parties: json["parties"]?.toString() ?? "",
      material_count: json["material_count"]?.toString() ?? "",
      total_file_size: json["total_file_size"]?.toString() ?? "",
      phone: json["phone"]?.toString() ?? "",
    );
  }
}

class CaseDetail {
  String id;
  String user_id;
  String title;
  String parties;
  String phone;
  String case_type;
  String status;
  String amount;
  String description;
  Map<String, dynamic> material_stats;

  CaseDetail({
    required this.id,
    required this.user_id,
    required this.title,
    required this.parties,
    required this.phone,
    required this.case_type,
    required this.status,
    required this.amount,
    required this.description,
    required this.material_stats,
  });

  factory CaseDetail.fromJSON(Map<String, dynamic> json) {
    return CaseDetail(
      id: json["id"]?.toString() ?? "",
      user_id: json["user_id"]?.toString() ?? "",
      title: json["title"]?.toString() ?? "",
      parties: json["parties"]?.toString() ?? "",
      phone: json["phone"]?.toString() ?? "",
      case_type: json["case_type"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "",
      amount: json["amount"]?.toString() ?? "0",
      description: json["description"]?.toString() ?? "",
      material_stats: json["material_stats"] ?? {},
    );
  }
}

class Material {
  String id;
  String case_id;
  String user_id;
  String category; // case, evidence, payment, notice
  String name;
  String? file_type;
  String file_size;
  String? file_url;
  String? content;
  String created_at;
  String? updated_at;

  Material({
    required this.id,
    required this.case_id,
    required this.user_id,
    required this.category,
    required this.name,
    this.file_type,
    required this.file_size,
    this.file_url,
    this.content,
    required this.created_at,
    this.updated_at,
  });

  factory Material.fromJSON(Map<String, dynamic> json) {
    return Material(
      id: json["id"]?.toString() ?? "",
      case_id: json["case_id"]?.toString() ?? "",
      user_id: json["user_id"]?.toString() ?? "",
      category: json["category"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      file_type: json["file_type"]?.toString(),
      file_size: json["file_size"]?.toString() ?? "0B",
      file_url: json["file_url"]?.toString(),
      content: json["content"]?.toString(),
      created_at: json["created_at"]?.toString() ?? "",
      updated_at: json["updated_at"]?.toString(),
    );
  }
}
