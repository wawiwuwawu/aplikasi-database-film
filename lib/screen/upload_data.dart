import 'package:flutter/material.dart';
import 'package:weebase/screen/upload_list/staff_upload_list.dart';
import 'package:weebase/screen/upload_list/seiyu_upload_list.dart';
import 'package:weebase/screen/upload_list/karakter_upload_list.dart';
import 'package:weebase/screen/upload_list/movie_upload_list.dart';

class AdminMenuPage extends StatelessWidget {
  const AdminMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItem(
        icon: Icons.movie_creation,
        title: 'Tambah Movie',
        color: Colors.blue,
        destination: const MovieUploadListScreen(),
      ),
      _MenuItem(
        icon: Icons.people,
        title: 'Tambah Staff',
        color: Colors.green,
        destination: const StaffUploadListScreen(),
      ),
      _MenuItem(
        icon: Icons.mic,
        title: 'Tambah Seiyu',
        color: Colors.orange,
        destination: const SeiyuUploadListScreen(),
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

