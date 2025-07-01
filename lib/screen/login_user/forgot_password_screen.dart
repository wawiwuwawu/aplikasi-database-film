import 'package:flutter/material.dart';
import 'package:weebase/service/auth_service.dart';
import 'package:weebase/screen/login_user/reset_password_screen.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleForgotPassword() async {
    final email = _emailController.text.trim();

    // Validasi email format
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format email tidak valid')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bool isSuccess = await _authService.forgotPassword(email);

      if (isSuccess && mounted) {
        // Tampilkan pesan sukses. Pesannya umum untuk keamanan.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Jika email Anda terdaftar, kode reset akan dikirim.')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(email: email),
          ),
        );
      } else {
        // Tampilkan pesan error umum
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memproses permintaan. Coba lagi.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                Image.asset('assets/icons/transparent_icon.png', height: 100),
                const SizedBox(height: 10),
                const Text(
                  'LUPA PASSWORD',
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
                        const Text(
                          'Masukkan email Anda yang terdaftar untuk menerima kode reset password.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        // Email Field
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Alex@gmail.com',
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Tombol Kirim Kode
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _isLoading ? null : _handleForgotPassword,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Kirim Kode Reset',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Tombol Kembali ke Login
                TextButton(
                  onPressed: () {
                    // Kembali ke halaman sebelumnya (LoginScreen)
                    Navigator.of(context).pop();
                  },
                  child: const Text("Kembali ke menu Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
