import 'package:flutter/material.dart';
import 'package:flutter_application_1/screen/login_screen.dart';
import 'package:flutter_application_1/service/preferences_service.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: ProfileScreen()));
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () async {
              await PreferencesService.clearToken();
              await PreferencesService.clearCredentials();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
            icon: Icon(Icons.logout, color: Colors.black),
            label: Text("LogOut", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(
                'assets/avatar.png',
              ), // Ganti path ke gambar kamu
            ),
            const SizedBox(height: 10),
            Text(
              'AlexPastoor25',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text('Alex Pastoor', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 30),
            buildMenuItem(Icons.person_outline, "Profile"),
            buildMenuItem(Icons.mail_outline, "Notification"),
            buildMenuItem(Icons.folder_open, "My List"),
            buildMenuItem(Icons.error_outline, "About"),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFF9F1FD), // Warna soft pink
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
