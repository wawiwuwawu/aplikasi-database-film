import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../service/seiyu_service.dart';
import '../model/seiyu_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddSeiyuForm extends StatefulWidget {
  const AddSeiyuForm({super.key});

  @override
  _SeiyuUploadPageState createState() => _SeiyuUploadPageState();
}

class _SeiyuUploadPageState extends State<AddSeiyuForm> {
  final _formKey = GlobalKey<FormState>();
  final SeiyuService _apiService = SeiyuService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  

  late Seiyu _seiyu;
  File? _coverImage;
  bool _isLoading = false;
  String? _errorMessage;
  final double _fixedAspectRatio = 4/5;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    _seiyu = Seiyu(
      id: 0,
      name: '',
      birthday: '',
      bio: '',
      websiteUrl: '',
      instagramUrl: '',
      twitterUrl: '',
      youtubeUrl: '',
      profileUrl: '',
    );
  }

  void _resetForm() {
    setState(() {
      _formKey.currentState?.reset();
      _selectedDate = null;
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



  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_coverImage == null) {
      setState(() {
        _errorMessage = 'Cover wajib dipilih';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final data = {
    'name': _nameController.text.trim(),
    'birthday': _birthdateController.text.trim(),
    'bio': _bioController.text.trim(),
    'website_url': _websiteController.text.trim().isNotEmpty 
        ? _websiteController.text.trim() 
        : null,
    'instagram_url': _instagramController.text.trim().isNotEmpty
        ? _instagramController.text.trim()
        : null,
    'twitter_url': _twitterController.text.trim().isNotEmpty
        ? _twitterController.text.trim()
        : null,
    'youtube_url': _youtubeController.text.trim().isNotEmpty
        ? _youtubeController.text.trim()
        : null,
  };

    try {
      await _apiService.uploadSeiyu(
        seiyu: _seiyu.copyWith(
          name: data['name'],
          birthday: data['birthday'],
          bio: data['bio'],
          websiteUrl: data['website_url'],
          instagramUrl: data['instagram_url'],
          twitterUrl: data['twitter_url'],
          youtubeUrl: data['youtube_url'],
        ),
        coverImage: _coverImage!,
      );

      _resetForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload berhasil!')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saat upload: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }


  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _birthdateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  String? _validateOptionalUrl(String? value, String type) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return null;
  
  RegExp pattern;
  String example;
  
  switch(type) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Seiyu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
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
              Column(
                children: [
              _buildFormField(
                label: 'Nama',
                controller: _nameController,
                validator: (v) => (v?.isEmpty ?? true) ? 'Harus diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                controller: _birthdateController,
                decoration: InputDecoration(
                  labelText: 'Ulang Tahun',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _pickDate,
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedDate = null;
                            _birthdateController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Bio',
                controller: _bioController,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Website',
                controller: _websiteController,
                validator: (v) => _validateOptionalUrl(v, 'website'),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Instagram',
                controller: _instagramController,
                validator: (v) => _validateOptionalUrl(v, 'instagram'),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Twitter/X',
                controller: _twitterController,
                validator: (v) => _validateOptionalUrl(v, 'twitter'),
              ),
              const SizedBox(height: 16),
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
              constraints: const BoxConstraints(
                maxHeight: 500,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _coverImage == null
                  ? const Center(child: Text('Pilih Profile'))
                  : AspectRatio(
                      aspectRatio: _fixedAspectRatio,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _coverImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '4:5',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
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
              )
            ],
          ),
        ),
      ),
    );
  }
}