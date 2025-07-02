import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weebase/model/staff_model.dart';
import 'package:weebase/service/staff_service.dart';
import 'package:weebase/screen/form_upload/staff_upload.dart';

class StaffUploadListScreen extends StatefulWidget {
  const StaffUploadListScreen({super.key});

  @override
  State<StaffUploadListScreen> createState() => _staffUploadListScreenState();
}

class _staffUploadListScreenState extends State<StaffUploadListScreen> {
  List<Staff> _staffList = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  final int _perPage = 25;
  final ScrollController _scrollController = ScrollController();
  bool _serverOffline = false;

  // State untuk pencarian
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchStaff();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Fungsi untuk mereset daftar dan memulai pencarian/refresh baru
  void _resetAndFetch() {
    setState(() {
      _staffList.clear();
      _currentPage = 1;
      _hasMore = true;
      _error = null;
      _serverOffline = false;
    });
    _fetchStaff();
  }

  // --- INI FUNGSI YANG PERLU ANDA GANTI / SESUAIKAN ---
  Future<void> _fetchStaff() async {
    // Guard untuk mencegah pemanggilan ganda
    if (_isLoading || !_hasMore) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Variabel untuk menampung hasil dari API
      late final List<Staff> list;

      // Logika untuk memilih service yang akan digunakan
      if (_searchQuery.isEmpty) {
        // Jika tidak mencari, panggil service get all
        list = await StaffService().getAllStaff(
          page: _currentPage,
        );
      } else {
        // Jika mencari, panggil service search dengan menyertakan halaman
        list = await StaffService().searchStaffByName(
          _searchQuery,
          page: _currentPage, // Tambahkan parameter halaman di sini
        );
      }

      // Setelah mendapatkan data, update UI
      setState(() {
        if (list.length < _perPage) {
          _hasMore = false;
        }
        _staffList.addAll(list);
        _isLoading = false;
        _currentPage++; // Selalu naikkan halaman setelah fetch berhasil
      });
    } catch (e, s) {
      print('Error fetching staff: $e');
      print(s);
      setState(() {
        _error = e.toString();
        _isLoading = false;
        if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
          _serverOffline = true;
        }
      });
    }
  }
  // --- BATAS AKHIR FUNGSI YANG DIGANTI ---

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _fetchStaff();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari karakter...',
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        if (_searchQuery.isNotEmpty) {
                          setState(() => _searchQuery = '');
                          _resetAndFetch();
                        }
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                if (_searchQuery != value) {
                  setState(() => _searchQuery = value);
                  _resetAndFetch();
                }
              });
            },
          ),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddStaffForm(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah staff',
      ),
    );
  }

  Widget _buildBody() {
    if (_staffList.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_serverOffline) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text('Server Offline', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              onPressed: _resetAndFetch,
            ),
          ],
        ),
      );
    }

    if (_staffList.isEmpty && !_isLoading) {
      return Center(
        child: Text(_error != null ? 'Error: $_error' : 'Tidak ada staff ditemukan.'),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        _searchController.clear();
        setState(() => _searchQuery = '');
        _resetAndFetch();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _staffList.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == _staffList.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final staff = _staffList[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: ListTile(
                leading: staff.profileUrl != null && staff.profileUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          staff.profileUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(Icons.person, size: 48),
                        ),
                      )
                    : const Icon(Icons.person, size: 48),
                title: Text(staff.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ID: ${staff.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddStaffForm(staff: staff),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}