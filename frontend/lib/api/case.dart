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

Future<vm.CaseDetail> updateCaseAPI(dynamic caseId, Map<String, dynamic> data) async {
  final response = await dioRequest.put("${HttpContants.CASE_DETAIL}$caseId", data: data);
  return vm.CaseDetail.fromJSON(response as Map<String, dynamic>);
}

Future<vm.CaseDetail> createCaseAPI(vm.CaseCreate caseData) async {
  final response = await dioRequest.post(
    HttpContants.CASE_CREATE,
    data: caseData.toJson(),
  );
  return vm.CaseDetail.fromJSON(response as Map<String, dynamic>);
}






