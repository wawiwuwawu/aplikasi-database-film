import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadMovies() async {
    setState(() {
      _futureMovies = _apiService.getMovies(query: _searchQuery);
    });
    
    final movies = await _futureMovies;
    setState(() {
      _movies
        ..clear()
        ..addAll(movies);
    });
  }

  void _onSearchChanged() {
    _loadMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari Anime...',
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white.withOpacity(0.2),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadMovies,
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _movies.length,
          itemBuilder: (context, index) => _buildMovieCard(_movies[index]),
        ),
      ),
      floatingActionButton: Padding(
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: movie),
          ),
        );
      },
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: movie.coverUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => 
                  Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => const Icon(Icons.error),
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
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        movie.rating,
                        style: const TextStyle(fontSize: 12),
                      ),
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