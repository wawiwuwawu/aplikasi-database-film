import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import '../../service/karakter_service.dart';
import '../../model/karakter_model.dart';

class AddCharacterForm extends StatefulWidget {
  const AddCharacterForm({super.key});

  @override
  _AddCharacterFormState createState() => _AddCharacterFormState();
}

class _AddCharacterFormState extends State<AddCharacterForm> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _namaFieldKey = GlobalKey();
  final _bioFieldKey = GlobalKey();
  final _coverFieldKey = GlobalKey();
  final _namaController = TextEditingController();
  final _bioController = TextEditingController();
  final _searchController = TextEditingController();
  final _picker = ImagePicker();
  final _apiService = KarakterService();

  File? _coverImage;
  bool _isLoading = false;
  String? _errorMessage;
  final List<Karakter> _searchResults = [];
  Karakter? _selectedKarakter;
  Timer? _debounce;

  @override
  void dispose() {
    _namaController.dispose();
    _bioController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _searchKarakter() async {
    if (_searchController.text.isEmpty) {
      setState(() => _errorMessage = 'Masukkan nama karakter untuk mencari');
      return;
    }

    setState(() {
      _isLoading = true;
      _searchResults.clear();
    });

    try {
      final results = await _apiService.searchKarakterByName(_searchController.text);

      if (results.isEmpty) {
        return;
      }

      setState(() {
        _searchResults.addAll(results);
      });
    } catch (e) {
      return;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectKarakter(Karakter karakter) {
    setState(() {
      _selectedKarakter = karakter;
      _namaController.text = karakter.nama;
      _bioController.text = karakter.bio ?? '';
      _coverImage = null;
      _searchResults.clear();
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || (_selectedKarakter == null && _coverImage == null)) {
      if (_selectedKarakter == null && _coverImage == null) {
        setState(() => _errorMessage = 'Cover wajib dipilih untuk karakter baru');
      }
      await _scrollToFirstError();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_selectedKarakter != null) {
        await _apiService.updateKarakter(
          id: _selectedKarakter!.id,
          karakter: Karakter(
            id: _selectedKarakter!.id,
            nama: _namaController.text,
            bio: _bioController.text,
            profileUrl: _selectedKarakter!.profileUrl,
          ),
          coverImage: _coverImage,
        );
      } else {
        await _apiService.uploadKarakter(
          karakter: Karakter(
            id: 0,
            nama: _namaController.text,
            bio: _bioController.text,
            profileUrl: '',
          ),
          coverImage: _coverImage!,
        );
      }

      _resetForm();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_selectedKarakter != null
              ? 'Update berhasil!'
              : 'Upload berhasil!'),
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteKarakter() async {
    if (_selectedKarakter == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _apiService.deleteKarakter(_selectedKarakter!.id);
      _resetForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Karakter berhasil dihapus!')),
      );
    } catch (e) {
      setState(() => _errorMessage = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    if (_selectedKarakter == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus karakter "${_selectedKarakter!.nama}"?'),
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
      await _deleteKarakter();
    }
  }

  void _resetForm() {
    setState(() {
      _formKey.currentState?.reset();
      _namaController.clear();
      _bioController.clear();
      _searchController.clear();
      _coverImage = null;
      _errorMessage = null;
      _isLoading = false;
      _selectedKarakter = null;
    });
  }

  Future<void> _scrollToFirstError() async {
    if (_namaController.text.isEmpty) {
      await _ensureVisible(_namaFieldKey);
      return;
    }
    if (_bioController.text.isEmpty) {
      await _ensureVisible(_bioFieldKey);
      return;
    }
    if (_selectedKarakter == null && _coverImage == null) {
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

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Cari Karakter (untuk edit)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchResults.clear();
                              _errorMessage = null;
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  setState(() {}); // Untuk update suffixIcon
                  if (value.isEmpty) {
                    setState(() {
                      _searchResults.clear();
                      _errorMessage = null;
                    });
                    return;
                  }
                  _debounce = Timer(const Duration(milliseconds: 1000), () {
                    if (value.isNotEmpty) {
                      _searchKarakter();
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _searchKarakter,
              child: _isLoading
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
        _buildSearchResults(),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchController.text.isNotEmpty && !_isLoading && _searchResults.isEmpty && (_debounce == null || !_debounce!.isActive)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Karakter tidak ditemukan'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 80, left: 16, right: 16),
            ),
          );
        }
      });
    }
    if (_searchResults.isEmpty) return const SizedBox();

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final karakter = _searchResults[index];
          return ListTile(
            leading: karakter.profileUrl != null && karakter.profileUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      karakter.profileUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error, size: 50),
                    ),
                  )
                : const Icon(Icons.person, size: 50),
            title: Text(karakter.nama),
            subtitle: Text(karakter.bio ?? 'Tidak ada bio'),
            onTap: () {
              _selectKarakter(karakter);
            },
          );
        },
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    Key? key,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        key: key,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildIdField() {
    if (_selectedKarakter == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'ID Karakter: ${_selectedKarakter!.id}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildImagePicker({Key? key}) {
    return InkWell(
      key: key,
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _coverImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _coverImage!,
                  fit: BoxFit.cover,
                ),
              )
            : const Center(child: Text('Pilih Profile')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Karakter'),
        actions: [
          if (_selectedKarakter != null)
            TextButton(
              onPressed: _resetForm,
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                'Batal Update',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedKarakter != null)
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
                        'Mode Edit Karakter',
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
              _buildSearchField(),
              _buildIdField(),
              _buildFormField(
                label: 'Nama',
                controller: _namaController,
                validator: (v) => (v?.isEmpty ?? true) ? 'Harus diisi' : null,
                key: _namaFieldKey,
              ),
              _buildFormField(
                label: 'Bio',
                controller: _bioController,
                validator: (v) => (v?.isEmpty ?? true) ? 'Harus diisi' : null,
                key: _bioFieldKey,
              ),
              const SizedBox(height: 20),
              _buildImagePicker(key: _coverFieldKey),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Icon(_selectedKarakter != null
                        ? Icons.update
                        : Icons.upload),
                label: Text(_isLoading
                    ? 'Proses...'
                    : _selectedKarakter != null
                        ? 'Update Karakter'
                        : 'Tambah Karakter'),
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              if (_selectedKarakter != null) const SizedBox(height: 20),
              if (_selectedKarakter != null)
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text('Hapus Karakter'),
                  onPressed: _isLoading ? null : _showDeleteConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
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