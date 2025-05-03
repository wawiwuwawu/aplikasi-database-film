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

  File? _coverImage;
  bool _isLoading = false;
  String? _errorMessage;

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
    if (_coverImage == null) {
      setState(() => _errorMessage = 'Cover wajib dipilih');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
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

      _resetForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload berhasil!')),
      );
    } catch (e) {
      setState(() => _errorMessage = 'Error saat upload: ${e.toString()}');
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
      _errorMessage = null;
      _isLoading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Seiyu')),
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
                      onTap: _pickDate, // Membuka date picker
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _birthdateController.clear(); // Menghapus input tanggal
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
              InkWell(
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

  String? _validateOptionalUrl(String? value, String type) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;

    RegExp pattern;
    String example;

    switch (type) {
      case 'website':
        pattern = RegExp(r'^(https?:\/\/)?(www\.)?[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(\/\S*)?$');
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