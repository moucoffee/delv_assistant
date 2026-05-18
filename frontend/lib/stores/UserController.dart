import 'package:frontend/viewmodels/user.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/state_manager.dart';

class UserController extends GetxController {
  var user = UserInfo.fromJSON({}).obs;

  updateUserInfo(UserInfo newUser)
  {
    user.value = newUser;
  }
}