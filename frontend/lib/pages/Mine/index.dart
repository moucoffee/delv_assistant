import 'package:flutter/material.dart';
import 'package:frontend/api/user.dart';
import 'package:frontend/components/Mine/UserHeader.dart';
import 'package:frontend/components/Mine/StatsCard.dart';
import 'package:frontend/components/Mine/SettingsList.dart';
import 'package:frontend/api/case.dart';
import 'package:frontend/routes/index.dart';
import 'package:frontend/stores/TokenManager.dart';
import 'package:frontend/stores/UserController.dart';
import 'package:frontend/viewmodels/user.dart' as vm;
import 'package:frontend/utils/ToastUtils.dart';
import 'package:frontend/viewmodels/user.dart';
import 'package:get/get.dart';

class MineView extends StatefulWidget {
  MineView({Key? key}) : super(key: key);

  @override
  _MineViewState createState() => _MineViewState();
}

class _MineViewState extends State<MineView> {
  vm.UserInfo? _userInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      final data = await getUserInfoAPI();
      setState(() {
        _userInfo = data;
        _isLoading = false;
      });
    } catch (e) {
      print("获取用户信息失败: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("确认退出"),
        content: const Text("确定要退出登录吗？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("确定", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final UserController _userController = Get.find();
      await tokenManager.removeToken();
      _userController.updateUserInfo(UserInfo.fromJSON({}));
      
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, RouteName.LOGIN, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          UserHeader(
            name: _userInfo?.username ?? "用户",
            phone: _hidePhone(_userInfo?.phone ?? ""),
          ),
          StatsCard(
            coins: _userInfo?.coins ?? 0,
            trialDays: _userInfo?.trialDays ?? 0,
            caseCount: _userInfo?.caseCount ?? 0,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: SettingsList(
              onChangePassword: () => Toastutils.showToast(context, "修改密码开发中..."),
              onDataBackup: () => Toastutils.showToast(context, "数据备份开发中..."),
              onAbout: () => Toastutils.showToast(context, "关于我们开发中..."),
              onDeleteAccount: () => Toastutils.showToast(context, "注销账号开发中..."),
              onLogout: _handleLogout,
            ),
          ),
        ],
      ),
    );
  }

  String _hidePhone(String phone) {
    if (phone.length < 7) return phone;
    return phone.replaceRange(3, 7, "****");
  }
}
