import 'package:flutter/material.dart';
import 'package:frontend/stores/TokenManager.dart';
import 'package:frontend/routes/index.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await tokenManager.init();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    if (tokenManager.getToken().isNotEmpty) {
      Navigator.pushReplacementNamed(context, RouteName.MAIN);
    } else {
      Navigator.pushReplacementNamed(context, RouteName.LOGIN);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
