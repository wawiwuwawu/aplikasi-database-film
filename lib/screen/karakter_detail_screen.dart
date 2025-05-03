import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../service/karakter_service.dart';
import '../model/karakter_model.dart';
import '../model/movie_model.dart' as movie_model;
import '../service/movie_service.dart';
import '../screen/movie_detail.dart';

class CharacterDetailScreen extends StatefulWidget {
  final int characterId;
  const CharacterDetailScreen({required this.characterId, Key? key}) : super(key: key);

  @override
  _CharacterDetailScreenState createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  final KarakterService _apiService = KarakterService();
  final MovieApiService _movieService = MovieApiService();
  late Future<Karakter> _characterFuture;

  @override
  void initState() {
    super.initState();
    _characterFuture = _apiService.getKarakterDetailId(widget.characterId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Karakter')),
      body: FutureBuilder<Karakter>(
        future: _characterFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final karakter = snapshot.data!;
          return _buildContent(karakter);
        },
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
          if (karakter.movies?.isNotEmpty == true) _buildRelatedMovies(karakter.movies!),
        ],
      ),
    );
  }

  Widget _buildCharacterProfile(Karakter karakter) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: karakter.profileUrl,
          height: 250,
          width: 175,
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
        ...movies.map(_buildMovieTile).toList(),
      ],
    );
  }

  Widget _buildMovieTile(MovieKarakter movie) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: movie.coverUrl,
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
      Navigator.of(context).pop(); // Tutup loading dialog
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MovieDetailScreen(movie: movie),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Tutup loading dialog
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
