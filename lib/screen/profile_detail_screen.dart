import 'package:flutter/material.dart';
import '../model/user_model.dart';

class ProfileDetailScreen extends StatefulWidget {
  final User user;
  const ProfileDetailScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: widget.user.profileUrl != null && widget.user.profileUrl!.isNotEmpty
                    ? CircleAvatar(
                        radius: 48,
                        backgroundImage: NetworkImage(widget.user.profileUrl!),
                      )
                    : CircleAvatar(
                        radius: 48,
                        child: Icon(Icons.person, size: 48),
                      ),
              ),
              SizedBox(height: 24),
              TextField(
                controller: _nameController,
                enabled: isEditing,
                decoration: InputDecoration(labelText: 'Nama'),
              ),
              SizedBox(height: 16),
              Text('Email: ${widget.user.email}', style: TextStyle(fontSize: 16)),
              if (widget.user.createdAt != null)
                Text('Dibuat: ${widget.user.createdAt}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              _bioController.text.isEmpty && !isEditing
                  ? Text('Belum ada bio', style: TextStyle(color: Colors.grey))
                  : TextField(
                      controller: _bioController,
                      enabled: isEditing,
                      decoration: InputDecoration(
                        labelText: 'Bio',
                        hintText: 'Belum ada bio',
                      ),
                      maxLines: 3,
                    ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isEditing = !isEditing;
                  });
                },
                child: Text(isEditing ? 'Simpan' : 'Edit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
