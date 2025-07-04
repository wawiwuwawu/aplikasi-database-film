import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weebase/service/wishlist_service.dart';
import 'package:weebase/service/movie_service.dart';
import 'package:weebase/model/movie_model.dart';
import 'package:weebase/screen/main_screen/movie_list.dart' as movie_list;
import 'package:weebase/screen/detail_screen/movie_detail.dart';

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
  BuildContext? _scaffoldContext;

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
          
          // Validasi setiap item cache memiliki movie_id
          bool isValidCache = cachedList.every((item) => 
            item.containsKey('movie_id') && 
            item['movie_id'] != null && 
            item['movie_id'] != 0
          );
          
          if (cachedList.isNotEmpty && isValidCache) {
            if (!mounted) return;
            setState(() {
              _animeList = cachedList;
              _isLoading = false;
            });
            _hasLoadedFromCache = true;
            return;
          } else {
            await prefs.remove('cached_wishlist');
          }
        } catch (e) {
          // Jika gagal decode, hapus cache lama
          await prefs.remove('cached_wishlist');
        }
      }
      
      final list = await _wishlistService.fetchWishlist();
      
      // Validasi data dari API juga
      final validList = list.where((item) => 
        item.containsKey('movie_id') && 
        item['movie_id'] != null && 
        item['movie_id'] != 0
      ).toList();
      
      if (!mounted) return;
      setState(() {
        _animeList = validList;
        _isLoading = false;
      });
      await prefs.setString('cached_wishlist', jsonEncode(validList));
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
      body: Builder(
        builder: (scaffoldContext) {
          _scaffoldContext = scaffoldContext;
          return SafeArea(
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
                                                final movieId = anime['movie_id'];
                                                if (movieId == null) {
                                                  if (_scaffoldContext != null) {
                                                    ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
                                                      SnackBar(content: Text('ID film tidak ditemukan.')),
                                                    );
                                                  }
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
                                                    if (_scaffoldContext != null) {
                                                      ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
                                                        SnackBar(content: Text('Gagal memuat detail film: $e')),
                                                      );
                                                    }
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
                                                  movie_list.SaveButton(
                                                    movie: Movie(
                                                      id: anime['movie_id'] ?? 0,
                                                      judul: anime['title']?.toString() ?? '',
                                                      sinopsis: '',
                                                      tahunRilis: int.tryParse(anime['tahun_rilis']?.toString() ?? '') ?? 0,
                                                      type: anime['type']?.toString() ?? '',
                                                      episode: 0,
                                                      durasi: 0,
                                                      rating: anime['rating']?.toString() ?? '',
                                                      coverUrl: anime['image']?.toString() ?? '',
                                                      genres: [],
                                                      themes: [],
                                                      staffs: [],
                                                      seiyus: [],
                                                      karakters: [],
                                                      savedCount: 0,
                                                      watchingCount: 0,
                                                      finishedCount: 0,
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
                                                  // TOMBOL HAPUS LIST - hanya tampil jika movie_id valid
                                                  if (anime['movie_id'] != null && anime['movie_id'] != 0)
                                                    IconButton(
                                                      icon: const Icon(Icons.delete, color: Colors.red),
                                                      tooltip: 'Hapus dari List',
                                                      onPressed: () async {
                                                        final confirm = await showDialog<bool>(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: const Text('Konfirmasi'),
                                                          content: const Text('Yakin ingin menghapus anime ini dari list?'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.pop(context, false),
                                                              child: const Text('Batal'),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () => Navigator.pop(context, true),
                                                              child: const Text('Hapus'),
                                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                            ),
                                                          ],
                                                        ),
                                                      );

                                                      if (confirm != true) return;

                                                      // 1. Simpan item yang akan dihapus dan indexnya, untuk jaga-jaga jika gagal.
                                                      final itemToDelete = anime;
                                                      final indexToDelete = filteredList.indexOf(itemToDelete);

                                                      // 2. Hapus item dari UI secara langsung (Optimistic UI)
                                                      setState(() {
                                                        _animeList.removeWhere((item) => item['movie_id'] == itemToDelete['movie_id']);
                                                      });

                                                      // Siapkan ScaffoldMessenger sebelum await
                                                      final scaffoldMessenger = _scaffoldContext != null 
                                                          ? ScaffoldMessenger.of(_scaffoldContext!)
                                                          : ScaffoldMessenger.of(context);

                                                      try {
                                                        // 3. Panggil API untuk menghapus data di backend.
                                                        await _wishlistService.deleteUserMovie(movieId: itemToDelete['movie_id']);

                                                        // 4. Jika berhasil, perbarui cache lokal dengan data terbaru.
                                                        final prefs = await SharedPreferences.getInstance();
                                                        await prefs.setString('cached_wishlist', jsonEncode(_animeList));

                                                        scaffoldMessenger.showSnackBar(
                                                          const SnackBar(
                                                            content: Text('Berhasil dihapus dari list!'),
                                                            backgroundColor: Colors.green,
                                                          ),
                                                        );
                                                      } catch (e) {
                                                        // 5. JIKA GAGAL: Kembalikan item ke UI dan tampilkan error.
                                                        setState(() {
                                                          // Masukkan kembali item ke posisi semula agar urutan tidak berubah
                                                          if (indexToDelete >= 0 && indexToDelete < _animeList.length) {
                                                            _animeList.insert(indexToDelete, itemToDelete);
                                                          } else {
                                                            _animeList.add(itemToDelete); // Fallback jika index tidak ditemukan
                                                          }
                                                        });

                                                        scaffoldMessenger.showSnackBar(
                                                          SnackBar(
                                                            content: Text('Gagal menghapus: $e'),
                                                            backgroundColor: Colors.red,
                                                          ),
                                                        );                                                        }
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
          );
        },
      ),
    );
  }
}
