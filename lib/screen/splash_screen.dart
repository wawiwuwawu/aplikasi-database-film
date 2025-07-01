import 'package:flutter/material.dart';
import 'package:weebase/screen/login_user/login_screen.dart';
import 'package:weebase/screen/main_screen.dart';
import 'package:weebase/service/preferences_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginAndNavigate();
  }

  Future<void> _checkLoginAndNavigate() async {
    await PreferencesService.init(); // Inisialisasi SharedPreferences sebelum akses token
    final token = PreferencesService.getToken();
    await Future.delayed(const Duration(seconds: 1)); // opsional delay agar transisi smooth

    if (!mounted) return;
    
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/icons/main_icon.png',
          width: 120,
          height: 120,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
