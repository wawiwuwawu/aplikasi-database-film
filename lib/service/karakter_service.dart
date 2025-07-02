import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../model/karakter_model.dart';
import 'dart:io';
import 'package:logger/logger.dart';

class KarakterService {
  static const String _baseUrl = 'https://api.wawunime.my.id/api/karakter';
  final Logger _logger = Logger();

  Future<List<Karakter>> getKarakterDetail({int page = 1, String? query}) async {
    const String baseUrl = '$_baseUrl/detail';
  
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'page': page.toString(),
        if (query != null && query.isNotEmpty) 'search': query,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      
      if (jsonData['data'] is List) {
        return (jsonData['data'] as List)
            .map((karakterJson) => Karakter.fromJson(karakterJson))
            .toList();
      } else {
        throw Exception('Invalid API response structure');
      }
    } else {
      throw Exception(
        'Failed to load karakter: ${response.statusCode} - ${response.body}'
      );
    }
  }



  Future<Karakter> getKarakterDetailId(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/detail/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);      

        if (data['data'] is Map<String, dynamic>) {
          return Karakter.fromJson(data['data']);
        } else {
          throw Exception('Invalid response structure');
        }
      } else {
        throw Exception(
          'Failed to load karakter details. Status: ${response.statusCode}'
        );
      }
    } catch (e) {
      _logger.e('Error in getKarakterDetailId: $e');
      throw Exception('Failed to load data: $e');
    }
  }

  Future<void> uploadKarakter({
    required Karakter karakter,
    required File coverImage,
  }) async {
    final uri = Uri.parse(_baseUrl);
    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..fields['nama'] = karakter.nama
      ..fields['bio']  = karakter.bio ?? '';

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
  
    if (streamedResponse.statusCode >= 200 && streamedResponse.statusCode < 300) {
      return json.decode(responseBody);
    } else {
      throw Exception('Upload failed: ${streamedResponse.statusCode} – $responseBody');
    }
  }

  Future<void> updateKarakter({
    required int id,
    required Karakter karakter,
    File? coverImage,
  }) async {
    final uri = Uri.parse('$_baseUrl/$id');
    final request = http.MultipartRequest('PUT', uri)
      ..headers['Accept'] = 'application/json'
      ..fields['nama'] = karakter.nama
      ..fields['bio'] = karakter.bio ?? '';

    // Tambahkan file gambar jika ada
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

    if (streamedResponse.statusCode >= 200 && streamedResponse.statusCode < 300) {
      _logger.i('Karakter berhasil diperbarui: $responseBody');
    } else {
      throw Exception('Update failed: ${streamedResponse.statusCode} – $responseBody');
    }
  }

  Future<List<Karakter>> searchKarakterByName(String name, {int page = 1}) async {
    final uri = Uri.parse('$_baseUrl/search').replace(
      queryParameters: {
        'name': name,
        'page': page.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData['data'] is List) {
        return (jsonData['data'] as List)
            .map((karakterJson) => Karakter.fromJson(karakterJson))
            .toList();
      } else {
        throw Exception('Invalid data format');
      }
    } else {
      throw Exception(
        'Failed to search karakter: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> deleteKarakter(int id) async {
    final uri = Uri.parse('$_baseUrl/$id');
    final response = await http.delete(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      _logger.i('Karakter berhasil dihapus');
    } else {
      throw Exception('Gagal menghapus karakter: ${response.statusCode}');
    }
  }

  Future<List<Karakter>> getAllKarakter({int page = 1, String? query}) async {
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
    print('KarakterService.getAllKarakter response: status=${response.statusCode}, body=${response.body}');
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['data'] is List) {
        return (jsonData['data'] as List)
            .map((karakterJson) => Karakter.fromJson(karakterJson))
            .toList();
      } else {
        print('KarakterService.getAllKarakter: data is not List');
        return [];
      }
    } else {
      print('KarakterService.getAllKarakter: Failed to load, status=${response.statusCode}');
      throw Exception('Failed to load karakter: ${response.statusCode} - ${response.body}');
    }
  }

}

