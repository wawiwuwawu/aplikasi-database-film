import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../model/movie_model.dart';
import 'karakter_detail_screen.dart';
import 'seiyu_detail_screen.dart';
import 'staff_detail_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  const MovieDetailScreen({required this.movie, super.key});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isSynopsisExpanded = false;
  bool _serverOffline = false;
  late Future<Movie> _movieFuture;

  @override
  void initState() {
    super.initState();
    _serverOffline = false;
    _movieFuture = _loadMovie();
  }

  Future<Movie> _loadMovie({bool fromRefresh = false}) async {
    setState(() {
      if (fromRefresh) _serverOffline = false;
    });
    try {
      // Simulasi: movie detail sudah diterima via widget.movie, tidak fetch ulang
      // Jika ingin fetch ulang dari API, ganti dengan service.getMovieDetail(widget.movie.id)
      setState(() {
        _serverOffline = false;
      });
      return widget.movie;
    } catch (e) {
      setState(() {
        _serverOffline = true;
      });
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.judul),
        elevation: 0,
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
                  _movieFuture = _loadMovie(fromRefresh: true);
                });
                await _movieFuture;
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
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _movieFuture = _loadMovie(fromRefresh: true);
                });
                await _movieFuture;
              },
              child: FutureBuilder<Movie>(
                future: _movieFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: \n${snapshot.error}'));
                  }
                  final movie = snapshot.data!;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCoverImage(movie.coverUrl),
                        const SizedBox(height: 20),
                        _buildBasicInfoSection(movie),
                        _buildSectionDivider(),
                        _buildListSection('Genres', movie.genres, (g) => g.nama),
                        _buildListSection('Themes', movie.themes, (t) => t.nama),
                        _buildSectionDivider(),
                        _buildStaffSection(movie.staffs),
                        _buildSectionDivider(),
                        _buildSeiyuSection(movie.seiyus, movie.karakters),
                        _buildSectionDivider(),
                        _buildCharacterSection(movie.karakters),
                      ],
                    ),
                  );
                },
              ),
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

  Widget _buildCoverImage(String? url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: url ?? '',
        width: 200, // Lebar penuh layar
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
      ),
    );
  }

  Widget _buildPlaceholder() => Container(
    width: 200,
    height: 200,
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Center(child: CircularProgressIndicator()),
  );

  Widget _buildErrorWidget() => Container(
    width: 200,
    height: 200,
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Icon(Icons.error, size: 40, color: Colors.red),
  );

  Widget _buildBasicInfoSection(Movie movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildInfoChip(Icons.calendar_today, '${movie.tahunRilis}'),
            const SizedBox(width: 8),
            _buildInfoChip(Icons.movie_filter, movie.type),
            const SizedBox(width: 8),
            _buildInfoChip(Icons.star, movie.rating),
          ],
        ),
        const SizedBox(height: 16),
        Text('Sinopsis', style: _sectionTitleStyle(context)),
        const SizedBox(height: 8),
        Text(
          movie.sinopsis.isNotEmpty ? movie.sinopsis : 'Tidak ada sinopsis',
          maxLines: _isSynopsisExpanded ? null : 4,
          overflow:
              _isSynopsisExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
        if (movie.sinopsis.isNotEmpty)
          GestureDetector(
            onTap:
                () =>
                    setState(() => _isSynopsisExpanded = !_isSynopsisExpanded),
            child: Text(
              _isSynopsisExpanded ? 'Lebih Sedikit' : 'Baca Selengkapnya',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: Colors.blue[50],
    );
  }

  Widget _buildSectionDivider() => const Divider(thickness: 1.5, height: 32);

  Widget _buildListSection<T>(
    String title,
    List<T> items,
    String Function(T) nameBuilder,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _sectionTitleStyle(context)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              items.map((item) {
                final name = nameBuilder(item);
                return Chip(
                  label: Text(name, overflow: TextOverflow.ellipsis),
                  backgroundColor: Colors.grey[200],
                );
              }).toList(),
        ),
      ],
    );
  }


  Widget _buildStaffSection(List<Staff> staffs) {
    if (staffs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Staff Produksi', style: _sectionTitleStyle(context)),
        const SizedBox(height: 8),
        ...staffs.map((staff) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: (staff.profileUrl.isNotEmpty == true)
                      ? CachedNetworkImageProvider(staff.profileUrl)
                      : null,
              child: (staff.profileUrl.isEmpty)
                      ? const Icon(Icons.person)
                      : null,
            ),
            title: Text(staff.name),
            subtitle: Text(staff.role),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StaffDetailScreen(staffId: staff.id),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildSeiyuSection(List<Seiyu> seiyus, List<Karakter> karakters) {
    if (seiyus.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pengisi Suara', style: _sectionTitleStyle(context)),
        const SizedBox(height: 8),
        ...seiyus.map((seiyu) {
          final karakterRelasi = karakters.where((k) => k.id == seiyu.seiyuMovie.karakterId).toList();

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: (seiyu.profileUrl.isNotEmpty)
                  ? CachedNetworkImageProvider(seiyu.profileUrl)
                  : null,
              child: (seiyu.profileUrl.isEmpty) ? const Icon(Icons.person) : null,
            ),
            title: Text(seiyu.name),
            subtitle:
                karakterRelasi.isNotEmpty
                    ? Text('Karakter: ${karakterRelasi.first.nama}')
                    : const Text('Karakter tidak diketahui'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeiyuDetailScreen(seiyuId: seiyu.id),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildCharacterSection(List<Karakter> karakters) {
    if (karakters.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Karakter', style: _sectionTitleStyle(context)),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: karakters.length,
          itemBuilder: (context, index) {
            final karakter = karakters[index];
            return GestureDetector(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              CharacterDetailScreen(characterId: karakter.id),
                    ),
                  ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: karakter.profileUrl,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) =>
                                Container(color: Colors.grey[200]),
                        errorWidget:
                            (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    karakter.nama,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  TextStyle _sectionTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ) ??
        const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        );
  }
}
