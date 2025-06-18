import 'package:flutter/material.dart';
import '../service/wishlist_service.dart';
import '../service/movie_service.dart';
import '../model/movie_model.dart';
import 'movie_list.dart';
import 'movie_detail.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> with SingleTickerProviderStateMixin {
  final WishlistService _wishlistService = WishlistService();
  final MovieApiService _movieApiService = MovieApiService();
  List<Map<String, dynamic>> _animeList = [];
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;
  final List<String> _statusTabs = ['disimpan', 'ditonton', 'sudah ditonton'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _fetchWishlist();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    // Filter list sesuai tab/status yang dipilih
    final filteredList = _animeList.where((anime) => anime['status'] == _statusTabs[_tabController.index]).toList();
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
              const SizedBox(height: 16),
              // TabBar untuk kategori status
              TabBar(
                controller: _tabController,
                labelColor: Colors.deepPurple,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.deepPurple,
                tabs: _statusTabs.map((status) => Tab(text: status.toUpperCase())).toList(),
                onTap: (_) {
                  setState(() {}); // trigger rebuild untuk filter
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
                        : RefreshIndicator(
                            onRefresh: _fetchWishlist,
                            child: filteredList.isEmpty
                                ? Center(child: Text('Tidak ada data untuk kategori ini'))
                                : ListView.builder(
                                    itemCount: filteredList.length,
                                    itemBuilder: (context, index) {
                                      final anime = filteredList[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(8),
                                          onTap: () async {
                                            print('[DEBUG] anime item: ' + anime.toString());
                                            final movieId = anime['movieId'];
                                            if (movieId == null) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('ID film tidak ditemukan.')),
                                              );
                                              return;
                                            }
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (context) => const Center(child: CircularProgressIndicator()),
                                            );
                                            try {
                                              final detailMovie = await _movieApiService.getMovieDetail(movieId);
                                              if (mounted) {
                                                Navigator.pop(context); // tutup loading
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => MovieDetailScreen(movie: detailMovie),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (mounted) {
                                                Navigator.pop(context); // tutup loading
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Gagal memuat detail film: $e')),
                                                );
                                              }
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: SizedBox(
                                                  width: 50,
                                                  height: 75,
                                                  child: AspectRatio(
                                                    aspectRatio: 2 / 3,
                                                    child: anime['image'] != null && anime['image'].toString().isNotEmpty
                                                        ? Image.network(
                                                            anime['image'],
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
                                                          )
                                                        : const Icon(Icons.image, size: 50),
                                                  ),
                                                ),
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
                                                    Row(
                                                      children: [
                                                        Text(
                                                          anime['status'] ?? '',
                                                          style: TextStyle(
                                                            color: anime['status'] == 'disimpan'
                                                                ? Colors.blue
                                                                : anime['status'] == 'ditonton'
                                                                    ? Colors.orange
                                                                    : anime['status'] == 'sudah ditonton'
                                                                        ? Colors.green
                                                                        : Colors.grey,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ],
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
                                              SaveButton(
                                                movie: Movie(
                                                  id: anime['movie_id'] ?? 0,
                                                  judul: anime['title'] ?? '',
                                                  sinopsis: '',
                                                  tahunRilis: anime['tahun_rilis'] ?? 0,
                                                  type: anime['type'] ?? '',
                                                  episode: 0,
                                                  durasi: 0,
                                                  rating: anime['rating'] ?? '',
                                                  coverUrl: anime['image'] ?? '',
                                                  genres: [],
                                                  themes: [],
                                                  staffs: [],
                                                  seiyus: [],
                                                  karakters: [],
                                                ),
                                                iconSize: 20,
                                                initialStatus: anime['status'],
                                              ),
                                            ],
                                          ),
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
