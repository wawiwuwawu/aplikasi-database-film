import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:weebase/service/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/movie_service.dart';
import '../service/wishlist_service.dart';
import '../model/movie_model.dart';
import '../screen/movie_detail.dart';
import '../screen/upload_data.dart';
import '../model/user_model.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final MovieApiService _apiService = MovieApiService();
  late Future<List<Movie>> _futureMovies;
  final List<Movie> _movies = [];
  final List<Movie> _suggestions = [];
  final TextEditingController _searchController = TextEditingController();
  final String _searchQuery = '';
  Timer? _debounce;
  User? _user;  
  bool _isLoading = false;
  bool _hasLoadedFromCache = false;
  bool _serverOffline = false; // Tambahkan state
  bool _isSearching = false;
  bool _searchLoading = false;
  DateTime? _last429Time;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  Map<int, String> _userMovieStatus = {}; // movieId -> status

  @override
  void initState() {
    super.initState();
    _getUserData();
    _loadAllData();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadAllData() async {
    if (_hasLoadedFromCache && _movies.isNotEmpty) {
      // Jika sudah pernah load dari cache dan data masih ada, tidak perlu request ulang
      setState(() {
        _isLoading = false;
        _serverOffline = false;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _serverOffline = false;
    });
    try {
      final fetchedUser = PreferencesService.getCredentials();
      if (fetchedUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      // Ambil data film dan wishlist user bersamaan
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_movies');
      if (cached != null && cached.isNotEmpty) {
        final cachedMovies = Movie.decodeList(cached);
        if (cachedMovies.isNotEmpty) {
          setState(() {
            _movies
              ..clear()
              ..addAll(cachedMovies);
            _isLoading = false;
            _serverOffline = false;
          });
          _hasLoadedFromCache = true;
          await _fetchUserWishlist(); // Tambahkan ini agar status film tetap terisi
          return;
        }
      }
      final results = await Future.wait([
        _apiService.getMovies(query: '', page: 1),
        WishlistService().fetchWishlist(),
      ]);
      final movies = results[0] as List<Movie>;
      final wishlist = results[1] as List<Map<String, dynamic>>;
      final Map<int, String> statusMap = {};
      for (var item in wishlist) {
        if (item['movie_id'] != null && item['status'] != null && item['status'] != '') {
          statusMap[item['movie_id'] as int] = item['status'] as String;
        }
      }
      for (var item in wishlist) {
        if (item['movie_id'] == null && item['title'] != null && item['status'] != null && item['status'] != '' && movies.isNotEmpty) {
          final matches = movies.where((m) => m.judul == item['title']);
          if (matches.isNotEmpty) {
            final movie = matches.first;
            statusMap[movie.id] = item['status'] as String;
          }
        }
      }
      setState(() {
        _movies
          ..clear()
          ..addAll(movies);
        _userMovieStatus = statusMap;
        _isLoading = false;
        _serverOffline = false;
        _currentPage = 1;
        _hasMore = movies.length >= 5;
      });
      // Update cache
      await prefs.setString('cached_movies', Movie.encodeList(movies));
      _hasLoadedFromCache = true;
    } catch (e) {
      print('Error saat memuat film/wishlist: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (_movies.isEmpty) _serverOffline = true;
      });
      if (_movies.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data film.')),
        );
      }
    }
  }

  Future<void> _fetchUserWishlist() async {
    try {
      final wishlist = await WishlistService().fetchWishlist();
      final Map<int, String> statusMap = {};
      for (var item in wishlist) {
        if (item['movie_id'] != null && item['status'] != null && item['status'] != '') {
          statusMap[item['movie_id'] as int] = item['status'] as String;
        }
      }
      // Fallback jika tidak ada movie_id, gunakan title mapping (tidak disarankan, sebaiknya backend kembalikan movie_id)
      for (var item in wishlist) {
        if (item['movie_id'] == null && item['title'] != null && item['status'] != null && item['status'] != '' && _movies.isNotEmpty) {
          final matches = _movies.where((m) => m.judul == item['title']);
          if (matches.isNotEmpty) {
            final movie = matches.first;
            statusMap[movie.id] = item['status'] as String;
          }
        }
      }
      setState(() {
        _userMovieStatus = statusMap;
      });
    } catch (e) {
      // ignore error
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
  void performSearch(String query, {bool silent = false}) async {
    if (query.isEmpty || query.length < 3) {
      setState(() {
        _suggestions.clear();
        _searchLoading = false;
      });
      return;
    }
    if (_isSearching) return;
    if (_last429Time != null && DateTime.now().difference(_last429Time!) < Duration(seconds: 3)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tunggu sebentar sebelum mencari lagi.')),
        );
      }
      return;
    }
    _isSearching = true;
    setState(() { _searchLoading = true; });
    try {
      final movies = await _apiService.searchMovies(query);
      if (!mounted) return;
      setState(() {
        _suggestions
          ..clear()
          ..addAll(movies);
        _searchLoading = false;
      });
      print('Hasil pencarian: \\${movies.length} film ditemukan');
    } catch (e) {
      print('Error saat mencari film: \\$e');
      if (mounted) {
        String msg = 'Gagal mencari film. Server tidak merespons.';
        if (e.toString().contains('429')) {
          msg = 'Terlalu cepat, tunggu sebentar.';
          _last429Time = DateTime.now();
        }
        setState(() { _searchLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } finally {
      _isSearching = false;
    }
  }

  Future<void> _getUserData() async {
    final fetchedUser = PreferencesService.getCredentials();
    if (fetchedUser != null) {
      setState(() {
        _user = fetchedUser;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoadingMore && _hasMore && !_isLoading) {
      _fetchMoreMovies();
    }
  }

  Future<void> _fetchMoreMovies() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() { _isLoadingMore = true; });
    try {
      final nextPage = _currentPage + 1;
      final movies = await _apiService.getMovies(query: '', page: nextPage);
      if (movies.isNotEmpty) {
        setState(() {
          _movies.addAll(movies);
          _currentPage = nextPage;
          _hasMore = movies.length >= 5; // ubah page size ke 5
        });
      } else {
        setState(() { _hasMore = false; });
      }
    } catch (e) {
      setState(() { _hasMore = false; });
    } finally {
      setState(() { _isLoadingMore = false; });
    }
  }

  Future<void> _loadMovies({bool fromRefresh = false}) async {
    setState(() {
      _isLoading = true;
      if (fromRefresh) _serverOffline = false; // reset offline saat refresh
      if (fromRefresh) {
        _currentPage = 1;
        _hasMore = true;
      }
    });
    final prefs = await SharedPreferences.getInstance();
    if (!fromRefresh && !_hasLoadedFromCache) {
      // Try loading from cache first
      final cached = prefs.getString('cached_movies');
      if (cached != null && cached.isNotEmpty) {
        final cachedMovies = Movie.decodeList(cached);
        if (cachedMovies.isNotEmpty) {
          setState(() {
            _movies
              ..clear()
              ..addAll(cachedMovies);
          });
          _hasLoadedFromCache = true;
        }
      }
    }
    if (fromRefresh || !_hasLoadedFromCache) {
      try {
        final movies = await _apiService.getMovies(query: '', page: 1);
        if (!mounted) return;
        setState(() {
          _movies
            ..clear()
            ..addAll(movies);
          _serverOffline = false;
          _currentPage = 1;
          _hasMore = movies.length >= 5; // ubah page size ke 5
        });
        // Update cache
        await prefs.setString('cached_movies', Movie.encodeList(movies));
        _hasLoadedFromCache = true;
        await _fetchUserWishlist(); // <-- Tambahkan ini setelah _movies diisi
      } catch (e) {
        print('Error saat memuat film: $e');
        if (_movies.isEmpty) {
          setState(() {
            _serverOffline = true;
          });
        }
        if (_movies.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat data film.')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      await _fetchUserWishlist(); // <-- Tambahkan ini juga jika tidak refresh
    }
  }
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1200), () {
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        performSearch(query);
      } else {
        setState(() {
          _suggestions.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: (value) {
            if (value.isNotEmpty) {
              performSearch(value);
            } else {
              setState(() {
                _suggestions.clear();
              });
            }
          },
          onSubmitted: (value) async {
            final movies = await _apiService.searchMovies(value);
            setState(() {
              _searchController.clear();
              _suggestions.clear();
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchResultScreen(searchResults: movies),
              ),
            );
          },
          decoration: InputDecoration(
            hintText: 'Cari Anime...',
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _suggestions.clear();
                      });
                      _loadMovies();
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.2),
          ),
        ),
      ),
      body: _serverOffline
          ? RefreshIndicator(
              onRefresh: () => _loadMovies(fromRefresh: true),
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'Server offline\nTarik ke bawah untuk mencoba lagi',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: Icon(Icons.refresh),
                            label: Text('Coba Muat Lagi'),
                            onPressed: () async {
                              await _loadMovies(fromRefresh: true);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // Daftar utama (GridView langsung, tanpa Column/Expanded)
                RefreshIndicator(
                  onRefresh: () => _loadMovies(fromRefresh: true),
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _movies.isEmpty
                          ? Center(
                              child: Text(
                                _searchController.text.isEmpty
                                    ? 'Tidak ada film tersedia'
                                    : 'Tidak ada hasil ditemukan',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                            )
                          : GridView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(8),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.6,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _movies.length + (_isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index < _movies.length) {
                                  return _buildMovieCard(_movies[index]);
                                } else {
                                  return Center(child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ));
                                }
                              },
                            ),
                ),
                // Suggestion search (hanya jika ada)
                if (_suggestions.isNotEmpty)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Material(
                      elevation: 4,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.25, // 1/4 layar
                        color: Colors.white,
                        child: ListView.builder(
                          itemCount: _suggestions.length,
                          itemBuilder: (context, index) {
                            final movie = _suggestions[index];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: movie.coverUrl,
                                  width: 50,
                                  height: 75,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Container(color: Colors.grey[200]),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                              title: Text(
                                movie.judul,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${movie.tahunRilis} • ${movie.type}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                              onTap: () async {
                                // Tampilkan loading dialog
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(child: CircularProgressIndicator()),
                                );
                                try {
                                  final detailMovie = await _apiService.getMovieDetail(movie.id);
                                  if (mounted) {
                                    Navigator.pop(context); // tutup loading
                                    setState(() {
                                      _searchController.clear();
                                      _suggestions.clear();
                                    });
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
                                      SnackBar(content: Text('Gagal memuat detail film.')),
                                    );
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                // Sticky mini FAB refresh di bawah
                if (!_hasMore && _movies.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 24 + MediaQuery.of(context).padding.bottom,
                    child: Center(
                      child: FloatingActionButton(
                        mini: true,
                        heroTag: 'refresh_fab',
                        onPressed: () async {
                          setState(() { _hasMore = true; });
                          await _fetchMoreMovies();
                        },
                        child: const Icon(Icons.refresh),
                        tooltip: 'Coba Muat Lagi',
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton:
          _user!.role == "customer"
              ? const SizedBox.shrink()
              : Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: FloatingActionButton(
                  onPressed: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (context) => AdminMenuPage()),
                    );

                    if (result == true) {
                      await _loadMovies();
                    }
                  },
                  tooltip: 'Tambah Anime Baru',
                  child: const Icon(Icons.add),
                ),
              ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return InkWell(
      onTap: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
        try {
          final detailMovie = await _apiService.getMovieDetail(movie.id);
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
              SnackBar(content: Text('Gagal memuat detail film.')),
            );
          }
        }
      },
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: movie.coverUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: (_user != null && _user!.role == "admin") ? 8 : 0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: SaveButton(
                            movie: movie,
                            iconSize: 20,
                            initialStatus: _userMovieStatus[movie.id],
                            onStatusChanged: (_) async {
                              // Hapus cache wishlist agar wishlist selalu up-to-date
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.remove('cached_wishlist');
                            },
                          ),
                        ),
                        if (_user != null && _user!.role == "admin")
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              tooltip: 'Quick Remove',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Konfirmasi Hapus'),
                                    content: Text('Yakin ingin menghapus "${movie.judul}"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const Center(child: CircularProgressIndicator()),
                                  );
                                  try {
                                    await _apiService.deleteMovie(movie.id);
                                    if (mounted) {
                                      setState(() {
                                        _movies.removeWhere((m) => m.id == movie.id);
                                      });
                                      Navigator.pop(context); // tutup loading
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Berhasil menghapus film.')),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      Navigator.pop(context); // tutup loading
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Gagal menghapus film.')),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.judul,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${movie.tahunRilis} • ${movie.type}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(movie.rating, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SaveButton extends StatefulWidget {
  final Movie movie;
  final double iconSize;
  final String? initialStatus;
  final void Function(String)? onStatusChanged;
  const SaveButton({required this.movie, this.iconSize = 24, this.initialStatus, this.onStatusChanged, super.key});

  @override
  State<SaveButton> createState() => SaveButtonState();
}

class SaveButtonState extends State<SaveButton> {
  String? _status;
  bool _isLoading = false;
  final List<Map<String, dynamic>> _statusOptions = [
    {'label': 'Disimpan', 'value': 'disimpan', 'icon': Icons.bookmark},
    {'label': 'Ditonton', 'value': 'ditonton', 'icon': Icons.play_circle},
    {'label': 'Sudah Ditonton', 'value': 'sudah ditonton', 'icon': Icons.check_circle},
  ];

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
  }

  @override
  void didUpdateWidget(covariant SaveButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialStatus != oldWidget.initialStatus) {
      setState(() {
        _status = widget.initialStatus;
      });
    }
  }

  Future<void> _saveStatus(String value) async {
    final user = PreferencesService.getCredentials();
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda harus login untuk menyimpan status.')),
        );
      }
      return;
    }
    setState(() => _isLoading = true);
    try {
      await WishlistService().saveUserMovieStatus(
        movieId: widget.movie.id,
        status: value,
      );
      if (!mounted) return;
      setState(() {
        _status = value;
      });
      if (widget.onStatusChanged != null) {
        widget.onStatusChanged!(value);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status film: ${_statusLabel(value)}'),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 1200),
        ),
      );
    } catch (e) {
      print('DEBUG error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan status: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 1800),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (_status) {
      case 'disimpan':
        icon = Icons.bookmark;
        color = Colors.blueAccent;
        break;
      case 'ditonton':
        icon = Icons.play_circle;
        color = Colors.orange;
        break;
      case 'sudah ditonton':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      default:
        icon = Icons.bookmark_border;
        color = Colors.grey;
    }
    return _isLoading
        ? SizedBox(
            width: widget.iconSize,
            height: widget.iconSize,
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
        : PopupMenuButton<String>(
            icon: Icon(icon, color: color, size: widget.iconSize),
            tooltip: 'Setel status film',
            constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            padding: EdgeInsets.zero,
            onSelected: (value) {
              _saveStatus(value);
            },
            itemBuilder: (context) => _statusOptions.map((item) => PopupMenuItem<String>(
              value: item['value'] as String,
              child: Row(
                children: [
                  Icon(item['icon'] as IconData, color: _status == item['value'] ? Theme.of(context).colorScheme.primary : Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(item['label'] as String),
                ],
              ),
            )).toList(),
          );
  }

  String _statusLabel(String value) {
    return _statusOptions.firstWhere((item) => item['value'] == value)['label'] as String;
  }
}

class SearchResultScreen extends StatelessWidget {
  final List<Movie> searchResults;

  const SearchResultScreen({super.key, required this.searchResults});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Pencarian'),
      ),
      body: searchResults.isEmpty
          ? Center(
              child: Text(
                'Tidak ada hasil ditemukan',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final movie = searchResults[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: movie.coverUrl,
                        width: 50,
                        height: 75,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                    title: Text(
                      movie.judul,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${movie.tahunRilis} • ${movie.type}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    onTap: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );
                      try {
                        final detailMovie = await MovieApiService().getMovieDetail(movie.id);
                        if (context.mounted) {
                          Navigator.pop(context); // tutup loading
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailScreen(movie: detailMovie),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(context); // tutup loading
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal memuat detail film.')),
                          );
                        }
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
