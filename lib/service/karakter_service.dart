import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MovieService {
  static const String _baseUrl = 'https://api.wawunime.my.id/api';

  Future<void> addStaff(Map<String, dynamic> staffData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/staff'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(staffData),
    );

    if (response.statusCode != 201) {
      throw Exception('Gagal menambahkan staff');
    }
  }

}