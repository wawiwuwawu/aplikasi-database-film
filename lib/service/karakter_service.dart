import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../model/karakter_model.dart';
import 'dart:io';

class KarakterService {
  static const String _baseUrl = 'https://api.wawunime.my.id/api/karakter';

  Future<List<Karakter>> getKarakterDetail({int page = 1, String? query}) async {
  const String baseUrl = 'https://api.wawunime.my.id/api/karakter/detail';
  
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
    print('Error in getKarakterDetailId: $e');
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
}

