import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../model/user_model.dart';
import '../../service/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  File? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService().updateUser(
        id: widget.user.id,
        name: _nameController.text.trim(),
        email: widget.user.email,
        bio:
            _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
        profileImage: _profileImage,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Profil berhasil diperbarui')));
        Navigator.pop(context, true); // Kirim nilai true untuk trigger refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memperbarui profil: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profil')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : (widget.user.profileUrl != null
                                      ? NetworkImage(widget.user.profileUrl!)
                                          as ImageProvider
                                      : null),
                          child:
                              _profileImage == null &&
                                      widget.user.profileUrl == null
                                  ? Icon(Icons.person, size: 50)
                                  : null,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Nama'),
                        validator:
                            (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? 'Nama tidak boleh kosong'
                                    : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _bioController,
                        decoration: InputDecoration(labelText: 'Bio'),
                        maxLines: 3,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _saveProfile,
                        child: Text('Simpan'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
