import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../model/seiyu_model.dart';
import 'dart:io';
import 'package:logger/logger.dart';

class SeiyuApiService {
  static const String _baseUrl = 'https://api.wawunime.my.id/api/seiyu';
  final Logger _logger = Logger();

  Future<List<Seiyu>> getSeiyuDetail({int page = 1, String? query}) async {
    final uri = Uri.parse('$_baseUrl/detail').replace(
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
            .map((seiyuJson) => Seiyu.fromJson(seiyuJson))
            .toList();
      } else {
        throw Exception('Invalid API response structure');
      }
    } else if (response.statusCode == 404) {
      // Jika 404 dan error "Seiyu tidak ditemukan", kembalikan list kosong
      try {
        final jsonData = json.decode(response.body);
        if (jsonData is Map &&
            (jsonData['error'] == 'Seiyu tidak ditemukan' ||
                jsonData['error'] == 'Data tidak ditemukan')) {
          return [];
        }
      } catch (_) {}
      throw Exception(
        'Failed to load seiyu: ${response.statusCode} - ${response.body}',
      );
    } else {
      throw Exception(
        'Failed to load seiyu: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<Seiyu> getSeiyuDetailId(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/detail/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'] is Map<String, dynamic>) {
          return Seiyu.fromJson(data['data']);
        } else {
          throw Exception('Invalid response structure');
        }
      } else {
        throw Exception(
          'Failed to load karakter details. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.e('Error in getSeiyuDetailId: $e');
      throw Exception('Failed to load data: $e');
    }
  }

  Future<void> uploadSeiyu({
    required Seiyu seiyu,
    required File coverImage,
  }) async {
    final uri = Uri.parse(_baseUrl);
    final request =
        http.MultipartRequest('POST', uri)
          ..headers['Accept'] = 'application/json'
          ..fields['name'] = seiyu.name
          ..fields['bio'] = seiyu.bio ?? '';

    if (seiyu.birthday != null && seiyu.birthday!.trim().isNotEmpty) {
      request.fields['birthday'] = seiyu.birthday!.trim();
    }

    if (seiyu.websiteUrl != null && seiyu.websiteUrl!.isNotEmpty) {
      request.fields['website_url'] = seiyu.websiteUrl!;
    }
    if (seiyu.instagramUrl != null && seiyu.instagramUrl!.isNotEmpty) {
      request.fields['instagram_url'] = seiyu.instagramUrl!;
    }
    if (seiyu.twitterUrl != null && seiyu.twitterUrl!.isNotEmpty) {
      request.fields['twitter_url'] = seiyu.twitterUrl!;
    }
    if (seiyu.youtubeUrl != null && seiyu.youtubeUrl!.isNotEmpty) {
      request.fields['youtube_url'] = seiyu.youtubeUrl!;
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

  Future<void> updateSeiyu({
    required int id,
    required Seiyu seiyu,
    File? coverImage,
  }) async {
    final uri = Uri.parse('$_baseUrl/$id');
    final request =
        http.MultipartRequest('PUT', uri)
          ..headers['Accept'] = 'application/json'
          ..fields['name'] = seiyu.name
          ..fields['bio'] = seiyu.bio ?? '';

    if (seiyu.birthday != null && seiyu.birthday!.trim().isNotEmpty) {
      request.fields['birthday'] = seiyu.birthday!.trim();
    }

    if (seiyu.websiteUrl != null && seiyu.websiteUrl!.isNotEmpty) {
      request.fields['website_url'] = seiyu.websiteUrl!;
    }

    if (seiyu.instagramUrl != null && seiyu.instagramUrl!.isNotEmpty) {
      request.fields['instagram_url'] = seiyu.instagramUrl!;
    }

    if (seiyu.twitterUrl != null && seiyu.twitterUrl!.isNotEmpty) {
      request.fields['twitter_url'] = seiyu.twitterUrl!;
    }

    if (seiyu.youtubeUrl != null && seiyu.youtubeUrl!.isNotEmpty) {
      request.fields['youtube_url'] = seiyu.youtubeUrl!;
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
      return json.decode(responseBody);
    } else {
      throw Exception(
        'Update failed: ${streamedResponse.statusCode} – $responseBody',
      );
    }
  }

  Future<void> deleteSeiyu(int id) async {
    final uri = Uri.parse('$_baseUrl/$id');
    final response = await http.delete(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      _logger.i('Seiyu berhasil dihapus');
    } else {
      throw Exception('Gagal menghapus seiyu: ${response.statusCode}');
    }
  }

  Future<List<Seiyu>> searchSeiyuByName(String name, {int page = 1}) async {
    final uri = Uri.parse('$_baseUrl/search').replace(
      queryParameters: {
        'name': name,
        'page': page.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData['data'] is List) {
        return (jsonData['data'] as List)
            .map((seiyuJson) => Seiyu.fromJson(seiyuJson))
            .toList();
      } else {
        throw Exception('Invalid data format');
      }
    } else {
      // 2. (Perbaikan kecil) Mengubah pesan error agar sesuai
      throw Exception(
        'Failed to search seiyu: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<List<Seiyu>> getAllSeiyu({int page = 1, String? query}) async {
    final uri = Uri.parse('$_baseUrl').replace(
      queryParameters: {
        'page': page.toString(),
        if (query != null && query.isNotEmpty) 'search': query,
      },
    );

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    print('SeiyuService.getAllSeiyu response: status=${response.statusCode}, body=${response.body}');
    
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['data'] is List) {
        return (jsonData['data'] as List)
            .map((seiyuJson) => Seiyu.fromJson(seiyuJson))
            .toList();
      } else {
        print('SeiyuService.getAllSeiyu: data is not List');
        return [];
      }
    } else {
      print('SeiyuService.getAllSeiyu: Failed to load, status=${response.statusCode}');
      throw Exception('Failed to load seiyu: ${response.statusCode} - ${response.body}');
    }
  }
}
