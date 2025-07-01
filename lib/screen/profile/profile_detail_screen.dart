import 'package:flutter/material.dart';
import 'package:weebase/screen/profile/edit_profile_screen.dart';
import '../login_user/forgot_password_screen.dart';
import 'package:weebase/service/auth_service.dart';
import '../../model/user_model.dart';

class ProfileDetailScreen extends StatefulWidget {
  final User user;
  const ProfileDetailScreen({super.key, required this.user});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  User? _user;
  bool _isLoading = true;
  String? _error;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadUser();
  }

  void _initControllers() {
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController(text: "12345678");
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final fetchedUser = await AuthService().getCurrentUser();
      setState(() {
        _user = fetchedUser;
        _isLoading = false;

        _nameController.text = _user?.name ?? '';
        _emailController.text = _user?.email ?? '';
        _bioController.text = _user?.bio ?? '';
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: const Text('Profil'),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildError()
              : _user == null
              ? const Center(child: Text('Data user tidak tersedia'))
              : _buildProfile(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Terjadi kesalahan:\n$_error', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loadUser, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child:
                  _user?.profileUrl != null && _user!.profileUrl!.isNotEmpty
                      ? CircleAvatar(
                        radius: 48,
                        backgroundImage: NetworkImage(_user!.profileUrl!),
                      )
                      : const CircleAvatar(
                        radius: 48,
                        child: Icon(Icons.person, size: 48),
                      ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _nameController,
              enabled: isEditing,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _emailController,
              enabled: isEditing,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              enabled: isEditing,
              obscureText: true,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordScreen(),
                  ),
                );
              },
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
              ),
              child: const Text(
                'Lupa Password?',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            if (_user?.createdAt != null)
              Text(
                'Dibuat: ${_user!.createdAt}',
                style: const TextStyle(fontSize: 14),
              ),

            const SizedBox(height: 16),

            TextField(
              controller: _bioController,
              enabled: isEditing,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              decoration: const InputDecoration(labelText: 'Bio'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(user: _user!),
                  ),
                );

                if (result == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profil berhasil diperbarui')),
                  );
                  await Future.delayed(Duration(milliseconds: 500));
                  await _loadUser();
                }
              },
              child: const Text('Edit Profil'),
            ),
          ],
        ),
      ),
    );
  }
}
