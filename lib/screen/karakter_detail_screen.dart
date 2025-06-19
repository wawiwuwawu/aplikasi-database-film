import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../service/karakter_service.dart';
import '../service/movie_service.dart';
import '../model/karakter_model.dart';
import '../screen/movie_detail.dart';

class CharacterDetailScreen extends StatefulWidget {
  final int characterId;
  const CharacterDetailScreen({required this.characterId, super.key});

  @override
  _CharacterDetailScreenState createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  final KarakterService _apiService = KarakterService();
  final MovieApiService _movieService = MovieApiService();
  late Future<Karakter> _characterFuture;
  bool _serverOffline = false;

  @override
  void initState() {
    super.initState();
    _serverOffline = false;
    _characterFuture = _loadCharacter();
  }

  Future<Karakter> _loadCharacter({bool fromRefresh = false}) async {
    setState(() {
      if (fromRefresh) _serverOffline = false;
    });
    try {
      final karakter = await _apiService.getKarakterDetailId(widget.characterId);
      setState(() {
        _serverOffline = false;
      });
      return karakter;
    } catch (e) {
      setState(() {
        _serverOffline = true;
      });
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Karakter'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _serverOffline
          ? RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _characterFuture = _loadCharacter(fromRefresh: true);
                });
              },
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
          : FutureBuilder<Karakter>(
              future: _characterFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: \\n${snapshot.error}'));
                }
                final karakter = snapshot.data!;
                return _buildContent(karakter);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        tooltip: 'Kembali ke Home',
        child: const Icon(Icons.home),
      ),
    );
  }

  Widget _buildContent(Karakter karakter) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCharacterProfile(karakter),
          const SizedBox(height: 20),
          _buildCharacterInfo(karakter),
          const Divider(thickness: 1.5, height: 32),
          if (karakter.movies.isNotEmpty) _buildRelatedMovies(karakter.movies),
        ],
      ),
    );
  }

  Widget _buildCharacterProfile(Karakter karakter) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: karakter.profileUrl ?? '',
          height: 300, // Tinggi foto diubah
          width: 200,  // Lebar foto diubah
          fit: BoxFit.cover,
          placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
          errorWidget: (_, __, ___) => const Icon(Icons.error, size: 50),
        ),
      ),
    );
  }

  Widget _buildCharacterInfo(Karakter karakter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          karakter.nama,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Bio',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
        ),
        const SizedBox(height: 8),
        Text(
          karakter.bio?.isNotEmpty == true ? karakter.bio! : 'Tidak ada bio',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildRelatedMovies(List<MovieKarakter> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Film Terkait',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
        ),
        const SizedBox(height: 12),
        ...movies.map(_buildMovieTile),
      ],
    );
  }

  Widget _buildMovieTile(MovieKarakter movie) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: movie.coverUrl ?? '',
          width: 50,
          height: 75,
          fit: BoxFit.cover,
          placeholder: (_, __) => const CircularProgressIndicator(),
          errorWidget: (_, __, ___) => const Icon(Icons.error),
        ),
      ),
      title: Text(movie.judul),
      subtitle: Text('${movie.tahunRilis} • ${movie.type}'),
      contentPadding: EdgeInsets.zero,
      onTap: () => _navigateToMovieDetail(movie.id),
    );
  }

  Future<void> _navigateToMovieDetail(int movieId) async {
    _showLoadingDialog();
    try {
      final movie = await _movieService.getMovieDetail(movieId);
      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MovieDetailScreen(movie: movie),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat detail film: $e')),
      );
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }
}
