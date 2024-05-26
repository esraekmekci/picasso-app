import 'package:flutter/material.dart';

class ArtDetailsPage extends StatefulWidget {
  const ArtDetailsPage({super.key});
  @override
  _ArtDetailsPageState createState() => _ArtDetailsPageState();
}


class _ArtDetailsPageState extends State<ArtDetailsPage> {
  int _currentIndex = 1; // Set the default index to 1 for "Daily"
  bool _isLiked = false; // Boolean to manage like button state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: ListView(
          children: [
            Image.asset('assets/dream.png'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between elements
              children: [
                const Text(
                  'Le Rêve (The Dream)',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
                  color: Colors.red,
                  onPressed: () {
                    setState(() {
                      _isLiked = !_isLiked; // Toggle the like state
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/artist');
                  },
                  child: Chip(
                    label: const Text('Pablo Picasso'),
                    backgroundColor: Colors.green[100],
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  '1932',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Labore sunt veniam amet est. Minim nisi dolor eu ad incididunt cillum elit ex ut. Dolore exercitation nulla tempor consequat aliquip occaecat. Nisi id ipsum irure aute. Deserunt sit aute irure quis nulla eu consequat fugiat Lorem sunt magna et consequat labore. Laboris incididunt id Lorem est duis deserunt nisi dolore eiusmod culpa exercitation consectetur.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Fugiat do aliqua laboris cillum sint dolor officia adipisicing excepteur fugiat officia. Cupidatat ut elit consequat ea laborum occaecat laborum aute consectetur Lorem exercitation. Lorem anim minim officia aliquip commodo deserunt mollit. Duis deserunt quis cillum voluptate duis ipsum quis incididunt elit excepteur excepteur labore duis cillum. Reprehenderit eu minim veniam aliquip do ipsum duis do qui adipisicing aliquip ad occaecat.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/museum');
                  },
                  child: Chip(
                    label: const Text('Louvre Museum'),
                    backgroundColor: Colors.green[100],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/style');
                  },
                  child: Chip(
                    label: const Text('Cubism'),
                    backgroundColor: Colors.green[100],
                  ),
                ),
              ],
            ),
          ],
        ),
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
