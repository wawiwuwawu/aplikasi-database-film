import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../service/movie_service.dart';
import '../model/movie_model.dart';
import '../screen/staff_upload.dart';
import '../screen/seiyu_upload.dart';
import '../screen/karakter_upload.dart';
import '../screen/movie_upload.dart';
import 'package:flutter/material.dart';
import 'dart:convert';


class AdminMenuPage extends StatelessWidget {
  const AdminMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuCard(
            context,
            Icons.movie_creation,
            'Tambah Movie',
            Colors.blue,
            () => _navigateToForm(context, const MovieFormPage()),
          ),
          _buildMenuCard(
            context,
            Icons.people,
            'Tambah Staff',
            Colors.green,
            () => _navigateToForm(context, const AddStaffForm()),
          ),
          _buildMenuCard(
            context,
            Icons.mic,
            'Tambah Seiyu',
            Colors.orange,
            () => _navigateToForm(context, const AddSeiyuForm()),
          ),
          _buildMenuCard(
            context,
            Icons.person,
            'Tambah Karakter',
            Colors.purple,
            () => _navigateToForm(context, const AddCharacterForm()),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, IconData icon, String title,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold
            )),
          ],
        ),
      ),
    );
  }

  void _navigateToForm(BuildContext context, Widget form) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => form),
    );
  }
}

