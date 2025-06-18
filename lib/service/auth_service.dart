import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const baseUrl = 'https://api.wawunime.my.id/api/auth';

  /// Registers a new user and triggers OTP sending in one step.
  /// Backend endpoint: POST /register
  /// Required fields: username, email, password
  /// On success, backend sends OTP to the email and returns a response indicating pending verification.
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
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
        print(responseData);

        return responseData;
      } else {
        print(responseData);
        throw Exception(responseData['message'] ?? 'Login gagal');
      }
    } catch (e) {
      print(e);

      throw Exception('Failed to login: $e');
    }
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future completeProfile(
    String userId,
    String phone,
    String address,
    String latitude,
    String longitude,
    String location,
    String gender,
  ) async {
    final url = Uri.parse('$baseUrl/completeProfile');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(({
        'user_id': userId,
        'phone': phone,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'location': location,
        'gender': gender,
      })),
    );

    if (response.statusCode == 200) {
      // Return the parsed response
      print(jsonDecode(response.body));
      return jsonDecode(response.body);
    } else {
      final responseData = jsonDecode(response.body);

      throw Exception(responseData["error"].toString());
    }
  }

  // Future<bool> requestOtp(String email) async {
  //   final url = Uri.parse('$baseUrl/send-otp');
  //   print('Requesting OTP to: $url'); // Log untuk debugging

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'email': email}),
  //     );

  //     if (response.statusCode == 200) {
  //       print('Service: Permintaan OTP sukses!');
  //       return true;
  //     } else {
  //       print('Service: Gagal meminta OTP - ${response.statusCode}');
  //       print('Service: Body - ${response.body}');
  //       return false;
  //     }
  //   } catch (e) {
  //     print('Service: Error koneksi saat meminta OTP - $e');
  //     return false;
  //   }
  // }

  Future<String?> verifyOtp(String email, String otp) async {
    final url = Uri.parse('$baseUrl/verify-otp');
    print('Verifying OTP to: $url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final String token = body['token'];
        print('Service: Verifikasi sukses, token diterima!');
        return token;
      } else {
        print('Service: Gagal verifikasi - ${response.statusCode}');
        print('Service: Body - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Service: Error koneksi saat verifikasi - $e');
      return null;
    }
  }
}
