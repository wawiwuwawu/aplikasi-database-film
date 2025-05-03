import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../model/seiyu_model.dart';
import 'dart:io';

class SeiyuApiService {
  static const String _baseUrl = 'https://api.wawunime.my.id/api/seiyu';

  Future<List<Seiyu>> getSeiyuDetail({int page = 1, String? query}) async {
  const String baseUrl = 'https://api.wawunime.my.id/api/seiyu/detail';
  
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
          .map((seiyuJson) => Seiyu.fromJson(seiyuJson))
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
        'Failed to load karakter details. Status: ${response.statusCode}'
      );
    }
  } catch (e) {
    print('Error in getSeiyuDetailId: $e');
    throw Exception('Failed to load data: $e');
  }
}


  Future<void> uploadSeiyu({
    required Seiyu seiyu,
    required File coverImage,
  }) async {
    final uri = Uri.parse(_baseUrl);
    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..fields['name']          = seiyu.name
      ..fields['bio']           = seiyu.bio ?? '';

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
    final responseBody    = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode >= 200 && streamedResponse.statusCode < 300) {
      return json.decode(responseBody);
    } else {
      throw Exception('Upload failed: ${streamedResponse.statusCode} – $responseBody');
    }
  }

}