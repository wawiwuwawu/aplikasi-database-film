import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../service/karakter_service.dart';
import '../model/karakter_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddCharacterForm extends StatefulWidget {
  const AddCharacterForm({super.key});

  @override
  _KarakterUploadPageState createState() => _KarakterUploadPageState();
}

class _KarakterUploadPageState extends State<AddCharacterForm> {
  final _formKey = GlobalKey<FormState>();
  final KarakterService _apiService = KarakterService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  late Karakter _karakter;
  final Map<String, dynamic> _formData = {};
  File? _coverImage;
  bool _isLoading = false;
  String? _errorMessage;
  final double _fixedAspectRatio = 4/5;

  @override
  void initState() {
    super.initState();
    _namaController.addListener(_updateFormData);
    _bioController.addListener(_updateFormData);
    _karakter = Karakter(
      id: 0,
      nama: '',
      bio: '',
      profileUrl: '',
    );
  }

  void _resetForm() {
    setState(() {
      _formKey.currentState?.reset();
      _namaController.clear();
      _bioController.clear();
      _coverImage = null;
      _formData.clear();
      _errorMessage = null;
      _isLoading = false;
    });
  }

    void _updateFormData() {
    _formData['nama'] = _namaController.text;
    _formData['bio'] = _bioController.text;
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

  try {
    await _apiService.uploadKarakter(
      karakter: _karakter.copyWith(
        nama: _namaController.text,
        bio:  _bioController.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Karakter Baru')),
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
                controller: _namaController,
                validator: (v) => (v?.isEmpty ?? true) ? 'Harus diisi' : null,
              ),
              _buildFormField(
                label: 'bio',
                controller: _bioController,
                validator: (v) => (v?.isEmpty ?? true) ? 'Harus diisi' : null,
              ),
            ],
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
          ),
        ),
      ),
    );
  }
}