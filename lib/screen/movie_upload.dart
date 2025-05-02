import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../service/movie_service.dart';
import '../model/movie_model.dart';
import 'package:flutter/material.dart';

class MovieFormPage extends StatefulWidget {
  const MovieFormPage({super.key});
  @override
  _MovieFormPageState createState() => _MovieFormPageState();
}

class _MovieFormPageState extends State<MovieFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _sinopsisController = TextEditingController();
  final TextEditingController _tahunController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _episodeController = TextEditingController();
  final TextEditingController _durasiController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  List<Genre> _allGenres = [];
  List<Genre> _selectedGenres = [];

  List<ThemeModel> _allThemes = [];
  List<ThemeModel> _selectedThemes = [];

  List<StaffForm> _staffs = [];
  List<SeiyuForm> _seiyus = [];
  List<CharacterForm> _karakters = [];

  File? _coverImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickCover() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _coverImage = File(image.path));
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _coverImage != null) {
      print('Form valid, submit data');
    } else if (_coverImage == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Pilih cover terlebih dahulu')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Movie')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul
              TextFormField(
                controller: _judulController,
                decoration: InputDecoration(labelText: 'Judul'),
                validator: (v) => v!.isEmpty ? 'Masukkan judul' : null,
              ),
              SizedBox(height: 12),
              // Sinopsis
              TextFormField(
                controller: _sinopsisController,
                decoration: InputDecoration(labelText: 'Sinopsis'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Masukkan sinopsis' : null,
              ),
              SizedBox(height: 12),
              // Tahun, Type, Episode, Durasi, Rating Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tahunController,
                      decoration: InputDecoration(labelText: 'Tahun Rilis'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Tahun?' : null,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                      child: DropdownButtonFormField<String>(
                      value: _typeController.text.isEmpty ? null : _typeController.text,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: const ['TV', 'Movie', 'ONA', 'OVA']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                       value: value,
                        child: Text(value),
                      );
                      }).toList(),
                  onChanged: (String? newValue) {
                  setState(() {
                    _typeController.text = newValue ?? '';
                  });
                },
                  validator: (value) => value == null || value.isEmpty ? 'Pilih Type' : null,
                )), 
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _episodeController,
                      decoration: InputDecoration(labelText: 'Episode'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Episodes?' : null,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _durasiController,
                      decoration: InputDecoration(labelText: 'Durasi (menit)'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Durasi?' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _ratingController.text.isEmpty ? null : _ratingController.text,
                decoration: const InputDecoration(labelText: 'Rating'),
                items: const ['G', 'PG', 'PG-13', 'R', 'NC-17']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _ratingController.text = newValue ?? '';
                  });
                },
                validator: (value) => value == null || value.isEmpty ? 'Pilih Rating' : null,
              ),
              SizedBox(height: 16),
              // Genre MultiSelect
              Text('Genres'),
              Wrap(
                spacing: 8,
                children: _allGenres.map((g) {
                  final selected = _selectedGenres.contains(g);
                  return FilterChip(
                    label: Text(g.nama),
                    selected: selected,
                    onSelected: (sel) {
                      setState(() {
                        sel ? _selectedGenres.add(g) : _selectedGenres.remove(g);
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              // Themes MultiSelect
              Text('Themes'),
              Wrap(
                spacing: 8,
                children: _allThemes.map((t) {
                  final selected = _selectedThemes.contains(t);
                  return FilterChip(
                    label: Text(t.nama),
                    selected: selected,
                    onSelected: (sel) {
                      setState(() {
                        sel ? _selectedThemes.add(t) : _selectedThemes.remove(t);
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              // Dynamic lists
              Text('Staffs'),
              ..._staffs.map((s) => s.build(context, onRemove: () {
                    setState(() => _staffs.remove(s));
                  })),
              TextButton.icon(
                onPressed: () => setState(() => _staffs.add(StaffForm())),
                icon: Icon(Icons.add),
                label: Text('Tambah Staff'),
              ),
              SizedBox(height: 16),
              Text('Seiyus'),
              ..._seiyus.map((s) => s.build(context, onRemove: () {
                    setState(() => _seiyus.remove(s));
                  })),
              TextButton.icon(
                onPressed: () => setState(() => _seiyus.add(SeiyuForm())),
                icon: Icon(Icons.add),
                label: Text('Tambah Seiyu'),
              ),
              SizedBox(height: 16),
              Text('Karakters'),
              ..._karakters.map((c) => c.build(context, onRemove: () {
                    setState(() => _karakters.remove(c));
                  })),
              TextButton.icon(
                onPressed: () => setState(() => _karakters.add(CharacterForm())),
                icon: Icon(Icons.add),
                label: Text('Tambah Karakter'),
              ),
              SizedBox(height: 16),
              // Cover picker
              Text('Cover Image'),
              SizedBox(height: 8),
              GestureDetector(
                onTap: _pickCover,
                child: _coverImage == null
                    ? Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Icon(Icons.add_a_photo, size: 50),
                      )
                    : Image.file(_coverImage!, height: 150, fit: BoxFit.cover),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper forms for dynamic entries

class StaffForm {
  final TextEditingController name = TextEditingController();
  final TextEditingController role = TextEditingController();
  Widget build(BuildContext context, {required VoidCallback onRemove}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            TextFormField(
              controller: name,
              decoration: InputDecoration(labelText: 'Nama Staff'),
            ),
            TextFormField(
              controller: role,
              decoration: InputDecoration(labelText: 'Role'),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.delete),
                onPressed: onRemove,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SeiyuForm {
  final TextEditingController name = TextEditingController();
  Widget build(BuildContext context, {required VoidCallback onRemove}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: name,
                decoration: InputDecoration(labelText: 'Nama Seiyu'),
              ),
            ),
            IconButton(icon: Icon(Icons.delete), onPressed: onRemove),
          ],
        ),
      ),
    );
  }
}

class CharacterForm {
  final TextEditingController name = TextEditingController();
  Widget build(BuildContext context, {required VoidCallback onRemove}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: name,
                decoration: InputDecoration(labelText: 'Nama Karakter'),
              ),
            ),
            IconButton(icon: Icon(Icons.delete), onPressed: onRemove),
          ],
        ),
      ),
    );
  }
}

// Dummy models for compile-time
class Genre { final int id; final String nama; Genre({required this.id, required this.nama}); }
class ThemeModel { final int id; final String nama; ThemeModel({required this.id, required this.nama}); }
