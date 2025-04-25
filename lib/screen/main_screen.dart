import 'package:flutter/material.dart';
import 'package:flutter_application_1/screen/movie_list.dart';
import 'package:flutter_application_1/screen/profile_screen.dart';
import 'package:flutter_application_1/screen/wishlist_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  // int _selectedIndex = 0;

  void _onNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Contoh konten halaman (untuk demo saja)
  final List<Widget> _pages = [
    MovieListScreen(),
    WishlistScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      extendBody: true, // Biar nav bar bisa melayang di atas body
      body: _pages[_currentIndex],
      bottomNavigationBar:  Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0), // Lebih rapat ke layar
  child: ClipRRect(
    borderRadius: BorderRadius.circular(30),
    child: Container(
      height: 70, // <<< Atur tinggi navbar di sini
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        iconSize: 26, // <<< Ukuran icon
        selectedFontSize: 14, // <<< Ukuran teks aktif
        unselectedFontSize: 12, // <<< Ukuran teks tidak aktif
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Movie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    ),
  ),
),
  
    );
  }
}
