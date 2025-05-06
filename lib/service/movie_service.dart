import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
    required Movie movie,
    required File coverImage,
  }) async {
    final uri = Uri.parse('$_baseUrl/upload');
    
    var request = http.MultipartRequest('POST', uri);

    final genresJson = json.encode(movie.genres.map((g) => g.id).toList());
    final themesJson = json.encode(movie.themes.map((t) => t.id).toList());
    final staffsJson = json.encode(movie.staffs.map((s) => s.toJson()).toList());
    final seiyusJson = json.encode(movie.seiyus.map((s) => s.toJson()).toList());
    final karaktersJson = json.encode(movie.karakters.map((k) => k.toJson()).toList());

    request.fields.addAll({
      'judul': movie.judul,
      'sinopsis': movie.sinopsis,
      'tahun_rilis': movie.tahunRilis.toString(),
      'type': movie.type,
      'episode': movie.episode.toString(),
      'durasi': movie.durasi.toString(),
      'rating': movie.rating,
      'genres': genresJson,
      'themes': themesJson,
      'staffs': staffsJson,
      'seiyus': seiyusJson,
      'karakters': karaktersJson,
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'cover', 
        coverImage.path,
      ),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode} - $responseBody');
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