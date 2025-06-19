import 'package:flutter/material.dart';
import 'package:weebase/service/preferences_service.dart';
import 'profile_detail_screen.dart';
import 'about_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    final creds = PreferencesService.getCredentials();
    if (mounted) {
      setState(() {
        user = creds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? '-';
    final email = user?.email ?? '-';
    final profileUrl = user?.profileUrl;

    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.person,
        'title': 'Profile',
        'onTap': () {
          if (user == null) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileDetailScreen(user: user!),
            ),
          );
        },
      },
      {
        'icon': Icons.error_outline,
        'title': 'About',
        'onTap': () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AboutScreen()));
        },
      },
      {
        'icon': Icons.help_outline,
        'title': 'FAQ',
        'onTap': () async {
          final url = Uri.parse('https://web.wawunime.my.id/html/faq.html');
          await launchUrl(url, mode: LaunchMode.externalApplication);
        },
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F1FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () async {
              await PreferencesService.clearToken();
              await PreferencesService.clearCredentials();
              await PreferencesService.clearMovieCache();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            icon: Icon(Icons.logout, color: Colors.black),
            label: Text('LogOut', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: 32),
                Center(
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: Colors.purple[100],
                    backgroundImage: (profileUrl != null && profileUrl.isNotEmpty)
                        ? NetworkImage(profileUrl)
                        : null,
                    child: (profileUrl == null || profileUrl.isEmpty)
                        ? Icon(Icons.person, size: 56, color: Colors.white)
                        : null,
                  ),
                ),
                SizedBox(height: 16),
                Text(name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(email, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                SizedBox(height: 24),
                ...menuItems.map((item) => Card(
                      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: ListTile(
                        leading: Icon(item['icon'], color: Colors.purple),
                        title: Text(item['title']),
                        onTap: item['onTap'],
                      ),
                    )),
              ],
            ),
    );
  }
}