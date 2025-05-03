import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../service/karakter_service.dart';
import '../model/karakter_model.dart';

class CharacterDetailScreen extends StatefulWidget {
  final int characterId;

  const CharacterDetailScreen({required this.characterId, Key? key}) : super(key: key);

  @override
  _CharacterDetailScreenState createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  final KarakterService _apiService = KarakterService();
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCharacterProfile(karakter),
                const SizedBox(height: 20),
                _buildCharacterInfo(karakter),
                const Divider(thickness: 1.5, height: 32),
                _buildRelationsSection(karakter),
              ],
            ),
          );
        },
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
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error, size: 50),
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

  Widget _buildRelationsSection(Karakter karakter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (karakter.seiyus?.isNotEmpty == true)
          _buildSection(
            title: 'Pengisi Suara',
            children: karakter.seiyus!.map(_buildSeiyuTile).toList(),
          ),
        if (karakter.movies?.isNotEmpty == true)
          _buildSection(
            title: 'Film Terkait',
            children: karakter.movies!.map(_buildMovieTile).toList(),
          ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSeiyuTile(SeiyuKarakter seiyu) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: seiyu.profileUrl.isNotEmpty
            ? CachedNetworkImageProvider(seiyu.profileUrl)
            : null,
        child: seiyu.profileUrl.isEmpty ? const Icon(Icons.person) : null,
      ),
      title: Text(seiyu.name),
      subtitle: Text(seiyu.bio),
      contentPadding: EdgeInsets.zero,
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
        ),
      ),
      title: Text(movie.judul),
      subtitle: Text('${movie.tahunRilis} • ${movie.type}'),
      contentPadding: EdgeInsets.zero,
      onTap: () {
        // Navigasi ke detail film jika diperlukan
      },
    );
  }
}