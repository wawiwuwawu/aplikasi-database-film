import 'dart:convert';
import 'package:http/http.dart' as http;
import '../service/preferences_service.dart';
import '../service/user_credential.dart';

class WishlistService {
  static const String baseUrl = 'https://api.wawunime.my.id/api/list/';

  Future<List<Map<String, dynamic>>> fetchWishlist() async {
    final credentials = PreferencesService.getCredentials();
    if (credentials == null) throw Exception('User not logged in');
    final userId = credentials.id;
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
}
