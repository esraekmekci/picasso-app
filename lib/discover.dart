import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  int _currentIndex = 0;
  Future<List<Artwork>>? artworks;
  Future<List<Artist>>? artists;
  Future<List<Movement>>? movements;
  Future<List<Museum>>? museums;

  @override
  void initState() {
    super.initState();
    artworks = fetchArtworks();
    artists = fetchArtists();
    movements = fetchMovements();
    museums = fetchMuseums();
  }
Future<List<Museum>> fetchMuseums() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('museums').get();
  return snapshot.docs.map((doc) => Museum.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
}

  Future<List<Artwork>> fetchArtworks() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('artworks').get();
    return snapshot.docs.map((doc) => Artwork.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  Future<List<Artist>> fetchArtists() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('artists').get();
    return snapshot.docs.map((doc) => Artist.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  Future<List<Movement>> fetchMovements() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('movements').get();
    return snapshot.docs.map((doc) => Movement.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => Navigator.pushNamed(context, '/filter'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.shuffle),
                    onPressed: () {
                      // Implement shuffle functionality here
                    },
                  ),
                ],
              ),
            ),
            _buildSection(title: 'Artworks', futureData: artworks),
            _buildSection(title: 'Artists', futureData: artists),
            _buildSection(title: 'Movements', futureData: movements),
            _buildSection(title: 'Museums', futureData: museums),

          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() => _currentIndex = index);
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

  Widget _buildSection({required String title, required Future<List<dynamic>>? futureData}) {
    return FutureBuilder<List<dynamic>>(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var item = snapshot.data![index];
                  return GestureDetector(
                    onTap: () => navigateToDetailPage(context, item, title),
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(item.imageUrl),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void navigateToDetailPage(BuildContext context, dynamic item, String title) {
    String route = '/';
    switch (title.toLowerCase()) {
      case 'artworks':
        route = '/daily'; // Ensure you have a route set up for this in your app
        break;
      case 'artists':
        route = '/artist'; // Adjust as necessary for your route configuration
        break;
      case 'movements':
        route = '/movement'; // Adjust as necessary for your route configuration
        break;
      case 'museums':
        route = '/museum'; // Adjust as necessary for your route configuration
        break;
    }
    Navigator.pushNamed(context, route, arguments: item);
  }
}

class Artwork {
  final String id;
  final String imageUrl;

  Artwork({required this.id, required this.imageUrl});

  factory Artwork.fromMap(Map<String, dynamic> data, String id) {
    return Artwork(
      id: id,
      imageUrl: data['image'] ?? '',
    );
  }
}

class Artist {
  final String id;
  final String imageUrl;

  Artist({required this.id, required this.imageUrl});

  factory Artist.fromMap(Map<String, dynamic> data, String id) {
    return Artist(
      id: id,
      imageUrl: data['image'] ?? '',
    );
  }
}

class Movement {
  final String id;
  final String imageUrl;

  Movement({required this.id, required this.imageUrl});

  factory Movement.fromMap(Map<String, dynamic> data, String id) {
    return Movement(
      id: id,
      imageUrl: data['image'] ?? '',
    );
  }
}

class Museum {
  final String id;
  final String imageUrl;

  Museum({required this.id, required this.imageUrl});

  factory Museum.fromMap(Map<String, dynamic> data, String id) {
    return Museum(
      id: id,
      imageUrl: data['image'] ?? '',
    );
  }
}