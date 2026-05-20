import 'package:flutter/material.dart';
import 'package:frontend/api/user.dart';
import 'package:frontend/routes/index.dart';
import 'package:frontend/stores/TokenManager.dart';
import 'package:frontend/stores/UserController.dart';
import 'package:frontend/utils/ToastUtils.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _rememberPassword = false;
  bool _obscurePassword = true;

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "欢迎使用",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 8),
        Text(
          "AI助理",
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isLogin = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isLogin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: _isLogin
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  "登录",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _isLogin ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isLogin = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isLogin ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: !_isLogin
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  "注册",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: !_isLogin ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "手机号/邮箱",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) return "请输入手机号";
            if (!RegExp(r"^1[3-9]\d{9}$").hasMatch(value)) return "手机格式不正确";
            return null;
          },
          controller: _phoneController,
          decoration: InputDecoration(
            hintText: "请输入手机号",
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildPasswordTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "密码",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) return "请输入密码";
            if (value.length < 6) return "密码长度不能少于6位";
            return null;
          },
          obscureText: _obscurePassword,
          controller: _passwordController,
          decoration: InputDecoration(
            hintText: "请输入密码",
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF94A3B8),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildRememberAndForgot() {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _rememberPassword,
            onChanged: (value) {
              setState(() {
                _rememberPassword = value ?? false;
              });
            },
            activeColor: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          "记住密码",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF475569),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {},
          child: const Text(
            "忘记密码？",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF3B82F6),
            ),
          ),
        ),
      ],
    );
  }

  final UserController _userController = Get.find();

  _handleLogin() async {
    try{
      final userInfo = await LoginAPI({
        "phone" : _phoneController.text,
        "password" : _passwordController.text
      });
      _userController.updateUserInfo(userInfo);
      tokenManager.setToken(userInfo.token);

      Toastutils.showToast(context, "登录成功");
      Navigator.pushNamedAndRemoveUntil(context, RouteName.MAIN, (route) => false);
    } catch(e){
      Toastutils.showToast(context, e.toString());
    }
      
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: () {
        if (_formKey.currentState!.validate()) {
          //校验通过
          _handleLogin();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF3B82F6),
              Color(0xFF60A5FA),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "登录",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text(
          "注册功能开发中...",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Column(
      children: [
        Text(
          "v2.0.0.1615",
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF94A3B8),
          ),
        ),
        SizedBox(height: 4),
        Text(
          "版权所有 © 2026",
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildTabBar(),
                const SizedBox(height: 32),
                if (_isLogin) ...[
                  _buildPhoneTextField(),
                  const SizedBox(height: 20),
                  _buildPasswordTextField(),
                  const SizedBox(height: 16),
                  _buildRememberAndForgot(),
                  const SizedBox(height: 32),
                  _buildLoginButton(),
                ],
                if (!_isLogin) _buildRegisterPlaceholder(),
                const SizedBox(height: 40),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
