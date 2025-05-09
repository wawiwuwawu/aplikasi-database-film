import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../service/seiyu_service.dart';
import '../model/seiyu_model.dart';

class AddSeiyuForm extends StatefulWidget {
  const AddSeiyuForm({super.key});

  @override
  _AddSeiyuFormState createState() => _AddSeiyuFormState();
}

class _AddSeiyuFormState extends State<AddSeiyuForm> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = SeiyuApiService();
  final _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();
  final _instagramController = TextEditingController();
  final _twitterController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _searchController = TextEditingController();

  File? _coverImage;
  bool _isLoading = false;
  String? _errorMessage;
  final List<Seiyu> _searchResults = [];
  Seiyu? _selectedSeiyu;

  @override
  void dispose() {
    _nameController.dispose();
    _birthdateController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _youtubeController.dispose();
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

  Future<void> _searchSeiyu() async {
    if (_searchController.text.isEmpty) {
      setState(() => _errorMessage = 'Nama seiyu tidak boleh kosong');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResults.clear();
    });

    try {
      final results = await _apiService.searchSeiyuByName(_searchController.text);

      if (results.isEmpty) {
        setState(() => _errorMessage = 'Seiyu tidak ditemukan');
        return;
      }

      setState(() {
        _searchResults.addAll(results);
      });
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan saat mencari seiyu: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

    void _selectSeiyu(Seiyu seiyu) {
    if (seiyu.id == null || seiyu.name.isEmpty) {
      setState(() => _errorMessage = 'Data seiyu tidak valid');
      return;
    }

    setState(() {
      _selectedSeiyu = seiyu;
      _nameController.text = seiyu.name;
      _birthdateController.text = seiyu.birthday ?? '';
      _bioController.text = seiyu.bio ?? '';
      _coverImage = null;
      _websiteController.text = seiyu.websiteUrl ?? '';
      _instagramController.text = seiyu.instagramUrl ?? '';
      _twitterController.text = seiyu.twitterUrl ?? '';
      _youtubeController.text = seiyu.youtubeUrl ?? '';
      _searchResults.clear();
    });
  }

  Future<void> _deleteSeiyu() async {
    if (_selectedSeiyu == null || _selectedSeiyu!.id == null) {
      setState(() => _errorMessage = 'Seiyu tidak valid untuk dihapus');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _apiService.deleteSeiyu(_selectedSeiyu!.id!);
      _resetForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seiyu berhasil dihapus!')),
      );
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    if (_selectedSeiyu == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus seiyu "${_selectedSeiyu!.name}"?'),
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
      await _deleteSeiyu();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_selectedSeiyu != null) {
        await _apiService.updateSeiyu(
          id: _selectedSeiyu!.id!,
          seiyu: Seiyu(
            id: _selectedSeiyu!.id!,
            name: _nameController.text.trim(),
            birthday: _birthdateController.text.trim(),
            bio: _bioController.text.trim(),
            websiteUrl: _websiteController.text.trim(),
            instagramUrl: _instagramController.text.trim(),
            twitterUrl: _twitterController.text.trim(),
            youtubeUrl: _youtubeController.text.trim(),
            profileUrl: _selectedSeiyu!.profileUrl,
          ),
          coverImage: _coverImage,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seiyu berhasil diperbarui!')),
        );
      } else {
        // Mode Tambah
        if (_coverImage == null) {
          setState(() => _errorMessage = 'Cover wajib dipilih untuk seiyu baru');
          return;
        }

        await _apiService.uploadSeiyu(
          seiyu: Seiyu(
            id: 0,
            name: _nameController.text.trim(),
            birthday: _birthdateController.text.trim(),
            bio: _bioController.text.trim(),
            websiteUrl: _websiteController.text.trim(),
            instagramUrl: _instagramController.text.trim(),
            twitterUrl: _twitterController.text.trim(),
            youtubeUrl: _youtubeController.text.trim(),
            profileUrl: '',
          ),
          coverImage: _coverImage!,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seiyu berhasil ditambahkan!')),
        );
      }

      _resetForm();
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    setState(() {
      _formKey.currentState?.reset();
      _nameController.clear();
      _birthdateController.clear();
      _bioController.clear();
      _websiteController.clear();
      _instagramController.clear();
      _twitterController.clear();
      _youtubeController.clear();
      _coverImage = null;
      _selectedSeiyu = null;
      _searchController.clear();
      _searchResults.clear();
      _errorMessage = null;
      _isLoading = false;
    });
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
                decoration: const InputDecoration(
                  labelText: 'Cari Seiyu (untuk edit)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _searchSeiyu,
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
          final seiyu = _searchResults[index];
          return ListTile(
            leading: seiyu.profileUrl != null && seiyu.profileUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      seiyu.profileUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error, size: 50),
                    ),
                  )
                : const Icon(Icons.person, size: 50),
            title: Text(seiyu.name),
            subtitle: Text(seiyu.bio ?? 'Tidak ada bio'),
            onTap: () {
              _selectSeiyu(seiyu);
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
    bool readOnly = false,
    VoidCallback? onTap,
    VoidCallback? onClear,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onTap != null)
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: onTap,
                ),
              if (onClear != null && controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                ),
            ],
          ),
        ),
        validator: validator,
      ),
    );
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
          'ID Seiyu: ${_selectedSeiyu?.id.toString() ?? 'ID belum tersedia'}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

    Widget _buildImagePicker() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _coverImage == null
            ? const Center(child: Text('Pilih Profile'))
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _coverImage!,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Seiyu'),
        actions: [
          if (_selectedSeiyu != null)
            ElevatedButton(
              onPressed: _resetForm,
              style: ElevatedButton.styleFrom(
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
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                controller: _nameController,
                validator: (v) => (v?.isEmpty ?? true) ? 'Harus diisi' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _birthdateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Ulang Tahun',
                        border: OutlineInputBorder(),
                      ),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _birthdateController.clear();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Hapus', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildFormField(
                label: 'Bio',
                controller: _bioController,
              ),
              _buildFormField(
                label: 'Website',
                controller: _websiteController,
                validator: (v) => _validateOptionalUrl(v, 'website'),
              ),
              _buildFormField(
                label: 'Instagram',
                controller: _instagramController,
                validator: (v) => _validateOptionalUrl(v, 'instagram'),
              ),
              _buildFormField(
                label: 'Twitter/X',
                controller: _twitterController,
                validator: (v) => _validateOptionalUrl(v, 'twitter'),
              ),
              _buildFormField(
                label: 'Youtube',
                controller: _youtubeController,
                validator: (v) => _validateOptionalUrl(v, 'youtube'),
              ),
              const SizedBox(height: 20),
              _buildImagePicker(),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Icon(_selectedSeiyu != null
                        ? Icons.update
                        : Icons.upload),
                label: Text(_isLoading
                    ? 'Proses...'
                    : _selectedSeiyu != null
                        ? 'Update Seiyu'
                        : 'Tambah Seiyu'),
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              if (_selectedSeiyu != null) const SizedBox(height: 20),
              if (_selectedSeiyu != null)
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text('Hapus Seiyu'),
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

  String? _validateOptionalUrl(String? value, String type) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;

    RegExp pattern;
    String example;

    switch (type) {
      case 'website':
        pattern = RegExp(
          r'^(https?:\/\/(www\.)?|www\.)'
          r'([a-zA-Z0-9-]+\.)+'
          r'[a-zA-Z]{2,}'
          r'(\/.*)?$'
        );
        example = 'https://example.com';
        break;
      case 'instagram':
        pattern = RegExp(r'^https?:\/\/(www\.)?instagram\.com\/[A-Za-z0-9_.]{1,30}\/?$');
        example = 'https://instagram.com/username';
        break;
      case 'twitter':
        pattern = RegExp(r'^https?:\/\/(www\.)?(twitter\.com|x\.com)\/[A-Za-z0-9_]{1,15}\/?$');
        example = 'https://x.com/username';
        break;
      case 'youtube':
        pattern = RegExp(r'^https?:\/\/(www\.)?(youtube\.com\/(channel\/|c\/|user\/|@)|youtu\.be\/)[a-zA-Z0-9_-]+(\/?)$');
        example = 'https://youtube.com/@username';
        break;
      default:
        return null;
    }

    return !pattern.hasMatch(trimmed)
        ? 'Format URL tidak valid\nContoh: $example'
        : null;
  }
}