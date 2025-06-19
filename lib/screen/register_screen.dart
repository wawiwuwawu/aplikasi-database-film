import 'package:flutter/material.dart';
import 'package:weebase/screen/otp_verification_screen.dart';
import 'package:weebase/service/auth_service.dart';

const String kTermsAndConditions = '''
Selamat datang di WeeBase!

Dokumen Syarat dan Ketentuan ("Ketentuan") ini mengatur akses dan penggunaan Anda terhadap aplikasi WeeBase ("Aplikasi", "Layanan") yang kami sediakan. Dengan mengunduh, mendaftar, atau menggunakan Aplikasi kami, Anda ("Pengguna", "Anda") secara otomatis menyetujui dan terikat oleh semua ketentuan yang tercantum di bawah ini.

Jika Anda tidak menyetujui Ketentuan ini, mohon untuk tidak menggunakan Layanan kami.

1. Deskripsi Layanan
WeeBase adalah aplikasi database yang menyediakan informasi mengenai anime, serta fitur untuk membantu pengguna melacak daftar tontonan (watchlist) dan berinteraksi dengan komunitas. Aplikasi ini dikembangkan sebagai proyek studi atau tugas akhir oleh mahasiswa Universitas Amikom Purwokerto. Layanan ini disediakan "sebagaimana adanya" (as is) dan "sebagaimana tersedia" (as available).

2. Akun Pengguna
a. Untuk menggunakan fitur tertentu seperti watchlist, Anda mungkin diwajibkan untuk membuat akun.
b. Anda bertanggung jawab penuh untuk menjaga kerahasiaan informasi akun Anda, termasuk kata sandi.
c. Anda setuju untuk bertanggung jawab atas semua aktivitas yang terjadi di bawah akun Anda.
d. Anda harus berusia minimal 13 tahun untuk membuat akun dan menggunakan layanan kami.

3. Kewajiban dan Perilaku Pengguna
Anda setuju untuk tidak menggunakan Layanan untuk:
a. Melakukan aktivitas yang melanggar hukum atau peraturan yang berlaku.
b. Mengunggah atau membagikan konten yang bersifat melecehkan, cabul, mengandung ujaran kebencian, atau menyinggung pihak lain.
c. Mengirimkan spam atau iklan yang tidak diinginkan kepada pengguna lain.
d. Mencoba mengganggu, merusak, atau mengakses server dan jaringan kami secara tidak sah.
e. Meniru atau mengaku sebagai orang atau entitas lain.

Kami berhak untuk menangguhkan atau menghapus akun pengguna yang melanggar ketentuan ini tanpa pemberitahuan sebelumnya.

4. Hak Kekayaan Intelektual
a. Layanan WeeBase: Semua elemen dalam Aplikasi, termasuk kode, desain, logo, dan nama "WeeBase" adalah milik pengembang. Anda tidak diizinkan untuk menyalin, memodifikasi, atau mendistribusikannya tanpa izin tertulis dari kami.
b. Konten Pihak Ketiga: Semua data, gambar, sinopsis, dan materi terkait anime adalah hak cipta dari pemiliknya masing-masing (misalnya, studio animasi, penerbit, dll.). WeeBase tidak mengklaim kepemilikan atas konten ini dan hanya menampilkannya untuk tujuan informasi dan ulasan sesuai prinsip fair use.
c. Konten Buatan Pengguna: Konten yang Anda buat, seperti ulasan atau komentar, adalah milik Anda. Namun, dengan mengunggahnya ke Aplikasi, Anda memberikan kami lisensi non-eksklusif, bebas royalti, dan berlaku di seluruh dunia untuk menggunakan, menampilkan, dan mendistribusikan konten tersebut di dalam platform WeeBase.

5. Penafian (Disclaimer)
a. Akurasi Data: Kami berusaha menyajikan data seakurat mungkin, namun kami tidak menjamin bahwa semua informasi di dalam Aplikasi (seperti jadwal tayang, sinopsis, dll.) selalu akurat, lengkap, atau terbaru.
b. Ketersediaan Layanan: Sebagai proyek studi, Aplikasi ini mungkin mengalami gangguan, bug, atau penghentian layanan untuk pemeliharaan. Kami tidak menjamin layanan akan selalu tersedia tanpa gangguan.

6. Batasan Tanggung Jawab
Dalam batas maksimal yang diizinkan oleh hukum, pengembang WeeBase tidak akan bertanggung jawab atas segala kerugian atau kerusakan (baik langsung maupun tidak langsung) yang timbul dari penggunaan atau ketidakmampuan Anda untuk menggunakan Aplikasi ini.

7. Perubahan pada Ketentuan
Kami berhak untuk mengubah atau memperbarui Syarat dan Ketentuan ini dari waktu ke waktu. Kami akan berusaha memberikan pemberitahuan tentang perubahan yang signifikan. Dengan terus menggunakan Aplikasi setelah perubahan tersebut, Anda dianggap menyetujui Ketentuan yang baru.

8. Kontak
Jika Anda memiliki pertanyaan mengenai Syarat dan Ketentuan ini, silakan hubungi kami melalui Sosial media kami atau pun Sosial media Wawunime

Terima kasih telah menggunakan WeeBase!
''';

// Anda mungkin ingin mengubah nama file ini menjadi login_screen.dart
// karena sekarang fungsinya lebih ke arah login/registrasi.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isAgreed = false; // Tambahkan ini

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validasi
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi!')),
      );
      return;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format email tidak valid')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 6 karakter')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.register(name, email, password);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kode OTP telah dikirim ke email Anda.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(email: email),
          ),
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
                // Logo
                Image.asset('assets/main_logo.png', height: 100),
                const SizedBox(height: 10),
                const Text(
                  'MYS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  'YOUR MOVIE & SERIES',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'REGISTER',
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
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama',
                            hintText: 'Masukkan nama lengkap',
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Masukkan email Anda',
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            hintText: 'Masukkan password',
                          ),
                        ),
                        const SizedBox(height: 20),
                        CheckboxListTile(
                          value: _isAgreed,
                          onChanged: (val) {
                            setState(() {
                              _isAgreed = val ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          title: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Syarat & Ketentuan'),
                                  content: SingleChildScrollView(
                                    child: Text(kTermsAndConditions),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Tutup'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Text.rich(
                              TextSpan(
                                text: 'Saya menyetujui ',
                                children: [
                                  TextSpan(
                                    text: 'Syarat & Ketentuan',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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
                            onPressed: _isLoading || !_isAgreed ? null : _handleRegister,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Daftar & Kirim Kode OTP',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    'Masukkan nama, email, dan password untuk mendaftar. Kami akan mengirimkan kode verifikasi ke email Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

