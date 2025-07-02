import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weebase/model/movie_model.dart';
import 'package:weebase/service/movie_service.dart';
import 'package:weebase/screen/form_upload/movie_upload.dart';

class MovieUploadListScreen extends StatefulWidget {
  const MovieUploadListScreen({super.key});

  @override
  State<MovieUploadListScreen> createState() => _movieUploadListScreenState();
}

class _movieUploadListScreenState extends State<MovieUploadListScreen> {
  List<Movie> _movieList = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  final int _perPage = 25;
  final ScrollController _scrollController = ScrollController();
  bool _serverOffline = false;

  // State untuk pencarian
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchMovie();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Fungsi untuk mereset daftar dan memulai pencarian/refresh baru
  void _resetAndFetch() {
    setState(() {
      _movieList.clear();
      _currentPage = 1;
      _hasMore = true;
      _error = null;
      _serverOffline = false;
    });
    _fetchMovie();
  }

  Future<void> _fetchMovie() async {
    if (_isLoading || !_hasMore) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      late final List<Movie> list;

      if (_searchQuery.isEmpty) {
        list = await MovieApiService().getMovies(
          page: _currentPage,
        );
      } else {
        // Jika mencari, panggil service search dengan menyertakan halaman
        list = await MovieApiService().searchMovies(
          _searchQuery,
          page: _currentPage, // Tambahkan parameter halaman di sini
        );
      }

      // Setelah mendapatkan data, update UI
      setState(() {
        if (list.length < _perPage) {
          _hasMore = false;
        }
        _movieList.addAll(list);
        _isLoading = false;
        _currentPage++; // Selalu naikkan halaman setelah fetch berhasil
      });
    } catch (e, s) {
      print('Error fetching movie: $e');
      print(s);
      setState(() {
        _error = e.toString();
        _isLoading = false;
        if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
          _serverOffline = true;
        }
      });
    }
  }
  // --- BATAS AKHIR FUNGSI YANG DIGANTI ---

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _fetchMovie();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari movie...',
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        if (_searchQuery.isNotEmpty) {
                          setState(() => _searchQuery = '');
                          _resetAndFetch();
                        }
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                if (_searchQuery != value) {
                  setState(() => _searchQuery = value);
                  _resetAndFetch();
                }
              });
            },
          ),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MovieFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Movie',
      ),
    );
  }

  Widget _buildBody() {
    if (_movieList.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_serverOffline) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text('Server Offline', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              onPressed: _resetAndFetch,
            ),
          ],
        ),
      );
    }

    if (_movieList.isEmpty && !_isLoading) {
      return Center(
        child: Text(_error != null ? 'Error: $_error' : 'Tidak ada movie ditemukan.'),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        _searchController.clear();
        setState(() => _searchQuery = '');
        _resetAndFetch();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _movieList.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == _movieList.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final movie = _movieList[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: ListTile(
                leading: movie.coverUrl != null && movie.coverUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          movie.coverUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(Icons.person, size: 48),
                        ),
                      )
                    : const Icon(Icons.person, size: 48),
                title: Text(movie.judul, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ID: ${movie.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                onTap: () async {
                  // Tampilkan loading indicator kecil di tengah layar
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(child: CircularProgressIndicator());
                    },
                  );

                  try {
                    // 1. Ambil detail LENGKAP dari movie berdasarkan ID
                    final movieDetail = await MovieApiService().getMovieDetail(movie.id);

                    // 2. Tutup loading indicator
                    Navigator.of(context).pop();

                    // 3. Pindah halaman dengan membawa data yang sudah lengkap
                    if (mounted) { // Pastikan widget masih ada sebelum navigasi
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieFormPage(movie: movieDetail),
                        ),
                      );
                    }
                  } catch (e) {
                    // Jika gagal, tutup loading dan tampilkan error
                    Navigator.of(context).pop();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal mengambil detail: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}