import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'package:weebase/model/user_model.dart';
import 'package:weebase/service/preferences_service.dart';

class AuthService {
  static final Logger logger = Logger();
  static const baseUrl = 'https://api.wawunime.my.id/api/auth';

  /// Registers a new user and triggers OTP sending in one step.
  /// Backend endpoint: POST /register
  /// Required fields: username, email, password
  /// On success, backend sends OTP to the email and returns a response indicating pending verification.
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": username,
          "email": email,
          "password": password,
        }),
      );

      final statusCode = response.statusCode;
      final responseBody = response.body;

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(responseBody);
      } catch (e) {
        throw Exception('Server tidak mengembalikan data JSON');
      }

      if (statusCode == 200 || statusCode == 201) {
        // Registration successful, OTP sent
        return responseData;
      } else {
        // Error from server
        if (responseData.containsKey('errors')) {
          List errors = responseData['errors'];
          String errorMessages = errors.map((e) => e['msg']).join('\n');
          throw Exception(errorMessages);
        } else if (responseData.containsKey('massage')) {
          throw Exception(responseData['massage']);
        } else if (responseData.containsKey('message')) {
          throw Exception(responseData['message']);
        } else {
          throw Exception('Terjadi kesalahan saat registrasi');
        }
      }
    } catch (e) {
      throw Exception('Gagal melakukan registrasi: $e');
    }
  }

  // Login function
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        logger.i(responseData);
        return responseData;
      } else {
        if (response.statusCode == 403) {
          throw Exception(
            responseData['message'] ?? 'Akun Anda belum diverifikasi.',
          );
        } else {
          throw Exception(
            responseData['message'] ?? 'Email atau password salah.',
          );
        }
      }
    } catch (e) {
      logger.e(e);
      throw Exception('Failed to login: $e');
    }
  }

  Future<User> getCurrentUser() async {
    final url = Uri.parse('$baseUrl/me');
    final token = PreferencesService.getToken();

    print("Token: $token");

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login ulang.");
    }

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    final statusCode = response.statusCode;
    final responseBody = response.body;

    if (statusCode == 200) {
      final responseData = jsonDecode(responseBody);
      if (responseData['success'] == true && responseData['data'] != null) {
        return User.fromJson(responseData['data']);
      } else {
        throw Exception('Data user tidak ditemukan.');
      }
    } else {
      logger.e('Gagal mendapatkan user: $statusCode - $responseBody');
      throw Exception('Gagal mendapatkan data user: ${response.reasonPhrase}');
    }
  }

  Future<void> updateUser({
    required int id,
    required String name,
    required String email,
    String? bio,
    String? password,
    File? profileImage,
  }) async {
    final uri = Uri.parse('$baseUrl/me');
    final request = http.MultipartRequest('PUT', uri)
      ..headers['Accept'] = 'application/json';

    // Tambahkan Authorization Bearer Token
    final token = PreferencesService.getToken();

    print("TOken: $token");

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Isi field form
    request.fields['name'] = name;
    request.fields['email'] = email;
    if (bio != null) request.fields['bio'] = bio;
    if (password != null) request.fields['password'] = password;

    // Jika ada gambar
    if (profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          profileImage.path,
          contentType: MediaType(
            'image',
            profileImage.path.toLowerCase().endsWith('.png') ? 'png' : 'jpeg',
          ),
        ),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      logger.i('Response Status Code: ${response.statusCode}');
      logger.i('Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // ✅ Success, tampilkan jika perlu
        logger.i('Update berhasil');
      } else {
        // ❌ Error → tampilkan error detail
        try {
          final jsonResponse = jsonDecode(response.body);
          logger.e('Error detail: $jsonResponse');
          throw Exception(
            jsonResponse['error'] ??
                jsonResponse['message'] ??
                'Gagal update user',
          );
        } catch (e) {
          logger.e('Gagal parsing JSON error response: $e');
          throw Exception(
            'Gagal update user: ${response.statusCode} - ${response.body}',
          );
        }
      }
    } catch (e) {
      logger.e('Exception during updateUser: $e');
      rethrow; // biar error tetap dilempar ke atas untuk ditangani
    }
  }

  // Future completeProfile(
  //   String userId,
  //   String phone,
  //   String address,
  //   String latitude,
  //   String longitude,
  //   String location,
  //   String gender,
  // ) async {
  //   final url = Uri.parse('$baseUrl/completeProfile');
  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode(({
  //       'user_id': userId,
  //       'phone': phone,
  //       'address': address,
  //       'latitude': latitude,
  //       'longitude': longitude,
  //       'location': location,
  //       'gender': gender,
  //     })),
  //   );

  //   if (response.statusCode == 200) {
  //     // Return the parsed response
  //     logger.i(jsonDecode(response.body));
  //     return jsonDecode(response.body);
  //   } else {
  //     final responseData = jsonDecode(response.body);
  //     throw Exception(responseData["error"].toString());
  //   }
  // }

  Future<String?> verifyOtp(String email, String otp) async {
    final url = Uri.parse('$baseUrl/verify-otp');
    logger.i('Verifying OTP to: $url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final String token = body['token'];
        logger.i('Service: Verifikasi sukses, token diterima!');
        return token;
      } else {
        logger.e('Service: Gagal verifikasi - \\${response.statusCode}');
        logger.e('Service: Body - \\${response.body}');
        return null;
      }
    } catch (e) {
      logger.e('Service: Error koneksi saat verifikasi - \\$e');
      return null;
    }
  }

  Future<bool> resendOtp(String email) async {
    final url = Uri.parse('$baseUrl/resend-otp');
    logger.i('Resending OTP to: \\$url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      // Status 200 OK berarti backend berhasil mengirim ulang
      if (response.statusCode == 200) {
        logger.i('Service: OTP berhasil dikirim ulang.');
        return true;
      } else {
        logger.e('Service: Gagal mengirim ulang OTP - \\${response.body}');
        return false;
      }
    } catch (e) {
      logger.e('Service: Error koneksi saat kirim ulang OTP - \\$e');
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/forgot-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/reset-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
