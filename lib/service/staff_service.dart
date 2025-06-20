import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../model/staff_model.dart';
import 'dart:io';
import 'package:logger/logger.dart';

class StaffService {
  static const String _baseUrl = 'https://api.wawunime.my.id/api/staff';
  final Logger _logger = Logger();

  Future<void> uploadStaff({
    required Staff staff,
    required File coverImage,
  }) async {
    final uri = Uri.parse(_baseUrl);
    final request =
        http.MultipartRequest('POST', uri)
          ..headers['Accept'] = 'application/json'
          ..fields['name'] = staff.name
          ..fields['role'] = staff.role
          ..fields['bio'] = staff.bio ?? '';

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
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode >= 200 &&
        streamedResponse.statusCode < 300) {
      return json.decode(responseBody);
    } else {
      throw Exception(
        'Upload failed: ${streamedResponse.statusCode} – $responseBody',
      );
    }
  }

  Future<List<Staff>> getStaff({int page = 1, String? query}) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'page': page.toString(),
        if (query != null && query.isNotEmpty) 'search': query,
      },
    );

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['data'] is List) {
        return (data['data'] as List)
            .map((staffJson) => Staff.fromJson(staffJson))
            .toList();
      } else {
        throw Exception('Invalid data format');
      }
    } else {
      throw Exception('Failed to load staff: ${response.statusCode}');
    }
  }

  Future<Staff> getStaffById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'] is Map<String, dynamic>) {
          return Staff.fromJson(data['data']);
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        throw Exception('Failed to load staff: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error in getStaffById: $e');
      throw Exception('Failed to load data: $e');
    }
  }

  Future<Staff> getStaffDetailId(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$id/movie'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'] is Map<String, dynamic>) {
          return Staff.fromJson(data['data']);
        } else {
          throw Exception('Invalid data strucuture');
        }
      } else {
        throw Exception(
          'Failed to load staff detail, Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.e('Error in getStaffDetailId: $e');
      throw Exception('Failed to load data: $e');
    }
  }

  Future<void> updateStaff({
    required int id,
    required Staff staff,
    File? coverImage,
  }) async {
    final uri = Uri.parse('$_baseUrl/$id');
    final request =
        http.MultipartRequest('PUT', uri)
          ..headers['Accept'] = 'application/json'
          ..fields['name'] = staff.name
          ..fields['role'] = staff.role
          ..fields['bio'] = staff.bio ?? '';

    if (staff.birthday != null && staff.birthday!.trim().isNotEmpty) {
      request.fields['birthday'] = staff.birthday!.trim();
    }

    if (coverImage != null) {
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
    }

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode >= 200 &&
        streamedResponse.statusCode < 300) {
      _logger.i('Staff berhasil diperbarui: $responseBody');
    } else {
      throw Exception(
        'Update failed: ${streamedResponse.statusCode} – $responseBody',
      );
    }
  }

  Future<List<Staff>> searchStaffByName(String name) async {
    final uri = Uri.parse(
      '$_baseUrl/search',
    ).replace(queryParameters: {'name': name});

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['data'] is List) {
        return (data['data'] as List)
            .map((staffJson) => Staff.fromJson(staffJson))
            .toList();
      } else {
        throw Exception('Invalid data format');
      }
    } else {
      throw Exception('Failed to search staff: ${response.statusCode}');
    }
  }

  Future<void> deleteStaff(int id) async {
    final uri = Uri.parse('$_baseUrl/$id');
    final response = await http.delete(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      _logger.i('Staff berhasil dihapus');
    } else {
      throw Exception('Gagal menghapus staff: ${response.statusCode}');
    }
  }
}
