import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../model/movie_model.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  const MovieDetailScreen({required this.movie, Key? key}) : super(key: key);

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isSynopsisExpanded = false;

  @override
  void initState() {
    super.initState();
    // Debug: print raw JSON and parsed model
    debugPrint('RAW MOVIE JSON: \${widget.movie.toJson()}');
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.judul),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoverImage(movie.coverUrl),
            const SizedBox(height: 20),
            _buildBasicInfoSection(movie),
            _buildSectionDivider(),
            _buildListSection<Genre>('Genres', movie.genres, (g) => g.nama),
            _buildListSection<ThemeMovie>('Themes', movie.themes, (t) => t.nama),
            _buildSectionDivider(),
            _buildStaffSection(movie.staffs),
            _buildSectionDivider(),
            _buildSeiyuSection(movie.seiyus, movie.karakters),
            _buildSectionDivider(),
            _buildCharacterSection(movie.karakters),
          ],
        ),
      ),
    );
  }

  TextStyle _sectionTitleStyle(BuildContext context) {
    final base = Theme.of(context).textTheme.titleLarge;
    return base?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue[800])
        ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue);
  }

  Widget _buildCoverImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: url,
        height: 275,
        width: 175,
        fit: BoxFit.cover,
        placeholder: (c, u) => Container(
          height: 275,
          color: Colors.grey[175],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (c, u, e) => Container(
          height: 275,
          color: Colors.grey[175],
          child: const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() => Container(
  height: 300,
  decoration: BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(12),
  ),
  child: Center(child: CircularProgressIndicator(color: Colors.blue[800])),
);

Widget _buildErrorWidget() => Container(
  height: 300,
  decoration: BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.error_outline, color: Colors.red[400], size: 40),
      const SizedBox(height: 8),
      Text('Gagal memuat gambar', style: TextStyle(color: Colors.red[400])),
    ],
  ),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              movie.sinopsis.isNotEmpty ? movie.sinopsis : 'Tidak ada sinopsis',
              maxLines: _isSynopsisExpanded ? null : 4,
              overflow: _isSynopsisExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            if (movie.sinopsis.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isSynopsisExpanded = !_isSynopsisExpanded;
                  });
                },
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
        ),
      ],
    );
  }

Widget _buildInfoChip(IconData icon, String label) => AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  child: InkWell(
    onTap: () {},
    borderRadius: BorderRadius.circular(20),
    child: Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: Colors.blue[50],
      visualDensity: VisualDensity.compact,
    ),
  ),
);

  Widget _buildSectionDivider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Divider(thickness: 1.5),
      );

Widget _buildListSection<T>(String title, List<T> items, String Function(T) nameBuilder) {
  if (items.isEmpty) return const SizedBox.shrink();
  return Column(
    children: [
      if (title.isNotEmpty) ...[
        Text(title, style: _sectionTitleStyle(context)),
        const SizedBox(height: 12),
      ],
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((e) {
          final name = nameBuilder(e);
          return Tooltip(
            message: name,
            child: Chip(
              label: Text(
                name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              backgroundColor: Colors.grey[200],
            ),
          );
        }).toList(),
      ),
    ],
  );
}

  Widget _buildStaffSection(List<Staff> staffs) {
    debugPrint('Staffs count: ${staffs.length}');
    if (staffs.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Staff Produksi', style: _sectionTitleStyle(context)),
        const SizedBox(height: 8),
        ...staffs.map((s) => ListTile(
              leading: CircleAvatar(
                backgroundImage: s.profileUrl.isNotEmpty
                    ? CachedNetworkImageProvider(s.profileUrl)
                    : null,
                child: s.profileUrl.isEmpty ? const Icon(Icons.person) : null,
              ),
              title: Text(s.name),
              subtitle: Text(s.role),
              contentPadding: EdgeInsets.zero,
            )),
      ],
    );
  }

  Widget _buildSeiyuSection(List<Seiyu> seiyus, List<Karakter> allChars) {
    debugPrint('Seiyus count: ${seiyus.length}');
    if (seiyus.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pengisi Suara', style: _sectionTitleStyle(context)),
        const SizedBox(height: 8),
        ...seiyus.map((s) {
          final mainChar = allChars.firstWhere(
            (k) => k.id == s.seiyuMovie.karakterId,
            orElse: () => Karakter(id: 0, nama: 'Unknown', profileUrl: ''),
          );
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: s.profileUrl.isNotEmpty
                      ? CachedNetworkImageProvider(s.profileUrl)
                      : null,
                  child: s.profileUrl.isEmpty ? const Icon(Icons.person) : null,
                ),
                title: Text(s.name),
                subtitle: Text('Karakter: ${mainChar.nama}'),
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(height: 1),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCharacterSection(List<Karakter> chars) {
    debugPrint('Karakters count: ${chars.length}');
    if (chars.isEmpty) return const SizedBox.shrink();
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
          itemCount: chars.length,
          itemBuilder: (c, i) {
            final k = chars[i];
            return Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: k.profileUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (c, u) => Container(color: Colors.grey[200]),
                      errorWidget: (c, u, e) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  k.nama,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}