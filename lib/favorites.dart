import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}


class _FavoritesPageState extends State<FavoritesPage> {
  int _currentIndex = 2; // Set the default index to 2 for "Favorites"


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.grey[300],
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Favorites Page Content'),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) { // Check if the current index is different
            setState(() {
              _currentIndex = index;
            });
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/discover');
                break;
              case 1:
                Navigator.pushNamed(context, '/daily');
                break;
              case 2:
                Navigator.pushNamed(context, '/favorites');
                break;
            }
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.panorama_horizontal_select_rounded),
            label: 'Daily',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
