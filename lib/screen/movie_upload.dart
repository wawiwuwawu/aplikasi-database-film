
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../service/movie_service.dart';
import '../model/movie_model.dart';

class MovieUploadPage extends StatefulWidget {
  const MovieUploadPage({super.key});

  @override
  _MovieUploadPageState createState() => _MovieUploadPageState();
}

class _MovieUploadPageState extends State<MovieUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final MovieApiService _apiService = MovieApiService();
  final ImagePicker _picker = ImagePicker();
  
  late Movie _movie;
  final Map<String, dynamic> _formData = {};  // store form inputs
  File? _coverImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _movie = Movie(
      id: 0,
      judul: '',
      sinopsis: '',
      tahunRilis: 0,
      thema: '',
      genre: '',
      studio: '',
      type: '',
      episode: 0,
      durasi: 0,
      rating: '',
      coverUrl: '',
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _coverImage = File(pickedFile.path));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_coverImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cover wajib dipilih')),
      );
      return;
    }

    _formKey.currentState!.save();  // populate _formData via onSaved

    // create new Movie immutable instance
    final movieToUpload = _movie.copyWith(
      judul: _formData['judul'] as String,
      sinopsis: _formData['sinopsis'] as String,
      tahunRilis: _formData['tahunRilis'] as int,
      thema: _formData['thema'] as String,
      genre: _formData['genre'] as String,
      studio: _formData['studio'] as String,
      type: _formData['type'] as String,
      episode: _formData['episode'] as int,
      durasi: _formData['durasi'] as int,
      rating: _formData['rating'] as String,
    );

    setState(() => _isLoading = true);
    try {
      await _apiService.uploadMovie(
        movie: movieToUpload,
        coverImage: _coverImage!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil diupload!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildFormField({
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Anime Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildFormField(
                label: 'Judul',
                validator: (v) => (v?.isEmpty ?? true) ? 'Harus diisi' : null,
                onSaved: (v) => _formData['judul'] = v!.trim(),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Sinopsis',
                maxLines: 5,
                validator: (v) => (v?.isEmpty ?? true) ? 'Harus diisi' : null,
                onSaved: (v) => _formData['sinopsis'] = v!.trim(),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Tahun Rilis',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Harus diisi';
                  if (int.tryParse(v!) == null) return 'Harus berupa angka';
                  return null;
                },
                onSaved: (v) => _formData['tahunRilis'] = int.parse(v!),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Thema',
                validator: (v) => (v?.isEmpty ?? true) ? 'Harus diisi' : null,
                onSaved: (v) => _formData['thema'] = v!.trim(),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Genre',
                validator: (v) => (v?.isEmpty ?? true) ? 'Harus diisi' : null,
                onSaved: (v) => _formData['genre'] = v!.trim(),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Studio',
                validator: (v) => (v?.isEmpty ?? true) ? 'Harus diisi' : null,
                onSaved: (v) => _formData['studio'] = v!.trim(),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Type',
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Harus diisi';
                  const validTypes = ['TV', 'Movie', 'ONA', 'OVA'];
                  if (!validTypes.contains(v)) return 'Type tidak valid';
                  return null;
                },
                onSaved: (v) => _formData['type'] = v!,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Episode',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Harus diisi';
                  if (int.tryParse(v!) == null || int.parse(v) < 1) return 'Episode tidak valid';
                  return null;
                },
                onSaved: (v) => _formData['episode'] = int.parse(v!),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Durasi',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Harus diisi';
                  if (int.tryParse(v!) == null || int.parse(v) < 1) return 'Durasi tidak valid';
                  return null;
                },
                onSaved: (v) => _formData['durasi'] = int.parse(v!),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Rating',
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Harus diisi';
                  const validRatings = ['G', 'PG', 'PG-13', 'R'];
                  if (!validRatings.contains(v)) return 'Rating tidak valid';
                  return null;
                },
                onSaved: (v) => _formData['rating'] = v!,
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _coverImage == null
                      ? const Center(child: Text('Pilih Cover'))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_coverImage!, fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.upload),
                label: Text(_isLoading ? 'Mengupload...' : 'Upload'),
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
