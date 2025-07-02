import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:numberpicker/numberpicker.dart';
import 'package:weebase/service/karakter_service.dart';
import 'package:weebase/model/karakter_model.dart' as karakter_model;
import 'package:weebase/service/seiyu_service.dart';
import 'package:weebase/model/seiyu_model.dart' as seiyu_model;
import 'package:weebase/service/staff_service.dart';
import 'package:weebase/model/staff_model.dart' as staff_model;
import 'package:weebase/model/movie_model.dart' as movie_model;
import 'package:weebase/service/movie_service.dart';
import 'package:weebase/model/movie_model.dart';

class MovieFormPage extends StatefulWidget {
  final Movie? movie;
  const MovieFormPage({Key? key, this.movie}) : super(key: key);

  @override
  _MovieFormPageState createState() => _MovieFormPageState();
}


class _MovieFormPageState extends State<MovieFormPage>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // GlobalKey untuk setiap field wajib
  final _judulFieldKey = GlobalKey();
  final _sinopsisFieldKey = GlobalKey();
  final _typeFieldKey = GlobalKey();
  final _ratingFieldKey = GlobalKey();
  final _coverFieldKey = GlobalKey();

  final _judulController = TextEditingController();
  final _sinopsisController = TextEditingController();
  final _typeController = TextEditingController();
  final _ratingController = TextEditingController();

  // Tambahkan FocusNode untuk sinopsis
  final FocusNode _sinopsisFocusNode = FocusNode();

  final _apiServiceKarakter = KarakterService();
  final _apiServiceSeiyu = SeiyuApiService();
  final _apiServiceStaff = StaffService();
  final MovieApiService _movieApiService = MovieApiService();

  final _searchKarakterController = TextEditingController();
  final List<karakter_model.Karakter> _searchKarakterResults = [];
  bool _isSearchingKarakter = false;
  Timer? _debounceKarakter;

  final _searchSeiyuController = TextEditingController();
  final List<seiyu_model.Seiyu> _searchSeiyuResults = [];
  bool _isSearchingSeiyu = false;
  Timer? _debounceSeiyu;

  final _searchStaffController = TextEditingController();
  final List<staff_model.Staff> _searchStaffResults = [];
  bool _isSearchingStaff = false;
  Timer? _debounceStaff;

  final _searchMovieController = TextEditingController();
  final List<movie_model.Movie> _searchMovieResults = [];
  bool _isSearchingMovie = false;
  movie_model.Movie? _selectedMovie;

  Timer? _debounceMovie;

  int _selectedYear = DateTime.now().year;
  int _selectedDuration = 20;
  int _selectedEpisode = 12;

  List<movie_model.Genre> _allGenres = [];
  List<movie_model.Genre> _selectedGenres = [];
  List<movie_model.ThemeMovie> _allThemes = [];
  List<movie_model.ThemeMovie> _selectedThemes = [];
  List<StaffForm> _staffs = [];
  List<SeiyuKarakterPairForm> _seiyuKarakterPairs = [];

  File? _coverImageFile;
  String? _coverImageUrl;
  final _picker = ImagePicker();
  bool _isLoading = false;
  String? _errorMessage;
  bool _keyboardVisible = false;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _allGenres = [
      movie_model.Genre(id: 1, nama: 'Action'),
      movie_model.Genre(id: 2, nama: 'Adventure'),
      movie_model.Genre(id: 3, nama: 'Avant Garde'),
      movie_model.Genre(id: 4, nama: 'Award Winning'),
      movie_model.Genre(id: 5, nama: 'Boys Love'),
      movie_model.Genre(id: 6, nama: 'Comedy'),
      movie_model.Genre(id: 7, nama: 'Drama'),
      movie_model.Genre(id: 8, nama: 'Fantasy'),
      movie_model.Genre(id: 9, nama: 'Girls Love'),
      movie_model.Genre(id: 10, nama: 'Gourmet'),
      movie_model.Genre(id: 11, nama: 'Horror'),
      movie_model.Genre(id: 12, nama: 'Mystery'),
      movie_model.Genre(id: 13, nama: 'Romance'),
      movie_model.Genre(id: 14, nama: 'Sci-Fi'),
      movie_model.Genre(id: 15, nama: 'Slice of Life'),
      movie_model.Genre(id: 16, nama: 'Sports'),
      movie_model.Genre(id: 17, nama: 'Supernatural'),
      movie_model.Genre(id: 18, nama: 'Suspense'),
      movie_model.Genre(id: 19, nama: 'Echi'),
    ];
    _allThemes = [
      movie_model.ThemeMovie(id: 1, nama: 'Adult Cast'),
      movie_model.ThemeMovie(id: 2, nama: 'Anthropomorphic'),
      movie_model.ThemeMovie(id: 3, nama: 'CGDCT'),
      movie_model.ThemeMovie(id: 4, nama: 'Childcare'),
      movie_model.ThemeMovie(id: 5, nama: 'Combat Sports'),
      movie_model.ThemeMovie(id: 6, nama: 'Crossdressing'),
      movie_model.ThemeMovie(id: 7, nama: 'Delinquents'),
      movie_model.ThemeMovie(id: 8, nama: 'Detective'),
      movie_model.ThemeMovie(id: 9, nama: 'Educational'),
      movie_model.ThemeMovie(id: 10, nama: 'Gag Humor'),
      movie_model.ThemeMovie(id: 11, nama: 'Gore'),
      movie_model.ThemeMovie(id: 12, nama: 'Harem'),
      movie_model.ThemeMovie(id: 13, nama: 'High Stakes Game'),
      movie_model.ThemeMovie(id: 14, nama: 'Historical'),
      movie_model.ThemeMovie(id: 15, nama: 'Idols (Female)'),
      movie_model.ThemeMovie(id: 16, nama: 'Idols (Male)'),
      movie_model.ThemeMovie(id: 17, nama: 'Isekai'),
      movie_model.ThemeMovie(id: 18, nama: 'Iyashikei'),
      movie_model.ThemeMovie(id: 19, nama: 'Love Polygon'),
      movie_model.ThemeMovie(id: 20, nama: 'Love Status Quo'),
      movie_model.ThemeMovie(id: 21, nama: 'Magical Sex Shift'),
      movie_model.ThemeMovie(id: 22, nama: 'Mahou Shoujo'),
      movie_model.ThemeMovie(id: 23, nama: 'Martial Arts'),
      movie_model.ThemeMovie(id: 24, nama: 'Mecha'),
      movie_model.ThemeMovie(id: 25, nama: 'Medical'),
      movie_model.ThemeMovie(id: 26, nama: 'Military'),
      movie_model.ThemeMovie(id: 27, nama: 'Music'),
      movie_model.ThemeMovie(id: 28, nama: 'Mythology'),
      movie_model.ThemeMovie(id: 29, nama: 'Organized Crime'),
      movie_model.ThemeMovie(id: 30, nama: 'Otaku Culture'),
      movie_model.ThemeMovie(id: 31, nama: 'Parody'),
      movie_model.ThemeMovie(id: 32, nama: 'Performing Arts'),
      movie_model.ThemeMovie(id: 33, nama: 'Pets'),
      movie_model.ThemeMovie(id: 34, nama: 'Psychological'),
      movie_model.ThemeMovie(id: 35, nama: 'Racing'),
      movie_model.ThemeMovie(id: 36, nama: 'Reincarnation'),
      movie_model.ThemeMovie(id: 37, nama: 'Reverse Harem'),
      movie_model.ThemeMovie(id: 38, nama: 'Samurai'),
      movie_model.ThemeMovie(id: 39, nama: 'School'),
      movie_model.ThemeMovie(id: 40, nama: 'Showbiz'),
      movie_model.ThemeMovie(id: 41, nama: 'Space'),
      movie_model.ThemeMovie(id: 42, nama: 'Strategy Game'),
      movie_model.ThemeMovie(id: 43, nama: 'Super Power'),
      movie_model.ThemeMovie(id: 44, nama: 'Survival'),
      movie_model.ThemeMovie(id: 45, nama: 'Team Sports'),
      movie_model.ThemeMovie(id: 46, nama: 'Time Travel'),
      movie_model.ThemeMovie(id: 47, nama: 'Urban Fantasy'),
      movie_model.ThemeMovie(id: 48, nama: 'Vampire'),
      movie_model.ThemeMovie(id: 49, nama: 'Video Game'),
      movie_model.ThemeMovie(id: 50, nama: 'Villainess'),
      movie_model.ThemeMovie(id: 51, nama: 'Visual Arts'),
      movie_model.ThemeMovie(id: 52, nama: 'Workplace'),
    ];

    if (widget.movie != null) {
      // Panggil fungsi yang mengisi semua controller dan state
      _selectMovie(widget.movie!);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _judulController.dispose();
    _sinopsisController.dispose();
    _typeController.dispose();
    _ratingController.dispose();
    _searchMovieController.dispose();
    _debounceMovie?.cancel();
    _searchKarakterController.dispose();
    _debounceKarakter?.cancel();
    _searchSeiyuController.dispose();
    _debounceSeiyu?.cancel();
    _searchStaffController.dispose();
    _debounceStaff?.cancel();
    // Dispose FocusNode sinopsis
    _sinopsisFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newKeyboardVisible = bottomInset > 0.0;
    // Hapus/uncomment logic unfocus otomatis agar keyboard tidak menutup sendiri
    // if (_keyboardVisible && !newKeyboardVisible) {
    //   FocusScopeNode currentFocus = FocusScope.of(context);
    //   if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    //     currentFocus.unfocus();
    //   }
    // }
    _keyboardVisible = newKeyboardVisible;
    super.didChangeMetrics();
  }

  Widget _buildIdField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'ID Movie: ${_selectedMovie != null ? _selectedMovie!.id.toString() : 'ID belum tersedia'}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        FocusScope.of(context).unfocus();
        await Future.delayed(const Duration(milliseconds: 50));
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kelola Movie'),
          actions: [
            if (_selectedMovie != null)
              TextButton(
                onPressed: _resetMovieForm,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Batal Edit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedMovie != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.edit, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'Mode Edit Movie',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[800]),
                      ),
                    ),
                  if (_errorMessage != null) const SizedBox(height: 16),
                  // _buildSearchMovieField(),
                  if (_selectedMovie != null) _buildIdField(),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _judulController,
                    'Judul',
                    'Masukkan judul',
                    key: _judulFieldKey,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _sinopsisController,
                    'Sinopsis',
                    'Masukkan sinopsis',
                    maxLines: 3,
                    key: _sinopsisFieldKey,
                  ),
                  const SizedBox(height: 12),
                  _buildYearPicker(),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    controller: _typeController,
                    label: 'Type',
                    items: const ['TV', 'Movie', 'ONA', 'OVA'],
                    key: _typeFieldKey,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberPicker(
                          'Episode',
                          _selectedEpisode,
                          _pickEpisode,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildNumberPicker(
                          'Durasi',
                          _selectedDuration,
                          _pickDuration,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    controller: _ratingController,
                    label: 'Rating',
                    items: const ['G', 'PG', 'PG-13', 'R', 'NC-17'],
                    key: _ratingFieldKey,
                  ),
                  const SizedBox(height: 16),
                  _buildGenreCheckboxList(),
                  const SizedBox(height: 16),
                  _buildThemeCheckboxList(),
                  const SizedBox(height: 16),
                  _buildDynamiStaffList(
                    'Staffs',
                    _staffs,
                    () => StaffForm(),
                    addButtonLabel: 'Tambah Staff',
                  ),
                  const SizedBox(height: 16),
                  _buildSeiyuAndCharacterSection(),
                  const SizedBox(height: 16),
                  _buildCoverPicker(key: _coverFieldKey),
                  const SizedBox(height: 20),
                  if (_selectedMovie == null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Icon(Icons.upload),
                        label: Text(_isLoading ? 'Proses...' : 'Submit'),
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                      ),
                    ),
                  if (_selectedMovie != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Icon(Icons.update),
                        label: Text(_isLoading ? 'Proses...' : 'Update Movie'),
                        onPressed: _isLoading ? null : _updateMovie,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Hapus Movie'),
                        onPressed: _isLoading ? null : _showDeleteMovieDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size.fromHeight(50),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildSearchMovieField() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         children: [
  //           Expanded(
  //             child: TextFormField(
  //               controller: _searchMovieController,
  //               decoration: InputDecoration(
  //                 labelText: 'Cari Movie (untuk edit)',
  //                 border: const OutlineInputBorder(),
  //                 prefixIcon: const Icon(Icons.search),
  //                 suffixIcon:
  //                     _searchMovieController.text.isNotEmpty
  //                         ? IconButton(
  //                           icon: const Icon(Icons.clear),
  //                           onPressed: () {
  //                             setState(() {
  //                               _searchMovieController.clear();
  //                               _searchMovieResults.clear();
  //                               _errorMessage = null;
  //                             });
  //                           },
  //                         )
  //                         : null,
  //               ),
  //               onChanged: (value) {
  //                 if (_debounceMovie?.isActive ?? false)
  //                   _debounceMovie!.cancel();
  //                 setState(() {}); // Untuk update suffixIcon
  //                 if (value.isEmpty) {
  //                   setState(() {
  //                     _searchMovieResults.clear();
  //                     _errorMessage = null;
  //                   });
  //                   return;
  //                 }
  //                 _debounceMovie = Timer(
  //                   const Duration(milliseconds: 1000),
  //                   () {
  //                     if (value.isNotEmpty) {
  //                       _searchMovie();
  //                     }
  //                   },
  //                 );
  //               },
  //             ),
  //           ),
  //           const SizedBox(width: 8),
  //           ElevatedButton(
  //             onPressed:
  //                 _isSearchingMovie
  //                     ? null
  //                     : () {
  //                       _searchMovie();
  //                       FocusScope.of(context).unfocus();
  //                     },
  //             child:
  //                 _isSearchingMovie
  //                     ? const SizedBox(
  //                       width: 20,
  //                       height: 20,
  //                       child: CircularProgressIndicator(
  //                         strokeWidth: 2,
  //                         color: Colors.white,
  //                       ),
  //                     )
  //                     : const Text('Cari'),
  //           ),
  //         ],
  //       ),
  //       _buildSearchMovieResults(),
  //     ],
  //   );
  // }

  Widget _buildSearchMovieResults() {
    // Tampilkan snackbar error hanya jika pencarian sudah selesai dan user tidak sedang mengetik
    if (_searchMovieController.text.isNotEmpty &&
        !_isSearchingMovie &&
        _searchMovieResults.isEmpty &&
        (_debounceMovie == null || !_debounceMovie!.isActive)) {
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   if (mounted) {
      //     ScaffoldMessenger.of(context).removeCurrentSnackBar();
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(
      //         content: Text('Movie tidak tersedia'),
      //         backgroundColor: Colors.red,
      //         duration: Duration(seconds: 2),
      //         behavior: SnackBarBehavior.floating,
      //         margin: EdgeInsets.only(bottom: 80, left: 16, right: 16),
      //       ),
      //     );
      //   }
      // });
    }
    if (_searchMovieResults.isEmpty) return const SizedBox();
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        itemCount: _searchMovieResults.length,
        itemBuilder: (context, index) {
          final movie = _searchMovieResults[index];
          return ListTile(
            leading:
                movie.coverUrl.isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        movie.coverUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.error, size: 50),
                      ),
                    )
                    : const Icon(Icons.movie, size: 50),
            title: Text(movie.judul),
            onTap: () async {
              setState(() {
                _isLoading = true;
              });
              try {
                final detailMovie = await _movieApiService.getMovieDetail(
                  movie.id,
                );
                _selectMovie(detailMovie);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal mengambil detail movie: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted)
                  setState(() {
                    _isLoading = false;
                  });
              }
            },
          );
        },
      ),
    );
  }

  Future<void> _searchMovie() async {
    if (_searchMovieController.text.isEmpty) {
      setState(() => _isSearchingMovie = false);
      return;
    }
    setState(() {
      _isSearchingMovie = true;
      _searchMovieResults.clear();
    });
    try {
      final results = await _movieApiService.searchMovies(
        _searchMovieController.text,
      );
      setState(() {
        _searchMovieResults.addAll(results);
      });
    } catch (e) {
      // Optional: tampilkan error
    } finally {
      setState(() => _isSearchingMovie = false);
    }
  }

  void _selectMovie(movie_model.Movie movie) {
    setState(() {
      _selectedMovie = movie;
      _judulController.text = movie.judul;
      _sinopsisController.text = movie.sinopsis;
      _typeController.text = movie.type;
      _ratingController.text = movie.rating;
      _selectedYear = movie.tahunRilis;
      _selectedDuration = movie.durasi;
      _selectedEpisode = movie.episode;
      _selectedGenres = List<movie_model.Genre>.from(movie.genres);
      _selectedThemes = List<movie_model.ThemeMovie>.from(movie.themes);
      _staffs = [];
      for (final staff in movie.staffs) {
        final staffForm = StaffForm();
        staffForm.selectedStaff = staff_model.Staff(
          id: staff.id,
          name: staff.name,
          role: staff.role,
          profileUrl: staff.profileUrl,
          bio: '',
        );
        _staffs.add(staffForm);
      }
      _seiyuKarakterPairs = [];
      for (int i = 0; i < movie.seiyus.length && i < movie.karakters.length; i++) {
        final seiyu = movie.seiyus[i];
        final karakter = movie.karakters[i];
        _seiyuKarakterPairs.add(
          SeiyuKarakterPairForm(
            seiyu: seiyu_model.Seiyu(
              id: seiyu.id,
              name: seiyu.name,
              profileUrl: seiyu.profileUrl,
            ),
            karakter: karakter_model.Karakter(
              id: karakter.id,
              nama: karakter.nama,
              profileUrl: karakter.profileUrl,
            ),
          ),
        );
      }
      // Deteksi cover dari URL atau file
      if (movie.coverUrl.isNotEmpty && (movie.coverUrl.startsWith('http') || movie.coverUrl.startsWith('https'))) {
        _coverImageFile = null;
        _coverImageUrl = movie.coverUrl;
      } else if (movie.coverUrl.isNotEmpty) {
        _coverImageFile = File(movie.coverUrl);
        _coverImageUrl = null;
      } else {
        _coverImageFile = null;
        _coverImageUrl = null;
      }
      _searchMovieController.clear();
      _searchMovieResults.clear();
    });
  }

  void _resetMovieForm() {
    setState(() {
      _formKey.currentState?.reset();
      _judulController.clear();
      _sinopsisController.clear();
      _typeController.clear();
      _ratingController.clear();
      _selectedYear = DateTime.now().year;
      _selectedDuration = 20;
      _selectedEpisode = 12;
      _selectedGenres.clear();
      _selectedThemes.clear();
      _staffs.clear();
      _seiyuKarakterPairs.clear();
      _coverImageFile = null;
      _coverImageUrl = null;
      _selectedMovie = null;
      _errorMessage = null;
    });
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String error, {
    int maxLines = 1,
    Key? key,
  }) {
    // Pasang FocusNode khusus untuk sinopsis
    return TextFormField(
      key: key,
      controller: controller,
      focusNode: label == 'Sinopsis' ? _sinopsisFocusNode : null,
      decoration: InputDecoration(labelText: label),
      maxLines: maxLines,
      validator: (v) => v!.isEmpty ? error : null,
    );
  }

  Widget _buildYearPicker() {
    return InkWell(
      onTap: _pickYear,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Tahun Rilis',
          border: OutlineInputBorder(),
        ),
        child: Text('$_selectedYear'),
      ),
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    required List<String> items,
    Key? key,
  }) {
    return DropdownButtonFormField<String>(
      key: key,
      value: controller.text.isEmpty ? null : controller.text,
      decoration: InputDecoration(labelText: label),
      items:
          items
              .map(
                (value) => DropdownMenuItem(value: value, child: Text(value)),
              )
              .toList(),
      onChanged: (value) => setState(() => controller.text = value ?? ''),
      validator:
          (value) => value == null || value.isEmpty ? 'Pilih $label' : null,
    );
  }

  Widget _buildNumberPicker(
    String label,
    int value,
    Future<void> Function() onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        child: Text('$value'),
      ),
    );
  }

  Widget _buildDynamiStaffList<T>(
    String label,
    List<T> items,
    T Function() createItem, {
    bool showAddButton = true,
    String? addButtonLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        ...items.map(
          (item) => (item as dynamic).build(
            context,
            onRemove: () => setState(() => items.remove(item)),
          ),
        ),
        if (showAddButton)
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _searchStaffController.clear();
                _searchStaffResults.clear();
                _isSearchingStaff = false;
              });
              showDialog(
                context: context,
                builder:
                    (context) => SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: _buildStaffSearchDialog(),
                    ),
              ).then((selectedStaff) {
                if (selectedStaff != null &&
                    selectedStaff is staff_model.Staff) {
                  setState(() {
                    final staffForm = StaffForm();
                    staffForm.selectedStaff = selectedStaff;
                    _staffs.add(staffForm);
                    // Clear search after selection
                    _searchStaffController.clear();
                    _searchStaffResults.clear();
                  });
                }
                // Hapus unfocus di sini agar tidak scroll ke atas setelah dialog ditutup
                // FocusScope.of(context).unfocus();
              });
            },
            icon: const Icon(Icons.add),
            label: Text(addButtonLabel ?? 'Tambah $label'),
          ),
      ],
    );
  }

  Widget _buildGenreCheckboxList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Genres',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _allGenres.map((genre) {
                final isSelected = _selectedGenres.any((g) => g.id == genre.id);
                return FilterChip(
                  label: Text(genre.nama),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (!_selectedGenres.any((g) => g.id == genre.id)) {
                          _selectedGenres.add(genre);
                        }
                      } else {
                        _selectedGenres.removeWhere((g) => g.id == genre.id);
                      }
                    });
                  },
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildThemeCheckboxList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Themes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _allThemes.map((theme) {
                final isSelected = _selectedThemes.any((t) => t.id == theme.id);
                return FilterChip(
                  label: Text(theme.nama),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (!_selectedThemes.any((t) => t.id == theme.id)) {
                          _selectedThemes.add(theme);
                        }
                      } else {
                        _selectedThemes.removeWhere((t) => t.id == theme.id);
                      }
                    });
                  },
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildCoverPicker({Key? key}) {
    return InkWell(
      key: key,
      onTap: _pickCover,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _coverImageFile == null && (_coverImageUrl == null || _coverImageUrl!.isEmpty)
            ? const Center(child: Text('Pilih Cover'))
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _coverImageFile != null
                    ? Image.file(
                        _coverImageFile!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Icon(Icons.broken_image, size: 80)),
                      )
                    : Image.network(
                        _coverImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Icon(Icons.broken_image, size: 80)),
                      ),
              ),
      ),
    );
  }

  Widget _buildSeiyuAndCharacterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seiyu & Karakter (berpasangan)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            ..._seiyuKarakterPairs.asMap().entries.map((entry) {
              final idx = entry.key;
              final pair = entry.value;
              return Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        // Reset search before showing dialog
                        setState(() {
                          _searchSeiyuController.clear();
                          _searchSeiyuResults.clear();
                          _isSearchingSeiyu = false;
                        });

                        final selectedSeiyu = await showDialog<
                          seiyu_model.Seiyu
                        >(
                          context: context,
                          builder:
                              (context) => SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
                                child: _buildSeiyuSearchDialog(
                                  onSelected: (seiyu) {
                                    Navigator.pop(context, seiyu);
                                  },
                                ),
                              ),
                        );
                        if (selectedSeiyu != null) {
                          setState(() {
                            pair.seiyu = selectedSeiyu;
                            // Clear search after selection
                            _searchSeiyuController.clear();
                            _searchSeiyuResults.clear();
                          });
                        }
                        FocusScope.of(context).unfocus();
                      },
                      child: _buildPairCard(
                        label:
                            pair.seiyu != null
                                ? pair.seiyu!.name
                                : 'Pilih Seiyu',
                        imageUrl: pair.seiyu?.profileUrl,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        // Reset search before showing dialog
                        setState(() {
                          _searchKarakterController.clear();
                          _searchKarakterResults.clear();
                          _isSearchingKarakter = false;
                        });

                        final selectedKarakter = await showDialog<
                          karakter_model.Karakter
                        >(
                          context: context,
                          builder:
                              (context) => SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
                                child: _buildKarakterSearchDialog(
                                  onSelected: (karakter) {
                                    Navigator.pop(context, karakter);
                                  },
                                ),
                              ),
                        );
                        if (selectedKarakter != null) {
                          setState(() {
                            pair.karakter = selectedKarakter;
                            // Clear search after selection
                            _searchKarakterController.clear();
                            _searchKarakterResults.clear();
                          });
                        }
                        FocusScope.of(context).unfocus();
                      },
                      child: _buildPairCard(
                        label:
                            pair.karakter != null
                                ? pair.karakter!.nama
                                : 'Pilih Karakter',
                        imageUrl: pair.karakter?.profileUrl,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed:
                        () => setState(() => _seiyuKarakterPairs.removeAt(idx)),
                  ),
                ],
              );
            }).toList(),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _seiyuKarakterPairs.add(SeiyuKarakterPairForm());
                });
                FocusScope.of(context).unfocus();
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Pasangan Seiyu & Karakter'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPairCard({required String label, String? imageUrl}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.error, size: 40),
                ),
              )
            else
              const Icon(Icons.person, size: 40),
            const SizedBox(width: 8),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickYear() async {
    final firstYear = 1900;
    final lastYear = DateTime.now().year + 5;
    await showModalBottomSheet(
      context: context,
      builder:
          (_) => SizedBox(
            height: 300,
            child: YearPicker(
              firstDate: DateTime(firstYear),
              lastDate: DateTime(lastYear),
              initialDate: DateTime(_selectedYear),
              selectedDate: DateTime(_selectedYear),
              onChanged: (date) {
                setState(() => _selectedYear = date.year);
                Navigator.pop(context);
                FocusScope.of(context).unfocus(); // unfocus setelah pilih tahun
              },
            ),
          ),
    );
    FocusScope.of(context).unfocus(); // unfocus setelah pilih tahun
  }

  Future<void> _pickDuration() =>
      _showNumberPicker('Durasi (menit)', _selectedDuration, (value) {
        setState(() => _selectedDuration = value);
        FocusScope.of(context).unfocus(); // unfocus setelah pilih durasi
      });
  Future<void> _pickEpisode() =>
      _showNumberPicker('Episode', _selectedEpisode, (value) {
        setState(() => _selectedEpisode = value);
        FocusScope.of(context).unfocus(); // unfocus setelah pilih episode
      });

  Future<void> _showNumberPicker(
    String title,
    int initialValue,
    ValueChanged<int> onConfirm,
  ) async {
    int temp = initialValue;
    await showModalBottomSheet(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setModalState) => SizedBox(
                  height: 250,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Text(title, style: const TextStyle(fontSize: 16)),
                      Expanded(
                        child: Center(
                          child: FractionallySizedBox(
                            widthFactor: 0.7,
                            child: NumberPicker(
                              value: temp,
                              minValue: 1,
                              maxValue: 500,
                              onChanged: (v) => setModalState(() => temp = v),
                              infiniteLoop: true,
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          onConfirm(temp);
                          Navigator.pop(context);
                          FocusScope.of(
                            context,
                          ).unfocus(); // unfocus setelah pilih durasi/episode
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Future<void> _pickCover() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _coverImageFile = File(image.path);
        _coverImageUrl = null;
      });
    }
  }

  Future<void> _searchKarakter(
    void Function(void Function()) setModalState,
  ) async {
    if (_searchKarakterController.text.isEmpty) {
      return;
    }
    setModalState(() {
      _isSearchingKarakter = true;
      _searchKarakterResults.clear();
    });
    try {
      final results = await _apiServiceKarakter.searchKarakterByName(
        _searchKarakterController.text.trim(),
      );
      setModalState(() {
        _searchKarakterResults.addAll(results);
        _isSearchingKarakter = false;
      });
    } catch (e) {
      setModalState(() {
        _isSearchingKarakter = false;
      });
    }
  }

  Future<void> _searchSeiyu(
    void Function(void Function()) setModalState,
  ) async {
    if (_searchSeiyuController.text.isEmpty) {
      setModalState(() {
        _searchSeiyuResults.clear();
      });
      return;
    }
    setModalState(() {
      _isSearchingSeiyu = true;
      _searchSeiyuResults.clear();
    });
    try {
      final results = await _apiServiceSeiyu.searchSeiyuByName(
        _searchSeiyuController.text.trim(),
      );
      setModalState(() {
        _searchSeiyuResults.addAll(results);
        _isSearchingSeiyu = false;
      });
    } catch (e) {
      setModalState(() {
        _isSearchingSeiyu = false;
      });
    }
  }

  Future<void> _searchStaff(
    void Function(void Function()) setModalState,
  ) async {
    if (_searchStaffController.text.isEmpty) {
      setModalState(() {
        _searchStaffResults.clear();
      });
      return;
    }
    setModalState(() {
      _isSearchingStaff = true;
      _searchStaffResults.clear();
    });
    try {
      final results = await _apiServiceStaff.searchStaffByName(
        _searchStaffController.text.trim(),
      );
      setModalState(() {
        _searchStaffResults.addAll(results);
        _isSearchingStaff = false;
      });
    } catch (e) {
      setModalState(() {
        _isSearchingStaff = false;
      });
    }
  }

  Future<void> _scrollToFirstError() async {
    if (_judulController.text.isEmpty) {
      await _ensureVisible(_judulFieldKey);
      return;
    }
    if (_sinopsisController.text.isEmpty) {
      await _ensureVisible(_sinopsisFieldKey);
      return;
    }
    if (_typeController.text.isEmpty) {
      await _ensureVisible(_typeFieldKey);
      return;
    }
    if (_ratingController.text.isEmpty) {
      await _ensureVisible(_ratingFieldKey);
      return;
    }
    if (_coverImageFile == null && (_coverImageUrl == null || _coverImageUrl!.isEmpty)) {
      await _ensureVisible(_coverFieldKey);
      return;
    }
  }

  Future<void> _ensureVisible(GlobalKey key) async {
    final context = key.currentContext;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _coverImageFile == null) {
      if (_coverImageFile == null) {
        setState(() {
          _errorMessage = 'Pilih cover terlebih dahulu';
        });
      }
      await _scrollToFirstError();
      return;
    }
    try {
      final staffIds =
          _staffs
              .where((f) => f.selectedStaff != null)
              .map((f) => f.selectedStaff!.id)
              .toList();
      final seiyuIds =
          _seiyuKarakterPairs
              .where((pair) => pair.seiyu != null)
              .map((pair) => pair.seiyu!.id)
              .toList();
      final karakterIds =
          _seiyuKarakterPairs
              .where((pair) => pair.karakter != null)
              .map((pair) => pair.karakter!.id)
              .toList();
      final genreIds = _selectedGenres.map((g) => g.id).toList();
      final themeIds = _selectedThemes.map((t) => t.id).toList();

      await _movieApiService.uploadMovie(
        judul: _judulController.text,
        sinopsis: _sinopsisController.text,
        tahunRilis: _selectedYear,
        type: _typeController.text,
        episode: _selectedEpisode,
        durasi: _selectedDuration,
        rating: _ratingController.text,
        genreIds: genreIds,
        themeIds: themeIds,
        staffIds: staffIds,
        seiyuIds: seiyuIds,
        karakterIds: karakterIds,
        coverImage: _coverImageFile!,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Movie berhasil diupload!')));
      _resetMovieForm();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal upload: ${e.toString()}';
      });
    }
  }

  Future<void> _updateMovie() async {
    if (_selectedMovie == null) return;
    if (!_formKey.currentState!.validate()) {
      await _scrollToFirstError();
      return;
    }
    try {
      final staffIds =
          _staffs.where((f) => f.selectedStaff != null).map((f) => f.selectedStaff!.id).toList();
      final seiyuIds =
          _seiyuKarakterPairs.where((pair) => pair.seiyu != null).map((pair) => pair.seiyu!.id).toList();
      final karakterIds =
          _seiyuKarakterPairs.where((pair) => pair.karakter != null).map((pair) => pair.karakter!.id).toList();
      final genreIds = _selectedGenres.map((g) => g.id).toList();
      final themeIds = _selectedThemes.map((t) => t.id).toList();
      await _movieApiService.updateMovie(
        id: _selectedMovie!.id,
        judul: _judulController.text,
        sinopsis: _sinopsisController.text,
        tahunRilis: _selectedYear,
        type: _typeController.text,
        episode: _selectedEpisode,
        durasi: _selectedDuration,
        rating: _ratingController.text,
        genreIds: genreIds,
        themeIds: themeIds,
        staffIds: staffIds,
        seiyuIds: seiyuIds,
        karakterIds: karakterIds,
        coverImage: _coverImageFile, // hanya kirim file jika user pilih gambar baru
      );
      _resetMovieForm();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Update Movie berhasil!')));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal update: ${e.toString()}';
      });
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMovie() async {
    if (_selectedMovie == null) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _movieApiService.deleteMovie(_selectedMovie!.id);
      _resetMovieForm();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Movie berhasil dihapus!')));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal hapus: ${e.toString()}';
      });
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showDeleteMovieDialog() async {
    if (_selectedMovie == null) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus movie "${_selectedMovie!.judul}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
    if (result == true) {
      await _deleteMovie();
    }
  }

  Widget _buildKarakterSearchDialog({
    required Function(karakter_model.Karakter) onSelected,
  }) {
    return Dialog(
      child: WillPopScope(
        onWillPop: () async {
          FocusScope.of(context).unfocus();
          await Future.delayed(const Duration(milliseconds: 50));
          return true;
        },
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Kembali',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Pencarian Karakter',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _searchKarakterController,
                          decoration: InputDecoration(
                            labelText: 'Cari Karakter',
                            border: const OutlineInputBorder(),
                            suffixIcon:
                                _searchKarakterController.text.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setModalState(() {
                                          _searchKarakterController.clear();
                                          _searchKarakterResults.clear();
                                        });
                                      },
                                    )
                                    : null,
                          ),
                          onChanged: (value) {
                            if (_debounceKarakter?.isActive ?? false)
                              _debounceKarakter!.cancel();
                            setModalState(() {}); // Untuk update suffixIcon
                            if (value.isEmpty) {
                              setModalState(() {
                                _searchKarakterResults.clear();
                              });
                              return;
                            }
                            _debounceKarakter = Timer(
                              const Duration(milliseconds: 1000),
                              () {
                                if (value.isNotEmpty) {
                                  _searchKarakter(setModalState);
                                }
                              },
                            );
                          },
                          onFieldSubmitted:
                              (_) => _searchKarakter(setModalState),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed:
                            _isSearchingKarakter
                                ? null
                                : () => _searchKarakter(setModalState),
                        child:
                            _isSearchingKarakter
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                                : const Text('Cari'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child:
                        _isSearchingKarakter
                            ? const Center(child: CircularProgressIndicator())
                            : _searchKarakterController.text.isEmpty
                            ? const SizedBox()
                            : _searchKarakterResults.isEmpty
                            ? const Center(child: Text('data tidak ditemukan'))
                            : ListView.separated(
                              shrinkWrap: true,
                              itemCount: _searchKarakterResults.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final karakter = _searchKarakterResults[index];
                                return ListTile(
                                  leading:
                                      karakter.profileUrl != null &&
                                              karakter.profileUrl!.isNotEmpty
                                          ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              karakter.profileUrl!,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.error,
                                                    size: 50,
                                                  ),
                                            ),
                                          )
                                          : const Icon(Icons.person, size: 50),
                                  title: Text(karakter.nama),
                                  subtitle: Text(
                                    karakter.bio ?? 'Tidak ada bio',
                                  ),
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    // Clear search controller here to ensure UI refreshes properly
                                    setModalState(() {
                                      _searchKarakterController.clear();
                                      _searchKarakterResults.clear();
                                    });
                                    Navigator.pop(context, karakter);
                                  },
                                );
                              },
                            ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSeiyuSearchDialog({
    required Function(seiyu_model.Seiyu) onSelected,
  }) {
    return Dialog(
      child: WillPopScope(
        onWillPop: () async {
          FocusScope.of(context).unfocus();
          await Future.delayed(const Duration(milliseconds: 50));
          return true;
        },
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Kembali',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Pencarian Seiyu',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _searchSeiyuController,
                          decoration: InputDecoration(
                            labelText: 'Cari Seiyu',
                            border: const OutlineInputBorder(),
                            suffixIcon:
                                _searchSeiyuController.text.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setModalState(() {
                                          _searchSeiyuController.clear();
                                          _searchSeiyuResults.clear();
                                        });
                                      },
                                    )
                                    : null,
                          ),
                          onChanged: (value) {
                            if (_debounceSeiyu?.isActive ?? false)
                              _debounceSeiyu!.cancel();
                            setModalState(() {}); // Untuk update suffixIcon
                            if (value.isEmpty) {
                              setModalState(() {
                                _searchSeiyuResults.clear();
                              });
                              return;
                            }
                            _debounceSeiyu = Timer(
                              const Duration(milliseconds: 1000),
                              () {
                                if (value.isNotEmpty) {
                                  _searchSeiyu(setModalState);
                                }
                              },
                            );
                          },
                          onFieldSubmitted: (_) => _searchSeiyu(setModalState),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed:
                            _isSearchingSeiyu
                                ? null
                                : () => _searchSeiyu(setModalState),
                        child:
                            _isSearchingSeiyu
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                                : const Text('Cari'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child:
                        _isSearchingSeiyu
                            ? const Center(child: CircularProgressIndicator())
                            : _searchSeiyuController.text.isEmpty
                            ? const SizedBox()
                            : _searchSeiyuResults.isEmpty
                            ? const Center(child: Text('data tidak ditemukan'))
                            : ListView.separated(
                              shrinkWrap: true,
                              itemCount: _searchSeiyuResults.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final seiyu = _searchSeiyuResults[index];
                                return ListTile(
                                  leading:
                                      seiyu.profileUrl != null &&
                                              seiyu.profileUrl!.isNotEmpty
                                          ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              seiyu.profileUrl!,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.error,
                                                    size: 50,
                                                  ),
                                            ),
                                          )
                                          : const Icon(Icons.person, size: 50),
                                  title: Text(seiyu.name),
                                  subtitle: Text(seiyu.bio ?? 'Tidak ada bio'),
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    // Clear search controller here to ensure UI refreshes properly
                                    setModalState(() {
                                      _searchSeiyuController.clear();
                                      _searchSeiyuResults.clear();
                                    });
                                    Navigator.pop(context, seiyu);
                                  },
                                );
                              },
                            ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStaffSearchDialog() {
    return Dialog(
      child: WillPopScope(
        onWillPop: () async {
          FocusScope.of(context).unfocus();
          await Future.delayed(const Duration(milliseconds: 50));
          return true;
        },
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Kembali',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Pencarian Staff',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _searchStaffController,
                          decoration: InputDecoration(
                            labelText: 'Cari Staff',
                            border: const OutlineInputBorder(),
                            suffixIcon:
                                _searchStaffController.text.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setModalState(() {
                                          _searchStaffController.clear();
                                          _searchStaffResults.clear();
                                        });
                                      },
                                    )
                                    : null,
                          ),
                          onChanged: (value) {
                            if (_debounceStaff?.isActive ?? false)
                              _debounceStaff!.cancel();
                            setModalState(() {}); // Untuk update suffixIcon
                            if (value.isEmpty) {
                              setModalState(() {
                                _searchStaffResults.clear();
                              });
                              return;
                            }
                            _debounceStaff = Timer(
                              const Duration(milliseconds: 1000),
                              () {
                                if (value.isNotEmpty) {
                                  _searchStaff(setModalState);
                                }
                              },
                            );
                          },
                          onFieldSubmitted: (_) => _searchStaff(setModalState),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed:
                            _isSearchingStaff
                                ? null
                                : () => _searchStaff(setModalState),
                        child:
                            _isSearchingStaff
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text('Cari'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _buildStaffSearchResults(setModalState)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStaffSearchResults(
    void Function(void Function()) setModalState,
  ) {
    if (_isSearchingStaff) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_searchStaffController.text.isEmpty) {
      return const SizedBox();
    }
    if (_searchStaffResults.isEmpty) {
      return const Center(child: Text('data tidak ditemukan'));
    }
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _searchStaffResults.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final staff = _searchStaffResults[index];
        return ListTile(
          leading:
              staff.profileUrl != null && staff.profileUrl!.isNotEmpty
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      staff.profileUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Icon(Icons.error, size: 50),
                    ),
                  )
                  : const Icon(Icons.person, size: 50),
          title: Text(staff.name),
          subtitle: Text(staff.bio ?? 'Tidak ada bio'),
          onTap: () {
            FocusScope.of(context).unfocus();
            // Clear search controller here to ensure UI refreshes properly
            setModalState(() {
              _searchStaffController.clear();
              _searchStaffResults.clear();
            });
            Navigator.pop(context, staff);
          },
        );
      },
    );
  }
}

