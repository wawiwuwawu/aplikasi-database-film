import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../service/karakter_service.dart';
import '../model/karakter_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddCharacterForm extends StatefulWidget {
  const AddCharacterForm({super.key});

  @override
  _AddKarakterFormState createState() => _AddKarakterFormState();
}

class _AddKarakterFormState extends State<AddCharacterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _profileUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Staff')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Staff'),
                validator: (value) => value!.isEmpty ? 'Harus diisi' : null,
              ),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: 'Peran'),
                validator: (value) => value!.isEmpty ? 'Harus diisi' : null,
              ),
              TextFormField(
                controller: _profileUrlController,
                decoration: const InputDecoration(labelText: 'URL Profil'),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newStaff = {
        'name': _nameController.text,
        'role': _roleController.text,
        'profile_url': _profileUrlController.text,
      };
    }
  }
}