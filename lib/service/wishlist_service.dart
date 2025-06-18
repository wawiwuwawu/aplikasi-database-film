import 'dart:convert';
import 'package:http/http.dart' as http;
import '../service/preferences_service.dart';

class WishlistService {
  static const String baseUrl = 'https://api.wawunime.my.id/api/list/';

  Future<List<Map<String, dynamic>>> fetchWishlist() async {
    final user = PreferencesService.getCredentials();
    if (user == null) throw Exception('User not logged in');
    final userId = user.id;
    final url = Uri.parse('$baseUrl$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      List<dynamic> data;
      if (decoded is List) {
        data = decoded;
      } else if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
        data = decoded['data'] is List ? decoded['data'] : [decoded['data']];
      } else if (decoded is Map<String, dynamic>) {
        data = [decoded];
      } else {
        data = [];
      }
      return data.map<Map<String, dynamic>>((item) {
        final movie = item['movie'] ?? {};
        return {
          'movie_id': movie['id'] ?? 0, // Pastikan gunakan 'id' dari movie
          'title': movie['judul'] ?? '',
          'status': item['status'] ?? '',
          'progress': 0.0, // API tidak ada progress, default 0
          'image': movie['cover_url'] ?? '',
          'tahun_rilis': movie['tahun_rilis'],
          'rating': movie['rating'],
        };
      }).toList();
    } else {
      throw Exception('Failed to load wishlist');
    }
  }

  Future<void> saveUserMovieStatus({required int movieId, required String status}) async {
    final user = PreferencesService.getCredentials();
    if (user == null) throw Exception('User not logged in');
    final userId = user.id;
    final response = await http.post(
      Uri.parse('https://api.wawunime.my.id/api/list'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'movieId': movieId,
        'status': status,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      print('DEBUG response.body: ' + response.body);
      String msg = 'Gagal menyimpan status movie';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          msg = decoded['message'].toString();
        } else if (decoded is String) {
          msg = decoded;
        }
      } catch (_) {
        msg = response.body;
      }
      throw Exception(msg);
    }
    return;
  }
}
