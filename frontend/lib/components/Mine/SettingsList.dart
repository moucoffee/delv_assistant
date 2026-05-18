import 'package:flutter/material.dart';

class SettingsList extends StatelessWidget {
  final VoidCallback? onChangePassword;
  final VoidCallback? onDataBackup;
  final VoidCallback? onAbout;
  final VoidCallback? onDeleteAccount;
  final VoidCallback? onLogout;

  const SettingsList({
    Key? key,
    this.onChangePassword,
    this.onDataBackup,
    this.onAbout,
    this.onDeleteAccount,
    this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSettingItem(
            icon: Icons.key,
            iconColor: Colors.blue,
            iconBgColor: Colors.blue.withOpacity(0.1),
            title: "修改密码",
            onTap: onChangePassword,
          ),
          const SizedBox(height: 8),
          _buildSettingItem(
            icon: Icons.cloud,
            iconColor: Colors.green,
            iconBgColor: Colors.green.withOpacity(0.1),
            title: "数据备份",
            onTap: onDataBackup,
          ),
          const SizedBox(height: 8),
          _buildSettingItem(
            icon: Icons.info,
            iconColor: Colors.orange,
            iconBgColor: Colors.orange.withOpacity(0.1),
            title: "关于我们",
            onTap: onAbout,
          ),
          const SizedBox(height: 8),
          _buildSettingItem(
            icon: Icons.person_remove,
            iconColor: Colors.red,
            iconBgColor: Colors.red.withOpacity(0.1),
            title: "注销账号",
            titleColor: Colors.red,
            onTap: onDeleteAccount,
          ),
          const SizedBox(height: 12),
          _buildLogoutButton(onLogout),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? Colors.black,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.withOpacity(0.5),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text(
            "退出登录",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
