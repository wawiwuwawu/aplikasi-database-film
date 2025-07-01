import 'package:flutter/material.dart';
import 'package:weebase/screen/main_screen.dart';
import 'package:weebase/service/auth_service.dart';
import 'package:weebase/screen/login_user/register_screen.dart';
import 'package:weebase/service/preferences_service.dart';
import 'package:weebase/model/user_model.dart';
import 'package:weebase/screen/login_user/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;

  void _login() async {
  if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Email dan password tidak boleh kosong')),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
  final result = await _authService.login(
    _emailController.text.trim(),
    _passwordController.text.trim(),
  );

  // Simpan token dan credentials ke SharedPreferences
  await PreferencesService.saveToken(result['token']);
  dynamic data = result['data'];
  User credentials;
  if (data is List && data.isNotEmpty) {
    credentials = User.fromJson(data[0]);
  } else if (data is Map<String, dynamic>) {
    credentials = User.fromJson(data);
  } else {
    throw Exception('Data user tidak ditemukan pada response.');
  }
  await PreferencesService.saveCredentials(credentials);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Login berhasil')),
  );

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => MainScreen()),
  );
} catch (e) {
  final errorMessage = e.toString().replaceAll('Exception: ', '');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(errorMessage)),
  );
}
 finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo
                Image.asset(
                  'assets/icons/transparent_icon.png',
                  height: 100,
                ),
                const SizedBox(height: 20),
                Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        // Email Field
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Alex@gmail.com',
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: '********',
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Forgot Password
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                              );
                            },
                            child: const Text(
                              'Lupa Password?',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Tidak punya akun? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterScreen()),
                        );
                      },
                      child: const Text("Daftar"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
