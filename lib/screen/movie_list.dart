import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/service/preferences_service.dart';
import 'package:flutter_application_1/service/user_credential.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/movie_service.dart';
import '../model/movie_model.dart';
import '../screen/movie_detail.dart';
import '../screen/upload_data.dart';

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
  String _searchQuery = '';
  Timer? _debounce;
  Credentials? _credentials;
  bool _isLoading = false;
  bool _hasLoadedFromCache = false;
  bool _serverOffline = false; // Tambahkan state

  @override
  void initState() {
    super.initState();
    _hasLoadedFromCache = false; // Reset agar cache selalu diprioritaskan saat kembali ke halaman
    _getCredentials();
    _loadMovies(fromRefresh: true); // Selalu refresh dari server saat pertama kali buka
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions.clear();
      });
      return;
    }

    try {
      final movies = await _apiService.searchMovies(query);
      setState(() {
        _suggestions
          ..clear()
          ..addAll(movies);
      });
      print('Hasil pencarian: \\${movies.length} film ditemukan');
    } catch (e) {
      print('Error saat mencari film: \\${e}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mencari film. Server tidak merespons.')),
        );
      }
    }
  }

  Future _getCredentials() async {
    final prefs = PreferencesService.getCredentials();
    print(prefs);
    if (prefs != null) {
      setState(() {
        _credentials = prefs;
      });
    }
  }

  Future<void> _loadMovies({bool fromRefresh = false}) async {
    setState(() {
      _isLoading = true;
      if (fromRefresh) _serverOffline = false; // reset offline saat refresh
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
        final movies = await _apiService.getMovies(query: '');
        setState(() {
          _movies
            ..clear()
            ..addAll(movies);
          _serverOffline = false;
        });
        // Update cache
        await prefs.setString('cached_movies', Movie.encodeList(movies));
        _hasLoadedFromCache = true;
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
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // Daftar utama
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
                              padding: const EdgeInsets.all(8),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.6,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _movies.length,
                              itemBuilder: (context, index) => _AnimatedMovieCard(
                                index: index,
                                child: _buildMovieCard(_movies[index]),
                              ),
                            ),
                ),
                if (_suggestions.isNotEmpty)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.25, // 1/4 layar
                      color: Colors.white,
                      child: ListView.builder(
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final movie = _suggestions[index];
                          return _AnimatedMovieCard(
                            index: index,
                            child: ListTile(
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
                              onTap: () {
                                setState(() {
                                  _searchController.clear();
                                  _suggestions.clear();
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MovieDetailScreen(movie: movie),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton:
          _credentials!.role == "customer"
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
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: _SaveButton(movie: movie, iconSize: 20),
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

class _SaveButton extends StatefulWidget {
  final Movie movie;
  final double iconSize;
  const _SaveButton({required this.movie, this.iconSize = 24, Key? key}) : super(key: key);

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  String? _status;

  final List<Map<String, dynamic>> _statusOptions = [
    {'label': 'Disimpan', 'value': 'saved', 'icon': Icons.bookmark},
    {'label': 'Ditonton', 'value': 'watching', 'icon': Icons.play_circle},
    {'label': 'Sudah Ditonton', 'value': 'watched', 'icon': Icons.check_circle},
  ];

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (_status) {
      case 'saved':
        icon = Icons.bookmark;
        color = Colors.blueAccent;
        break;
      case 'watching':
        icon = Icons.play_circle;
        color = Colors.orange;
        break;
      case 'watched':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      default:
        icon = Icons.bookmark_border;
        color = Colors.grey;
    }
    return PopupMenuButton<String>(
      icon: Icon(icon, color: color, size: widget.iconSize),
      tooltip: 'Setel status film',
      constraints: const BoxConstraints(minWidth: 0, minHeight: 0), // Hilangkan padding default
      padding: EdgeInsets.zero, // Hilangkan padding default
      onSelected: (value) {
        setState(() {
          _status = value;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status film: ' + _statusLabel(value)),
            duration: const Duration(milliseconds: 800), // lebih cepat
          ),
        );
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

class _AnimatedMovieCard extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay = const Duration(milliseconds: 100);
  const _AnimatedMovieCard({required this.child, required this.index, Key? key}) : super(key: key);

  @override
  State<_AnimatedMovieCard> createState() => _AnimatedMovieCardState();
}

class _AnimatedMovieCardState extends State<_AnimatedMovieCard> with SingleTickerProviderStateMixin {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.baseDelay * widget.index, () {
      if (mounted) setState(() => _opacity = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 400),
      child: widget.child,
    );
  }
}

class SearchResultScreen extends StatelessWidget {
  final List<Movie> searchResults;

  const SearchResultScreen({Key? key, required this.searchResults})
      : super(key: key);

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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MovieDetailScreen(movie: movie),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
