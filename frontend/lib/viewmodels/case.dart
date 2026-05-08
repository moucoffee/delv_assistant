import 'package:flutter/material.dart';

class Case {
  String id;
  String user_id;
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