import 'package:flutter/material.dart';

class WishlistScreen extends StatelessWidget {
  final List<Map<String, dynamic>> animeList = [
    {
      "title": "Kuroko No Basket",
      "status": "Watching",
      "progress": 0.3,
      "image": "assets/kuroko.jpg",
    },
    {
      "title": "Dragon Ball Z",
      "status": "Watching",
      "progress": 0.4,
      "image": "assets/dragonball.jpg",
    },
    {
      "title": "One Piece",
      "status": "Watching",
      "progress": 0.5,
      "image": "assets/onepiece.jpg",
    },
    {
      "title": "Samurai X",
      "status": "Watching",
      "progress": 0.2,
      "image": "assets/samurai.jpg",
    },
    {
      "title": "Naruto Shippuden",
      "status": "Watching",
      "progress": 0.7,
      "image": "assets/naruto.jpg",
    },
    {
      "title": "Fast X",
      "status": "Watching",
      "progress": 0.1,
      "image": "assets/fastx.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Anime List",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Search Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(0xFFF1E9F6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search",
                    border: InputBorder.none,
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Watching",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    itemCount: animeList.length,
                    itemBuilder: (context, index) {
                      final anime = animeList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              // child: Image.asset(
                              //   anime['image'],
                              //   width: 50,
                              //   height: 50,
                              //   fit: BoxFit.cover,
                              // ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    anime['title'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    anime['status'],
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  LinearProgressIndicator(
                                    value: anime['progress'],
                                    backgroundColor: Colors.grey.shade300,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                Icon(Icons.arrow_upward, size: 20),
                                Icon(Icons.text_fields, size: 20),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
