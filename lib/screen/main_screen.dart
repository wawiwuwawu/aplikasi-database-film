import 'package:flutter/material.dart';
import 'package:weebase/screen/main_screen/movie_list.dart';
import 'package:weebase/screen/profile/profile_screen.dart';
import 'package:weebase/screen/main_screen/wishlist_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;


  void _onNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }


  final List<Widget> _pages = [
    MovieListScreen(),
    WishlistScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar:  Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(30),
    child: Container(
      height: 70,
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
        iconSize: 26,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Movie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
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
