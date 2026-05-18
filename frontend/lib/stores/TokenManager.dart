import 'package:frontend/contants/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {

  Future<SharedPreferences> _getInstance() {
    return SharedPreferences.getInstance();
  }
  String _token = "";
  
  init() async {
    final prefs = await _getInstance();
    _token = prefs.getString(GlobalContants.TOKEN_KEY) ?? "";
  }

  Future<void> setToken(String val) async {
    final prefs = await _getInstance();
    prefs.setString(GlobalContants.TOKEN_KEY, val); //写入token
    _token = val;
  }

  String getToken() {
    return _token;
  }

  Future<void> removeToken() async {
    final prefs = await _getInstance();
    prefs.remove(GlobalContants.TOKEN_KEY);
    _token = "";
  }
}

final tokenManager = TokenManager();