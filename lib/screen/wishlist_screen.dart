import 'package:flutter/material.dart';
import '../service/wishlist_service.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService _wishlistService = WishlistService();
  List<Map<String, dynamic>> _animeList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  Future<void> _fetchWishlist() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await _wishlistService.fetchWishlist();
      setState(() {
        _animeList = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Anime List",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Search Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(0xFFF1E9F6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search",
                    border: InputBorder.none,
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Watching",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
                        : RefreshIndicator(
                            onRefresh: _fetchWishlist,
                            child: _animeList.isEmpty
                                ? Center(child: Text('Tidak ada data wishlist'))
                                : ListView.builder(
                                    itemCount: _animeList.length,
                                    itemBuilder: (context, index) {
                                      final anime = _animeList[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: anime['image'] != null && anime['image'].toString().isNotEmpty
                                                  ? Image.network(
                                                      anime['image'],
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
                                                    )
                                                  : const Icon(Icons.image, size: 50),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    anime['title'] ?? '',
                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      if (anime['tahun_rilis'] != null)
                                                        Text('${anime['tahun_rilis']}', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                                      if (anime['tahun_rilis'] != null && anime['rating'] != null)
                                                        Text(' • ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                                      if (anime['rating'] != null)
                                                        Text('${anime['rating']}', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    anime['status'] ?? '',
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  LinearProgressIndicator(
                                                    value: anime['progress'] ?? 0.0,
                                                    backgroundColor: Colors.grey.shade300,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      Colors.blue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              children: [
                                                Icon(Icons.arrow_upward, size: 20),
                                                Icon(Icons.text_fields, size: 20),
                                              ],
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
