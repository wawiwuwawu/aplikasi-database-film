import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:numberpicker/numberpicker.dart';

class MovieFormPage extends StatefulWidget {
  const MovieFormPage({super.key});

  @override
  _MovieFormPageState createState() => _MovieFormPageState();
}

class _MovieFormPageState extends State<MovieFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _sinopsisController = TextEditingController();
  final _typeController = TextEditingController();
  final _ratingController = TextEditingController();

  int _selectedYear = DateTime.now().year;
  int _selectedDuration = 20;
  int _selectedEpisode = 12;

  List<Genre> _allGenres = [];
  List<Genre> _selectedGenres = [];
  List<ThemeModel> _allThemes = [];
  List<ThemeModel> _selectedThemes = [];
  List<StaffForm> _staffs = [];
  List<SeiyuForm> _seiyus = [];
  List<CharacterForm> _karakters = [];

  File? _coverImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _allGenres = [
      Genre(id: 1, nama: 'Action'),
      Genre(id: 2, nama: 'Adventure'),
      Genre(id: 3, nama: 'Avant Garde'),
      Genre(id: 4, nama: 'Award Winning'),
      Genre(id: 5, nama: 'Boys Love'),
      Genre(id: 6, nama: 'Comedy'),
      Genre(id: 7, nama: 'Drama'),
      Genre(id: 8, nama: 'Fantasy'),
      Genre(id: 9, nama: 'Girls Love'),
      Genre(id: 10, nama: 'Gourmet'),
      Genre(id: 11, nama: 'Horror'),
      Genre(id: 12, nama: 'Mystery'),
      Genre(id: 13, nama: 'Romance'),
      Genre(id: 14, nama: 'Sci-Fi'),
      Genre(id: 15, nama: 'Slice of Life'),
      Genre(id: 16, nama: 'Sports'),
      Genre(id: 17, nama: 'Supernatural'),
      Genre(id: 18, nama: 'Suspense'),
      Genre(id: 19, nama: 'Echi'),
    ];
    _allThemes = [
      ThemeModel(id: 1, nama: 'Adult Cast'),
      ThemeModel(id: 2, nama: 'Anthropomorphic'),
      ThemeModel(id: 3, nama: 'CGDCT'),
      ThemeModel(id: 4, nama: 'Childcare'),
      ThemeModel(id: 5, nama: 'Combat Sports'),
      ThemeModel(id: 6, nama: 'Crossdressing'),
      ThemeModel(id: 7, nama: 'Delinquents'),
      ThemeModel(id: 8, nama: 'Detective'),
      ThemeModel(id: 9, nama: 'Educational'),
      ThemeModel(id: 10, nama: 'Gag Humor'),
      ThemeModel(id: 11, nama: 'Gore'),
      ThemeModel(id: 12, nama: 'Harem'),
      ThemeModel(id: 13, nama: 'High Stakes Game'),
      ThemeModel(id: 14, nama: 'Historical'),
      ThemeModel(id: 15, nama: 'Idols (Female)'),
      ThemeModel(id: 16, nama: 'Idols (Male)'),
      ThemeModel(id: 17, nama: 'Isekai'),
      ThemeModel(id: 18, nama: 'Iyashikei'),
      ThemeModel(id: 19, nama: 'Love Polygon'),
      ThemeModel(id: 20, nama: 'Love Status Quo'),
      ThemeModel(id: 21, nama: 'Magical Sex Shift'),
      ThemeModel(id: 22, nama: 'Mahou Shoujo'),
      ThemeModel(id: 23, nama: 'Martial Arts'),
      ThemeModel(id: 24, nama: 'Mecha'),
      ThemeModel(id: 25, nama: 'Medical'),
      ThemeModel(id: 26, nama: 'Military'),
      ThemeModel(id: 27, nama: 'Music'),
      ThemeModel(id: 28, nama: 'Mythology'),
      ThemeModel(id: 29, nama: 'Organized Crime'),
      ThemeModel(id: 30, nama: 'Otaku Culture'),
      ThemeModel(id: 31, nama: 'Parody'),
      ThemeModel(id: 32, nama: 'Performing Arts'),
      ThemeModel(id: 33, nama: 'Pets'),
      ThemeModel(id: 34, nama: 'Psychological'),
      ThemeModel(id: 35, nama: 'Racing'),
      ThemeModel(id: 36, nama: 'Reincarnation'),
      ThemeModel(id: 37, nama: 'Reverse Harem'),
      ThemeModel(id: 38, nama: 'Samurai'),
      ThemeModel(id: 39, nama: 'School'),
      ThemeModel(id: 40, nama: 'Showbiz'),
      ThemeModel(id: 41, nama: 'Space'),
      ThemeModel(id: 42, nama: 'Strategy Game'),
      ThemeModel(id: 43, nama: 'Super Power'),
      ThemeModel(id: 44, nama: 'Survival'),
      ThemeModel(id: 45, nama: 'Team Sports'),
      ThemeModel(id: 46, nama: 'Time Travel'),
      ThemeModel(id: 47, nama: 'Urban Fantasy'),
      ThemeModel(id: 48, nama: 'Vampire'),
      ThemeModel(id: 49, nama: 'Video Game'),
      ThemeModel(id: 50, nama: 'Villainess'),
      ThemeModel(id: 51, nama: 'Visual Arts'),
      ThemeModel(id: 52, nama: 'Workplace'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Movie')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_judulController, 'Judul', 'Masukkan judul'),
              const SizedBox(height: 12),
              _buildTextField(_sinopsisController, 'Sinopsis', 'Masukkan sinopsis', maxLines: 3),
              const SizedBox(height: 12),
              _buildYearPicker(),
              const SizedBox(height: 12),
              _buildDropdownField(
                controller: _typeController,
                label: 'Type',
                items: const ['TV', 'Movie', 'ONA', 'OVA'],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildNumberPicker('Episode', _selectedEpisode, _pickEpisode)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildNumberPicker('Durasi', _selectedDuration, _pickDuration)),
                ],
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                controller: _ratingController,
                label: 'Rating',
                items: const ['G', 'PG', 'PG-13', 'R', 'NC-17'],
              ),
              const SizedBox(height: 16),
              _buildGenreCheckboxList(),
              const SizedBox(height: 16),
              _buildThemeCheckboxList(),
              const SizedBox(height: 16),
              _buildDynamicList('Staffs', _staffs, () => StaffForm()),
              const SizedBox(height: 16),
              _buildSeiyuAndCharacterSection(),
              const SizedBox(height: 16),
              _buildCoverPicker(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String error, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      maxLines: maxLines,
      validator: (v) => v!.isEmpty ? error : null,
    );
  }

  Widget _buildYearPicker() {
    return InkWell(
      onTap: _pickYear,
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Tahun Rilis', border: OutlineInputBorder()),
        child: Text('$_selectedYear'),
      ),
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    required List<String> items,
  }) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      decoration: InputDecoration(labelText: label),
      items: items.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
      onChanged: (value) => setState(() => controller.text = value ?? ''),
      validator: (value) => value == null || value.isEmpty ? 'Pilih $label' : null,
    );
  }

  Widget _buildNumberPicker(String label, int value, Future<void> Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        child: Text('$value'),
      ),
    );
  }

  Widget _buildMultiSelect<T>(String label, List<T> allItems, List<T> selectedItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Wrap(
          spacing: 8,
          children: allItems.map((item) {
            final isSelected = selectedItems.contains(item);
            return FilterChip(
              label: Text(item.toString()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selected ? selectedItems.add(item) : selectedItems.remove(item);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDynamicList<T>(String label, List<T> items, T Function() createItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        ...items.map((item) => (item as dynamic).build(context, onRemove: () => setState(() => items.remove(item)))),
        TextButton.icon(
          onPressed: () => setState(() => items.add(createItem())),
          icon: const Icon(Icons.add),
          label: Text('Tambah $label'),
        ),
      ],
    );
  }

  Widget _buildSeiyuAndCharacterSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildDynamicList('Seiyus', _seiyus, () => SeiyuForm()),
        ),
        const SizedBox(width: 16), // Jarak antara Seiyu dan Karakter
        Expanded(
          child: _buildDynamicList('Karakters', _karakters, () => CharacterForm()),
        ),
      ],
    );
  }

  Widget _buildCoverPicker() {
    return InkWell(
      onTap: _pickCover,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _coverImage == null
            ? const Center(child: Text('Pilih Cover'))
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

  Widget _buildGenreCheckboxList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Genres',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allGenres.map((genre) {
            final isSelected = _selectedGenres.contains(genre);
            return FilterChip(
              label: Text(genre.nama),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selected ? _selectedGenres.add(genre) : _selectedGenres.remove(genre);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildThemeCheckboxList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Themes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allThemes.map((theme) {
            final isSelected = _selectedThemes.contains(theme);
            return FilterChip(
              label: Text(theme.nama),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selected ? _selectedThemes.add(theme) : _selectedThemes.remove(theme);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _pickYear() async {
    final firstYear = 1900;
    final lastYear = DateTime.now().year + 5;
    await showModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: 300,
        child: YearPicker(
          firstDate: DateTime(firstYear),
          lastDate: DateTime(lastYear),
          initialDate: DateTime(_selectedYear),
          selectedDate: DateTime(_selectedYear),
          onChanged: (date) {
            setState(() => _selectedYear = date.year);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _pickDuration() => _showNumberPicker('Durasi (menit)', _selectedDuration, (value) => setState(() => _selectedDuration = value));
  Future<void> _pickEpisode() => _showNumberPicker('Episode', _selectedEpisode, (value) => setState(() => _selectedEpisode = value));

  Future<void> _showNumberPicker(String title, int initialValue, ValueChanged<int> onConfirm) async {
    int temp = initialValue;
    await showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => SizedBox(
          height: 250,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 16)),
              Expanded(
                child: Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.7,
                    child: NumberPicker(
                      value: temp,
                      minValue: 1,
                      maxValue: 500,
                      onChanged: (v) => setModalState(() => temp = v),
                      infiniteLoop: true,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  onConfirm(temp);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickCover() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _coverImage = File(image.path));
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _coverImage != null) {
      print('Form valid, submit data');
    } else if (_coverImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih cover terlebih dahulu')));
    }
  }
}

// Helper forms for dynamic entries
class StaffForm {
  final name = TextEditingController();
  final role = TextEditingController();
  Widget build(BuildContext context, {required VoidCallback onRemove}) {
    return _buildCard(
      children: [
        _buildTextField(name, 'Nama Staff'),
        _buildTextField(role, 'Role'),
        _buildRemoveButton(onRemove),
      ],
    );
  }
}

class SeiyuForm {
  final name = TextEditingController();
  Widget build(BuildContext context, {required VoidCallback onRemove}) {
    return _buildCard(
      children: [
        _buildTextField(name, 'Nama Seiyu'),
        _buildRemoveButton(onRemove),
      ],
    );
  }
}

class CharacterForm {
  final name = TextEditingController();
  Widget build(BuildContext context, {required VoidCallback onRemove}) {
    return _buildCard(
      children: [
        _buildTextField(name, 'Nama Karakter'),
        _buildRemoveButton(onRemove),
      ],
    );
  }
}

// Shared UI helpers
Widget _buildCard({required List<Widget> children}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 4),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Column(children: children),
    ),
  );
}

Widget _buildTextField(TextEditingController controller, String label) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label),
  );
}

Widget _buildRemoveButton(VoidCallback onRemove) {
  return Align(
    alignment: Alignment.centerRight,
    child: IconButton(icon: const Icon(Icons.delete), onPressed: onRemove),
  );
}

// Dummy models for compile-time
class Genre {
  final int id;
  final String nama;
  Genre({required this.id, required this.nama});
}

class ThemeModel {
  final int id;
  final String nama;
  ThemeModel({required this.id, required this.nama});
}
