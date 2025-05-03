import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../service/staff_service.dart';
import '../model/staff_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddStaffForm extends StatefulWidget {
  const AddStaffForm({super.key});

  @override
  _StaffUploadPageState createState() => _StaffUploadPageState();
}

class _StaffUploadPageState extends State<AddStaffForm> {
  final _formKey = GlobalKey<FormState>();
  final StaffService _apiService = StaffService();
  final ImagePicker _picker = ImagePicker();
  final List<String> _roles = ['Director', 'Producer', 'Staff'];
  String? _selectedRole;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();


  late Staff _staff;
  File? _coverImage;
  bool _isLoading = false;
  String? _errorMessage;
  final double _fixedAspectRatio = 4/5;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    _staff = Staff(
      id: 0,
      name: '',
      birthday: '',
      role: '',
      bio: '',
      profileUrl: '',
    );
  }

  void _resetForm() {
  setState(() {
    _formKey.currentState?.reset();
    _selectedDate = null;
    _nameController.clear();
    _birthdateController.clear();
    _roleController.clear();
    _bioController.clear();
    _selectedRole = null;
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
      'role': _selectedRole,
      'bio': _bioController.text.trim(),
      };

    try {
      await _apiService.uploadStaff(
        staff: _staff.copyWith(
          name: data['name'],
          birthday: data['birthday'],
          role: data['role'],
          bio: data['bio'],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Staff')),
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
                        onPressed: _resetForm,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: _roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                value: _selectedRole,
                validator: (v) => v == null ? 'Harus dipilih' : null,
                onChanged: (v) {
                  setState(() {
                    _selectedRole = v;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Bio',
                controller: _bioController,
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
                                '4:5', // Tampilkan rasio tetap
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