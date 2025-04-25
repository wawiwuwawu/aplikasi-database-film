import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../model/movie_model.dart';

class MovieApiService {
  static const String _baseUrl = 'https://api.wawunime.my.id/api/movies';

  Future<MovieResponse> getMovies({int page = 1}) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {'page': page.toString()},
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return MovieResponse.fromJson(jsonData['data']);
    } else {
      throw Exception(
          'Failed to load movies: ${response.statusCode} - ${response.body}');
    }
  }


  Future<void> uploadMovie({
    required Movie movie,
    required File coverImage,
  }) async {
    final uri = Uri.parse('$_baseUrl/upload');
    
    var request = http.MultipartRequest('POST', uri);

    // Tambahkan fields
    request.fields.addAll({
      'judul': movie.judul,
      'sinopsis': movie.sinopsis,
      'tahun_rilis': movie.tahunRilis.toString(),
      'thema': movie.thema,
      'genre': movie.genre,
      'studio': movie.studio,
      'type': movie.type,
      'episode': movie.episode.toString(),
      'durasi': movie.durasi.toString(),
      'rating': movie.rating,
    });

    // Tambahkan file cover
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

}