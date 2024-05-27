import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArtDetailsPage extends StatefulWidget {
  const ArtDetailsPage({super.key});
  @override
  _ArtDetailsPageState createState() => _ArtDetailsPageState();
}

class _ArtDetailsPageState extends State<ArtDetailsPage> {
  int _currentIndex = 1; // Set the default index to 1 for "Daily"
  bool _isLiked = false; // Boolean to manage like button state
  late Future<Map<String, dynamic>>? artworkData; // Future to hold the artwork data including artist's name

  @override
  void initState() {
    super.initState();
    artworkData = getArtworkDetails(); // Initialize artwork data loading
  }

  Future<Map<String, dynamic>> getArtworkDetails() async {
    final DateTime now = DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0).toUtc();
    final DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999).toUtc();

    var snapshot = await FirebaseFirestore.instance
        .collection('artworks')
        .where('publishdate', isGreaterThanOrEqualTo: startOfDay)
        .where('publishdate', isLessThanOrEqualTo: endOfDay)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('No art for today');
    }

    DocumentSnapshot artwork = snapshot.docs.first;
    Map<String, dynamic> artworkInfo = artwork.data() as Map<String, dynamic>;
    DocumentReference artistRef = artworkInfo['artist'];

    DocumentSnapshot artistSnapshot = await artistRef.get();
    artworkInfo['artistName'] = artistSnapshot.exists
        ? (artistSnapshot.data() as Map<String, dynamic>)['name']
        : 'Unknown Artist';

    return artworkInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: artworkData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load art details'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No Art for Today'));
          }

          Map<String, dynamic> data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(30.0),
            child: ListView(
              children: [
                Image.network(data['image']),
                const SizedBox(height: 10),
                Container(
                  color: Colors.grey[200],
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['name'],
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
                                _isLiked = !_isLiked;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/artist');
                        },
                        child: Chip(
                          label: Text(data['artistName']), // Display the artist's name from the future
                          backgroundColor: Colors.green[100],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        data['description'],
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
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