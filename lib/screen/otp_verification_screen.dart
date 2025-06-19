// file: lib/screens/otp_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/service/auth_service.dart';
import 'package:flutter_application_1/screen/login_screen.dart';
import 'dart:async';
import 'package:flutter_application_1/service/preferences_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  int _resendCooldown = 60;
  int _currentCooldown = 0;
  late final AuthService _authService;
  late final String _email;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _email = widget.email;
  }

  void _startCooldown() {
    setState(() {
      _currentCooldown = _resendCooldown;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentCooldown == 0) {
        timer.cancel();
      } else {
        setState(() {
          _currentCooldown--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _handleVerifyOtp() async {
    if (_otpController.text.isEmpty || _otpController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan 6 digit kode OTP.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    // Panggil service untuk verifikasi OTP
    final String? token = await _authService.verifyOtp(widget.email, _otpController.text);

    setState(() { _isLoading = false; });

    if (token != null && mounted) {
      // 1. Hapus token dan credentials agar user harus login ulang
      await PreferencesService.clearToken();
      await PreferencesService.clearCredentials();

      // 2. Navigasi ke halaman login dan hapus semua halaman sebelumnya
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _handleResendOtp() async {
  setState(() { _isLoading = true; });

  try {
    final bool isSuccess = await _authService.resendOtp(widget.email);

    if (isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode OTP baru telah berhasil dikirim.')),
      );
      _startCooldown();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim ulang kode OTP.')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi error: ${e.toString()}')),
    );
  } finally {
    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Masukkan 6 digit kode yang dikirim ke:\n${widget.email}', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextFormField(
              controller: _otpController,
              decoration: const InputDecoration(labelText: 'Kode OTP'),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleVerifyOtp,
                    child: const Text('Verifikasi & Login'),
                  ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _currentCooldown == 0 && !_isLoading ? _handleResendOtp : null,
                  child: _currentCooldown == 0
                      ? const Text('Kirim Ulang OTP')
                      : Text('Kirim ulang dalam $_currentCooldown detik'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}