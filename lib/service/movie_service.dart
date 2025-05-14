import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

import '../model/movie_model.dart';

class MovieApiService {
  static const String _baseUrl = 'https://api.wawunime.my.id/api/movie';

  Future<List<Movie>> getMovies({int page = 1, String? query}) async {
  const String baseUrl = 'https://api.wawunime.my.id/api/movie/detail';
  
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
          .map((movieJson) => Movie.fromJson(movieJson))
          .toList();
    } else {
      throw Exception('Invalid API response structure');
    }
  } else {
    throw Exception(
      'Failed to load movies: ${response.statusCode} - ${response.body}'
    );
  }
}

  Future<Movie> getMovieDetail(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id/detail'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Movie.fromJson(data['data']);
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  Future<void> uploadMovie({
    required String judul,
    required String sinopsis,
    required int tahunRilis,
    required String type,
    required int episode,
    required int durasi,
    required String rating,
    required List<int> genreIds,
    required List<int> themeIds,
    required List<int> staffIds,
    required List<int> seiyuIds,
    required List<int> karakterIds,
    required File coverImage,
  }) async {
    final uri = Uri.parse(_baseUrl);
    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..fields['judul'] = judul
      ..fields['sinopsis'] = sinopsis
      ..fields['tahun_rilis'] = tahunRilis.toString()
      ..fields['type'] = type
      ..fields['episode'] = episode.toString()
      ..fields['durasi'] = durasi.toString()
      ..fields['rating'] = rating;

    // Kirim genreIds, themeIds, staffIds, seiyuIds, karakterIds sebagai array id dengan index
    for (var i = 0; i < genreIds.length; i++) {
      request.fields['genreIds[$i]'] = genreIds[i].toString();
    }
    for (var i = 0; i < themeIds.length; i++) {
      request.fields['themeIds[$i]'] = themeIds[i].toString();
    }
    for (var i = 0; i < staffIds.length; i++) {
      request.fields['staffIds[$i]'] = staffIds[i].toString();
    }
    for (var i = 0; i < seiyuIds.length; i++) {
      request.fields['seiyuIds[$i]'] = seiyuIds[i].toString();
    }
    for (var i = 0; i < karakterIds.length; i++) {
      request.fields['karakterIds[$i]'] = karakterIds[i].toString();
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

    if (streamedResponse.statusCode < 200 || streamedResponse.statusCode >= 300) {
      throw Exception('Upload failed: \\${streamedResponse.statusCode} - $responseBody');
    }
  }

  Future<void> updateMovie({
    required int id,
    required String judul,
    required String sinopsis,
    required int tahunRilis,
    required String type,
    required int episode,
    required int durasi,
    required String rating,
    required List<int> genreIds,
    required List<int> themeIds,
    required List<int> staffIds,
    required List<int> seiyuIds,
    required List<int> karakterIds,
    File? coverImage,
  }) async {
    final uri = Uri.parse('$_baseUrl/$id');
    final request = http.MultipartRequest('PUT', uri)
      ..headers['Accept'] = 'application/json'
      ..fields['judul'] = judul
      ..fields['sinopsis'] = sinopsis
      ..fields['tahun_rilis'] = tahunRilis.toString()
      ..fields['type'] = type
      ..fields['episode'] = episode.toString()
      ..fields['durasi'] = durasi.toString()
      ..fields['rating'] = rating;
    for (var i = 0; i < genreIds.length; i++) {
      request.fields['genreIds[$i]'] = genreIds[i].toString();
    }
    for (var i = 0; i < themeIds.length; i++) {
      request.fields['themeIds[$i]'] = themeIds[i].toString();
    }
    for (var i = 0; i < staffIds.length; i++) {
      request.fields['staffIds[$i]'] = staffIds[i].toString();
    }
    for (var i = 0; i < seiyuIds.length; i++) {
      request.fields['seiyuIds[$i]'] = seiyuIds[i].toString();
    }
    for (var i = 0; i < karakterIds.length; i++) {
      request.fields['karakterIds[$i]'] = karakterIds[i].toString();
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
    if (streamedResponse.statusCode < 200 || streamedResponse.statusCode >= 300) {
      throw Exception('Update failed: \\${streamedResponse.statusCode} - $responseBody');
    }
  }

  Future<void> deleteMovie(int id) async {
    final uri = Uri.parse('$_baseUrl/$id');
    final response = await http.delete(uri, headers: {'Accept': 'application/json'});
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Delete failed: \\${response.statusCode} - ${response.body}');
    }
  }

  Future<List<Movie>> searchMovies(String name) async {
    final uri = Uri.parse('$_baseUrl/search').replace(
      queryParameters: {
        'name': name,
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
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();
      } else {
        throw Exception('Invalid API response structure');
      }
    } else {
      throw Exception(
        'Failed to search movies: ${response.statusCode} - ${response.body}',
      );
    }
  }
}