// --- Form Classes ---

class StaffForm {
  staff_model.Staff? selectedStaff;
  Widget build(BuildContext context, {required VoidCallback onRemove}) {
    return _buildCard(
      children: [
        Row(
          children: [
            if (selectedStaff?.profileUrl != null &&
                (selectedStaff?.profileUrl?.isNotEmpty ?? false))
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  selectedStaff!.profileUrl!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.error, size: 40),
                ),
              )
            else
              const Icon(Icons.person, size: 40),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(selectedStaff?.name ?? 'Nama Staff'),
                  Text(selectedStaff?.role ?? 'Role Staff'),
                ],
              ),
            ),
            _buildRemoveButton(onRemove),
          ],
        ),
      ],
    );
  }
}

class SeiyuKarakterPairForm {
  seiyu_model.Seiyu? seiyu;
  karakter_model.Karakter? karakter;
  SeiyuKarakterPairForm({this.seiyu, this.karakter});
}

// --- Util Widgets ---

Widget _buildCard({required List<Widget> children}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 4),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Column(children: children),
    ),
  );
}

Widget _buildRemoveButton(VoidCallback onRemove) {
  return Align(
    alignment: Alignment.centerRight,
    child: IconButton(icon: const Icon(Icons.delete), onPressed: onRemove),
  );
}
