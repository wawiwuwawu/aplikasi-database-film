import 'package:flutter/material.dart';
import '../service/movie_service.dart';
import '../model/movie_model.dart';
import 'movie_upload.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final MovieApiService _apiService = MovieApiService();
  late Future<MovieResponse> _futureMovies;
  int _currentPage = 1;
  bool _hasMore = true;
  final List<Movie> _movies = [];

  @override
  void initState() {
    super.initState();
    _futureMovies = _loadMovies();
  }

  Future<MovieResponse> _loadMovies() async {
    final response = await _apiService.getMovies(page: _currentPage);
    setState(() {
      _movies.addAll(response.movies);
      _hasMore = _currentPage < response.pagination.totalPages;
    });
    return response;
  }

  void _loadNextPage() {
    if (_hasMore) {
      setState(() {
        _currentPage++;
        _futureMovies = _loadMovies();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Anime'),
      ),
      body: FutureBuilder<MovieResponse>(
        future: _futureMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () => setState(() => _futureMovies = _loadMovies()),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _movies.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _movies.length) {
                      _loadNextPage();
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _buildMovieCard(_movies[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
       floatingActionButton: Padding(
         padding: EdgeInsets.only(bottom: 80),
         child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (context) => MovieUploadPage()),
            );
            
            if (result == true) {
              setState(() {
                _movies.clear(); // Clear data lama
                _currentPage = 1; // Reset ke halaman 1
                _futureMovies = _loadMovies(); // Load data baru
              });
            }
          },
          tooltip: 'Tambah Anime Baru',
          child: Icon(Icons.add),
               ),
       ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return InkWell(
      onTap: () {} ,
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                movie.coverUrl,
                fit: BoxFit.cover,
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
                      Icon(Icons.star, color: Colors.amber, size: 16),
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