import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:weebase/service/seiyu_service.dart';
import 'package:weebase/service/movie_service.dart';
import 'package:weebase/model/seiyu_model.dart';
import 'movie_detail.dart';

class SeiyuDetailScreen extends StatefulWidget {
  final int seiyuId;
  const SeiyuDetailScreen({required this.seiyuId, Key? key}) : super(key: key);

  @override
  _SeiyuDetailScreenState createState() => _SeiyuDetailScreenState();
}

class _SeiyuDetailScreenState extends State<SeiyuDetailScreen> {
  final SeiyuApiService _seiyuService = SeiyuApiService();
  final MovieApiService _movieService = MovieApiService();
  late Future<Seiyu> _seiyuFuture;
  bool _serverOffline = false;

  @override
  void initState() {
    super.initState();
    _serverOffline = false;
    _seiyuFuture = _loadSeiyu();
  }

  Future<Seiyu> _loadSeiyu({bool fromRefresh = false}) async {
    setState(() {
      if (fromRefresh) _serverOffline = false;
    });
    try {
      final seiyu = await _seiyuService.getSeiyuDetailId(widget.seiyuId);
      setState(() {
        _serverOffline = false;
      });
      return seiyu;
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
        title: const Text('Detail Seiyu'),
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
                  _seiyuFuture = _loadSeiyu(fromRefresh: true);
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
          : FutureBuilder<Seiyu>(
              future: _seiyuFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: \\n${snapshot.error}'));
                }
                final seiyu = snapshot.data!;
                return _buildContent(seiyu);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        child: const Icon(Icons.home),
        tooltip: 'Kembali ke Home',
      ),
    );
  }

  Widget _buildContent(Seiyu seiyu) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSeiyuProfile(seiyu),
          const SizedBox(height: 20),
          _buildBioSection(seiyu),
          const Divider(thickness: 1.5, height: 32),
          if (seiyu.karakters.isNotEmpty) _buildCharacterSection(seiyu.karakters),
          const Divider(thickness: 1.5, height: 32),
          if (seiyu.movies.isNotEmpty) _buildMovieSection(seiyu.movies),
        ],
      ),
    );
  }

  Widget _buildSeiyuProfile(Seiyu seiyu) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: seiyu.profileUrl ?? '',
          width: 185,
          height: 275,
          fit: BoxFit.cover,
          placeholder:
              (_, __) => const Center(child: CircularProgressIndicator()),
          errorWidget: (_, __, ___) => const Icon(Icons.error, size: 50),
        ),
      ),
    );
  }

  Widget _buildBioSection(Seiyu seiyu) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Biografi',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          seiyu.bio?.isNotEmpty == true ? seiyu.bio! : 'Tidak ada bio',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildCharacterSection(List<KarakterSeiyu> karakters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Karakter yang Diisi Suara',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        const SizedBox(height: 12),
        ...karakters.map(_buildCharacterTile).toList(),
      ],
    );
  }

  Widget _buildCharacterTile(KarakterSeiyu karakter) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: karakter.profileUrl ?? '',
          width: 50,
          height: 75,
          fit: BoxFit.cover,
          placeholder: (_, __) => const CircularProgressIndicator(),
          errorWidget: (_, __, ___) => const Icon(Icons.error),
        ),
      ),
      title: Text(karakter.nama),
      subtitle: Text(karakter.bio ?? 'Bio tidak tersedia'),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildMovieSection(List<MovieSeiyu> movies) {
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

  Widget _buildMovieTile(MovieSeiyu movie) {
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
      subtitle: Text('${movie.tahunRilis ?? 'N/A'} • ${movie.type ?? 'N/A'}'),
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
        MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Tutup loading dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat detail film: $e')));
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
