import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';
import '../../service/staff_service.dart';
import '../../model/staff_model.dart';

class AddStaffForm extends StatefulWidget {
  const AddStaffForm({super.key});

  @override
  _AddStaffFormState createState() => _AddStaffFormState();
}

class _AddStaffFormState extends State<AddStaffForm> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _nameFieldKey = GlobalKey();
  final _bioFieldKey = GlobalKey();
  final _roleFieldKey = GlobalKey();
  final _coverFieldKey = GlobalKey();
  final _apiService = StaffService();
  final _picker = ImagePicker();
  final _roles = ['Director', 'Producer', 'Staff'];
  final _nameController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _bioController = TextEditingController();
  final _searchController = TextEditingController();

  String? _selectedRole;
  File? _coverImageFile;
  String? _coverImageUrl;
  bool _isLoading = false;
  String? _errorMessage;
  final List<Staff> _searchResults = [];
  Staff? _selectedStaff;
  Timer? _debounce;

  @override
  void dispose() {
    _nameController.dispose();
    _birthdateController.dispose();
    _bioController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverImageFile = File(pickedFile.path);
        _coverImageUrl = null;
      });
    }
  }

  Future<void> _searchStaff() async {
    if (_searchController.text.isEmpty) {
      setState(() => _errorMessage = 'Nama staff tidak boleh kosong');
      return;
    }

    setState(() {
      _isLoading = true;
      _searchResults.clear();
    });

    try {
      final results = await _apiService.searchStaffByName(
        _searchController.text,
      );

      if (results.isEmpty) {
        // Tidak set errorMessage, biar hanya snackbar yang muncul
        return;
      }

      setState(() {
        _searchResults.addAll(results);
      });
    } catch (e) {
      // Tidak set errorMessage, biar hanya snackbar yang muncul
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectStaff(Staff staff) {
    if (staff.name.isEmpty) {
      setState(() => _errorMessage = 'Data staff tidak valid');
      return;
    }
    setState(() {
      _selectedStaff = staff;
      _nameController.text = staff.name;
      _birthdateController.text = staff.birthday ?? '';
      _bioController.text = staff.bio ?? '';
      _selectedRole = staff.role;
      _coverImageFile = null;
      _coverImageUrl = staff.profileUrl != null && staff.profileUrl!.isNotEmpty ? staff.profileUrl : null;
      _searchResults.clear();
    });
  }

  Future<void> _deleteStaff() async {
    if (_selectedStaff == null) {
      setState(() => _errorMessage = 'Staff tidak valid untuk dihapus');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _apiService.deleteStaff(_selectedStaff?.id ?? 0);
      _resetForm();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Staff berhasil dihapus!')));
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    if (_selectedStaff == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus staff "${_selectedStaff!.name}"?',
          ),
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
      await _deleteStaff();
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

  Future<void> _scrollToFirstError() async {
    if (_nameController.text.isEmpty) {
      await _ensureVisible(_nameFieldKey);
      return;
    }
    if (_selectedRole == null || _selectedRole!.isEmpty) {
      await _ensureVisible(_roleFieldKey);
      return;
    }
    if (_bioController.text.isEmpty) {
      await _ensureVisible(_bioFieldKey);
      return;
    }
    if (_selectedStaff == null && _coverImageFile == null && (_coverImageUrl == null || _coverImageUrl!.isEmpty)) {
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || (_selectedStaff == null && _coverImageFile == null && (_coverImageUrl == null || _coverImageUrl!.isEmpty))) {
      if (_selectedStaff == null && _coverImageFile == null && (_coverImageUrl == null || _coverImageUrl!.isEmpty)) {
        setState(() => _errorMessage = 'Cover wajib dipilih untuk staff baru');
      }
      await _scrollToFirstError();
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      if (_selectedStaff != null) {
        await _apiService.updateStaff(
          id: _selectedStaff?.id ?? 0,
          staff: Staff(
            id: _selectedStaff?.id ?? 0,
            name: _nameController.text.trim(),
            birthday: _birthdateController.text.trim().isEmpty ? null : _birthdateController.text.trim(),
            role: _selectedRole ?? '',
            bio: _bioController.text.trim(),
            profileUrl: _coverImageUrl ?? _selectedStaff!.profileUrl,
          ),
          coverImage: _coverImageFile, // null jika user tidak pilih file baru
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staff berhasil diperbarui!')),
        );
      } else {
        if (_coverImageFile == null) {
          setState(() => _errorMessage = 'Cover wajib dipilih untuk staff baru');
          return;
        }
        await _apiService.uploadStaff(
          staff: Staff(
            id: 0,
            name: _nameController.text.trim(),
            birthday: _birthdateController.text.trim().isEmpty ? null : _birthdateController.text.trim(),
            role: _selectedRole ?? '',
            bio: _bioController.text.trim(),
            profileUrl: '',
          ),
          coverImage: _coverImageFile!,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staff berhasil ditambahkan!')),
        );
      }
      _resetForm();
    } catch (e) {
      setState(() => _errorMessage = 'Error: ${e.toString()}');
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
      _searchController.clear();
      _selectedRole = null;
      _coverImageFile = null;
      _coverImageUrl = null;
      _selectedStaff = null;
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
                decoration: InputDecoration(
                  labelText: 'Cari Staff (untuk edit)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      _searchController.text.isNotEmpty
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
                      _searchStaff();
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _searchStaff,
              child:
                  _isLoading
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
    // Tampilkan snackbar error hanya jika pencarian sudah selesai dan user tidak sedang mengetik
    if (_searchController.text.isNotEmpty &&
        !_isLoading &&
        _searchResults.isEmpty &&
        (_debounce == null || !_debounce!.isActive)) {
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   if (mounted) {
      //     ScaffoldMessenger.of(context).removeCurrentSnackBar();
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(
      //         content: Text('Staff tidak ditemukan'),
      //         backgroundColor: Colors.red,
      //         duration: Duration(seconds: 2),
      //         behavior: SnackBarBehavior.floating,
      //         margin: EdgeInsets.only(bottom: 80, left: 16, right: 16),
      //       ),
      //     );
      //   }
      // });
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
          final staff = _searchResults[index];
          return ListTile(
            leading:
                staff.profileUrl != null && staff.profileUrl!.isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        staff.profileUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.error, size: 50),
                      ),
                    )
                    : const Icon(Icons.person, size: 50),
            title: Text(staff.name),
            subtitle: Text(staff.bio ?? 'Tidak ada bio'),
            onTap: () {
              _selectStaff(staff);
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
    Key? key,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        key: key,
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
                IconButton(icon: const Icon(Icons.clear), onPressed: onClear),
            ],
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildIdField() {
    if (_selectedStaff == null) return const SizedBox();
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
          'ID Staff: ${_selectedStaff!.id}',
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
        child: _coverImageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _coverImageFile!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 300,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Gagal memuat gambar'));
                  },
                ),
              )
            : (_coverImageUrl != null && _coverImageUrl!.isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _coverImageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 300,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Text('Gagal memuat gambar'));
                      },
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pilih Foto Profile',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Staff'),
        actions: [
          if (_selectedStaff != null)
            ElevatedButton(
              onPressed: _resetForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
              if (_selectedStaff != null)
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
                        'Mode Edit Staff',
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
                controller: _nameController,
                validator: (v) => (v?.isEmpty ?? true) ? 'Harus diisi' : null,
                key: _nameFieldKey,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Hapus',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items:
                    _roles.map((role) {
                      return DropdownMenuItem(value: role, child: Text(role));
                    }).toList(),
                value: _selectedRole,
                validator: (v) => v == null ? 'Harus dipilih' : null,
                onChanged: (v) => setState(() => _selectedRole = v),
                key: _roleFieldKey,
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
                icon:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Icon(
                          _selectedStaff != null ? Icons.update : Icons.upload,
                        ),
                label: Text(
                  _isLoading
                      ? 'Proses...'
                      : _selectedStaff != null
                      ? 'Update Staff'
                      : 'Tambah Staff',
                ),
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              if (_selectedStaff != null) const SizedBox(height: 20),
              if (_selectedStaff != null)
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text('Hapus Staff'),
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
