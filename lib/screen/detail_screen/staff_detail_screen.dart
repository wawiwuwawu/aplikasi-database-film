import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../model/staff_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../service/staff_service.dart';
import '../../service/movie_service.dart';
import '../../model/seiyu_model.dart';
import '../../model/movie_model.dart' as movie_model;
import 'movie_detail.dart';
import '../main_screen/movie_list.dart';

class StaffDetailScreen extends StatefulWidget {
  final int staffId;
  const StaffDetailScreen({required this.staffId, Key? key}) : super(key: key);

  @override
  _StaffDetailScreenState createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends State<StaffDetailScreen> {
  final StaffService _staffService = StaffService();
  final MovieApiService _movieService = MovieApiService();
  late Future<Staff> _staffFuture;

  @override
  void initState() {
    super.initState();
    _staffFuture = _staffService.getStaffDetailId(widget.staffId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Staff'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<Staff>(
        future: _staffFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final staff = snapshot.data!;
          return _buildContent(staff);
        },
      ),
    );
  }

  Widget _buildContent(Staff staff) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStaffProfile(staff),
          const SizedBox(height: 20),
          _buildBioSection(staff),
          const Divider(thickness: 1.5, height: 32),
          if (staff.movies?.isNotEmpty == true)
            _buildMovieSection(staff.movies!),
        ],
      ),
    );
  }

  Widget _buildStaffProfile(Staff staff) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: staff.profileUrl ?? '',
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

  Widget _buildBioSection(Staff staff) {
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
          staff.bio?.isNotEmpty == true ? staff.bio! : 'Tidak ada bio',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildMovieSection(List<MovieStaff> movies) {
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

  Widget _buildMovieTile(MovieStaff movie) {
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
      title: Text(movie.judul ?? 'Judul tidak tersedia'),
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
