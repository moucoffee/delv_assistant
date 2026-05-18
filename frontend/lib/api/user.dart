import 'package:frontend/contants/index.dart';
import 'package:frontend/utils/DioRequest.dart';
import 'package:frontend/viewmodels/user.dart';

// Future<UserInfo> getUserInfoAPI() async {
//   final response = await dioRequest.get(HttpContants.USER_ME);
//   return UserInfo.fromJSON(response as Map<String, dynamic>);
// }

Future<UserInfo> LoginAPI(Map<String, dynamic> data) async {
  return UserInfo.fromJSON(
    await dioRequest.post(HttpContants.USER_LOGIN, data: data),
  );
}

Future<UserInfo> getUserInfoAPI() async {
  return UserInfo.fromJSON(
    await dioRequest.get(HttpContants.USER_ME),
  );
}