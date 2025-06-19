import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/wishlist_service.dart';
import '../service/movie_service.dart';
import '../model/movie_model.dart';
import 'movie_list.dart';
import 'movie_detail.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();

  /// Fungsi static untuk menghapus cache wishlist, panggil saat logout
  static Future<void> clearWishlistCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_wishlist');
  }
}

class _WishlistScreenState extends State<WishlistScreen> with SingleTickerProviderStateMixin {
  final WishlistService _wishlistService = WishlistService();
  final MovieApiService _movieApiService = MovieApiService();
  List<Map<String, dynamic>> _animeList = [];
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;
  final List<String> _statusTabs = ['semua', 'disimpan', 'ditonton', 'sudah ditonton'];
  bool _hasLoadedFromCache = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _fetchWishlist();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchWishlist({int retry = 2}) async {
    if (_hasLoadedFromCache && _animeList.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_wishlist');
      if (cached != null && cached.isNotEmpty) {
        try {
          final List<dynamic> decoded = jsonDecode(cached);
          final List<Map<String, dynamic>> cachedList = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          if (cachedList.isNotEmpty) {
            if (!mounted) return;
            setState(() {
              _animeList = cachedList;
              _isLoading = false;
            });
            _hasLoadedFromCache = true;
            return;
          }
        } catch (e) {
          // Jika gagal decode, hapus cache lama
          await prefs.remove('cached_wishlist');
        }
      }
      final list = await _wishlistService.fetchWishlist();
      if (!mounted) return;
      setState(() {
        _animeList = list;
        _isLoading = false;
      });
      await prefs.setString('cached_wishlist', jsonEncode(list));
      _hasLoadedFromCache = true;
    } catch (e) {
      if (retry > 0) {
        await Future.delayed(const Duration(milliseconds: 700));
        return _fetchWishlist(retry: retry - 1);
      }
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter list sesuai tab/status yang dipilih
    List<Map<String, dynamic>> filteredList;
    if (_tabController.index == 0) {
      filteredList = List<Map<String, dynamic>>.from(_animeList);
    } else {
      filteredList = _animeList.where((anime) => anime['status'] == _statusTabs[_tabController.index]).toList();
    }
    // Filter by search query (case-insensitive, by title)
    if (_searchQuery.trim().isNotEmpty) {
      filteredList = filteredList.where((anime) => (anime['title'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    // Urutkan berdasarkan warna status: biru (disimpan), oranye (ditonton), hijau (sudah ditonton)
    filteredList.sort((a, b) {
      int getStatusOrder(String? status) {
        if (status == 'disimpan') return 0;
        if (status == 'ditonton') return 1;
        if (status == 'sudah ditonton') return 2;
        return 3;
      }
      return getStatusOrder(a['status']) - getStatusOrder(b['status']);
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "List Anime Ku",
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
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search",
                    border: InputBorder.none,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : Icon(Icons.search),
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
                            onRefresh: () async {
                              _hasLoadedFromCache = false;
                              await _fetchWishlist();
                            },
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
                                            final movieId = anime['movie_id'];
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
                                                onStatusChanged: (_) async {
                                                  final prefs = await SharedPreferences.getInstance();
                                                  await prefs.remove('cached_wishlist');
                                                  _hasLoadedFromCache = false;
                                                  await _fetchWishlist();
                                                },
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
