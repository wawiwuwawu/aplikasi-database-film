import 'package:flutter/material.dart';
import 'form_upload/staff_upload.dart';
import 'form_upload/seiyu_upload.dart';
import 'upload_list/karakter_upload_list.dart';
import 'form_upload/movie_upload.dart';

class AdminMenuPage extends StatelessWidget {
  const AdminMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItem(
        icon: Icons.movie_creation,
        title: 'Tambah Movie',
        color: Colors.blue,
        destination: const MovieFormPage(),
      ),
      _MenuItem(
        icon: Icons.people,
        title: 'Tambah Staff',
        color: Colors.green,
        destination: const AddStaffForm(),
      ),
      _MenuItem(
        icon: Icons.mic,
        title: 'Tambah Seiyu',
        color: Colors.orange,
        destination: const AddSeiyuForm(),
      ),
      _MenuItem(
        icon: Icons.person,
        title: 'Kelola Karakter',
        color: Colors.purple,
        destination: const KarakterUploadListScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return _buildMenuCard(context, item);
        },
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, _MenuItem item) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => item.destination),
        ),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 50, color: item.color),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: TextStyle(
                fontSize: 16,
                color: item.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final Color color;
  final Widget destination;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.destination,
  });
}

