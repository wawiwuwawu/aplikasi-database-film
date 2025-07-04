import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:weebase/model/movie_model.dart';
import 'package:weebase/service/wishlist_service.dart';
import 'package:weebase/service/preferences_service.dart';
import 'package:weebase/service/movie_service.dart';
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
  Movie? _currentMovie;
  bool _isSynopsisExpanded = false;
  bool _serverOffline = false;
  final MovieApiService _movieService = MovieApiService();

  @override
  void initState() {
    super.initState();
    _serverOffline = false;
    _currentMovie = widget.movie;
    _fetchDetail();
  }

  Future<void> _fetchDetail({bool fromRefresh = false}) async {
    // Saat refresh, pastikan state offline direset
    if (fromRefresh) {
      setState(() {
        _serverOffline = false;
      });
    }
    
    try {
      final detailedMovie = await _movieService.getMovieDetail(widget.movie.id);
      if (mounted) {
        setState(() {
          _currentMovie = detailedMovie;
          _serverOffline = false;
        });
      }
    } catch (e, stack) {
      debugPrint('[MovieDetailScreen] Error saat memuat detail movie id=${widget.movie.id}: $e\n$stack');
      if (mounted) {
        setState(() {
          _serverOffline = true;
        });
      }
    }
  }

  Widget _statItem(IconData icon, String label, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 2),
        Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildStatisticBox(Movie movie) {
    final int saved = movie.savedCount;
    final int watching = movie.watchingCount;
    final int finished = movie.finishedCount;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statItem(Icons.bookmark, 'Disimpan', saved, Colors.blue),
              _statItem(Icons.play_circle, 'Ditonton', watching, Colors.orange),
              _statItem(Icons.check_circle, 'Selesai', finished, Colors.green),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Statistik Anime',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final movie = _currentMovie;
    return Scaffold(
      appBar: AppBar(
        title: Text(movie?.judul ?? 'Loading...'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          _serverOffline
              ? RefreshIndicator(
                  onRefresh: () async {
                    await _fetchDetail(fromRefresh: true);
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
              : (movie == null)
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async {
                        await _fetchDetail(fromRefresh: true);
                      },
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCoverImage(movie.coverUrl),
                                const SizedBox(width: 16),
                                Expanded(child: _buildStatisticBox(movie)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const SizedBox(height: 60), // Beri ruang untuk FAB
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
                      ),
                    ),
          if (movie != null && !_serverOffline)
            Positioned(
              right: 16,
              bottom: 88,
              child: Builder(
                builder: (context) {
                  final fabShape = Theme.of(context).floatingActionButtonTheme.shape ?? const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)));
                  final purpleColor = const Color.fromARGB(255, 255, 255, 255);
                  return Material(
                    elevation: 6,
                    shape: fabShape,
                    color: purpleColor,
                    child: Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                        color: purpleColor,
                        shape: fabShape,
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SaveButton(
                        movie: movie,
                        iconSize: 32,
                        initialStatus: null, // Tidak ada userStatus di model Movie
                        onStatusChanged: (newStatus) {
                          // Tambahkan logika update status jika perlu
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
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
        width: 200,
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

class SaveButton extends StatefulWidget {
  final Movie movie;
  final double iconSize;
  final String? initialStatus;
  final void Function(String)? onStatusChanged;
  const SaveButton({required this.movie, this.iconSize = 24, this.initialStatus, this.onStatusChanged, super.key});

  @override
  State<SaveButton> createState() => SaveButtonState();
}

class SaveButtonState extends State<SaveButton> {
  String? _status;
  bool _isLoading = false;
  final List<Map<String, dynamic>> _statusOptions = [
    {'label': 'Disimpan', 'value': 'disimpan', 'icon': Icons.bookmark},
    {'label': 'Ditonton', 'value': 'ditonton', 'icon': Icons.play_circle},
    {'label': 'Sudah Ditonton', 'value': 'sudah ditonton', 'icon': Icons.check_circle},
  ];

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _loadCurrentStatus(); // Hapus agar tidak race condition
  }

  @override
  void didUpdateWidget(covariant SaveButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialStatus != oldWidget.initialStatus) {
      setState(() {
        _status = widget.initialStatus;
      });
    }
  }

  Future<void> _loadCurrentStatus() async {
    try {
      final wishlist = await WishlistService().fetchWishlist();
      final userMovie = wishlist.firstWhere(
        (item) => item['movie_id'] == widget.movie.id,
        orElse: () => <String, dynamic>{},
      );
      if (userMovie.isNotEmpty && userMovie['status'] != null) {
        setState(() {
          _status = userMovie['status'] as String;
        });
      }
    } catch (e) {
      // Ignore error, keep current status
    }
  }

  Future<void> _saveStatus(String value) async {
    final user = PreferencesService.getCredentials();
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda harus login untuk menyimpan status.')),
        );
      }
      return;
    }
    setState(() => _isLoading = true);
    try {
      await WishlistService().saveUserMovieStatus(
        movieId: widget.movie.id,
        status: value,
      );
      if (!mounted) return;
      setState(() {
        _status = value;
      });
      if (widget.onStatusChanged != null) {
        widget.onStatusChanged!(value);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status film: ${_statusLabel(value)}'),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 1200),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan status: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 1800),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (_status) {
      case 'disimpan':
        icon = Icons.bookmark;
        color = Colors.blueAccent;
        break;
      case 'ditonton':
        icon = Icons.play_circle;
        color = Colors.orange;
        break;
      case 'sudah ditonton':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      default:
        icon = Icons.bookmark_border;
        color = Colors.grey;
    }
    return _isLoading
        ? SizedBox(
            width: widget.iconSize,
            height: widget.iconSize,
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
        : PopupMenuButton<String>(
            icon: Icon(icon, color: color, size: widget.iconSize),
            tooltip: 'Setel status film',
            constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            padding: EdgeInsets.zero,
            onSelected: (value) {
              _saveStatus(value);
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
