import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../model/staff_model.dart';
import 'dart:io';

class StaffService {
  static const String _baseUrl = 'https://api.wawunime.my.id/api/staff';

  Future<void> uploadStaff({
    required Staff staff,
    required File coverImage,
  }) async {
    final uri = Uri.parse(_baseUrl);
    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..fields['name']     = staff.name
      ..fields['role']     = staff.role
      ..fields['bio']      = staff.bio ?? '';

    if (staff.birthday != null && staff.birthday!.trim().isNotEmpty) {
      request.fields['birthday'] = staff.birthday!.trim();
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        coverImage.path,
        contentType: MediaType(
          'image',
          coverImage.path.toLowerCase().endsWith('.png') ? 'png' : 'jpeg',
        ),
      ),
    );

    final streamedResponse = await request.send();
    final responseBody    = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode >= 200 && streamedResponse.statusCode < 300) {
      return json.decode(responseBody);
    } else {
      throw Exception('Upload failed: ${streamedResponse.statusCode} – $responseBody');
    }
  }
}