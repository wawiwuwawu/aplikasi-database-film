import 'package:flutter/material.dart';
import '../../model/karakter_model.dart';
import '../../service/karakter_service.dart';

class KarakterUploadListScreen extends StatefulWidget {
  const KarakterUploadListScreen({super.key});

  @override
  State<KarakterUploadListScreen> createState() => _KarakterUploadListScreenState();
}

class _KarakterUploadListScreenState extends State<KarakterUploadListScreen> {
  List<Karakter> _karakterList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchKarakter();
  }

  Future<void> _fetchKarakter() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await KarakterService().getAllKarakter();
      setState(() {
        _karakterList = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Karakter')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _karakterList.length,
                  itemBuilder: (context, i) {
                    final karakter = _karakterList[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        child: ListTile(
                          leading: karakter.profileUrl != null && karakter.profileUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    karakter.profileUrl!,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => const Icon(Icons.person, size: 48),
                                  ),
                                )
                              : const Icon(Icons.person, size: 48),
                          title: Text(karakter.nama, maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'ID: ${karakter.id}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          onTap: () {
                            // TODO: Navigasi ke detail/edit karakter jika perlu
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
