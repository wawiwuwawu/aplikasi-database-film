import 'package:flutter/material.dart';

class ProfileDetailScreen extends StatelessWidget {
  final String name;
  final String email;
  final String? bio;
  final String? profileUrl;
  final String? createdAt;

  const ProfileDetailScreen({
    Key? key,
    required this.name,
    required this.email,
    this.bio,
    this.profileUrl,
    this.createdAt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: profileUrl != null && profileUrl!.isNotEmpty
                    ? NetworkImage(profileUrl!)
                    : const AssetImage('assets/avatar.png') as ImageProvider,
              ),
            ),
            const SizedBox(height: 24),
            Text('Nama', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(name, style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(email, style: TextStyle(fontSize: 18)),
            if (bio != null && bio!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Bio', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(bio!, style: TextStyle(fontSize: 18)),
            ],
            if (createdAt != null && createdAt!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Dibuat pada', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(createdAt!, style: TextStyle(fontSize: 18)),
            ],
          ],
        ),
      ),
    );
  }
}
