import 'package:frontend/contants/index.dart';
import 'package:frontend/utils/DioRequest.dart';
import 'package:frontend/viewmodels/case.dart';

Future<List<Case>> getCaseListAPI() async {
  return (await dioRequest.get(HttpContants.CASE_LIST) as List).map((item) {
    return Case.fromJSON(item as Map<String, dynamic>);
  }).toList();
}

Future<CaseDetail> getCaseDetailAPI(dynamic caseId) async {
  return CaseDetail.fromJSON(await dioRequest.get("${HttpContants.CASE_DETAIL}$caseId"));
}
