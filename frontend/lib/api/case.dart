import 'package:dio/dio.dart';
import 'package:frontend/contants/index.dart';
import 'package:frontend/utils/DioRequest.dart';
import 'package:frontend/viewmodels/case.dart' as vm;

Future<List<vm.Case>> getCaseListAPI() async {
  final response = await dioRequest.get(HttpContants.CASE_LIST);
  return (response as List).map((item) {
    return vm.Case.fromJSON(item as Map<String, dynamic>);
  }).toList();
}

Future<vm.CaseDetail> getCaseDetailAPI(dynamic caseId) async {
  final response = await dioRequest.get("${HttpContants.CASE_DETAIL}$caseId");
  return vm.CaseDetail.fromJSON(response as Map<String, dynamic>);
}

// 步骤3.1：上传文件接口
Future<String> uploadFileAPI(MultipartFile file) async {
  final response = await dioRequest.uploadFile(HttpContants.UPLOAD_FILE, file: file);
  return response["file_url"] as String;
}

// 步骤3.2：创建材料接口
Future<vm.Material> createMaterialAPI(Map<String, dynamic> data) async {
  final response = await dioRequest.post(HttpContants.MATERIALS, data: data);
  return vm.Material.fromJSON(response as Map<String, dynamic>);
}
