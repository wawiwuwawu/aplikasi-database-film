import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const baseUrl = 'https://api.wawunime.my.id/api/auth';

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
      // Login berhasil
      return responseData;
    } else {
      // Error dari server
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
}
