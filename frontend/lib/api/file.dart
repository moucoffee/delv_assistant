import 'package:dio/dio.dart';
import 'package:frontend/contants/index.dart';
import 'package:frontend/utils/DioRequest.dart';
import 'package:frontend/viewmodels/case.dart' as vm;

Future<String> uploadFileAPI(MultipartFile file) async {
  final response = await dioRequest.uploadFile(HttpContants.UPLOAD_FILE, file: file);
  return response["file_url"] as String;
}

Future<vm.Material> createMaterialAPI(Map<String, dynamic> data) async {
  final response = await dioRequest.post(HttpContants.MATERIALS, data: data);
  return vm.Material.fromJSON(response as Map<String, dynamic>);
}