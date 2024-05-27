import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArtDetailsPage extends StatefulWidget {
  const ArtDetailsPage({super.key});

  @override
  _ArtDetailsPageState createState() => _ArtDetailsPageState();
}

class _ArtDetailsPageState extends State<ArtDetailsPage> {
  late Future<Map<String, dynamic>>? artworkData;

  @override
  void initState() {
    super.initState();
    artworkData = getArtworkDetails(); // Initialize artwork data loading
  }

  Future<Map<String, dynamic>> getArtworkDetails() async {
    final DateTime now = DateTime.now();
    final DateTime startOfToday = DateTime(now.year, now.month, now.day);
    final DateTime endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    var snapshot = await FirebaseFirestore.instance
        .collection('artworks')
        .where('publishdate', isGreaterThanOrEqualTo: startOfToday)
        .where('publishdate', isLessThanOrEqualTo: endOfToday)
        .orderBy('publishdate')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('No art for today');
    }

    DocumentSnapshot artwork = snapshot.docs.first;
    Map<String, dynamic> artworkInfo = artwork.data() as Map<String, dynamic>;
    DocumentReference artistRef = artworkInfo['artist'] as DocumentReference;
    DocumentReference movementRef = (artworkInfo['movement'] as List).first as DocumentReference;
    DocumentReference museumRef = artworkInfo['museum'] as DocumentReference;

    DocumentSnapshot artistSnapshot = await artistRef.get();
    DocumentSnapshot movementSnapshot = await movementRef.get();
    DocumentSnapshot museumSnapshot = await museumRef.get();

    return {
      'image': artworkInfo['image'],
      'name': artworkInfo['name'],
      'year': artworkInfo['year'],
      'description': artworkInfo['description'],
      'artist': (artistSnapshot.data() as Map<String, dynamic>)['name'],
      'movement': (movementSnapshot.data() as Map<String, dynamic>)['name'],
      'museum': (museumSnapshot.data() as Map<String, dynamic>)['name'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Artwork'),
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
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
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Image.asset(data['image']),
                SizedBox(height: 10),
                Text(
                  data['name'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/artist', arguments: data['artist']),
                      child: Chip(
                        label: Text(data['artist']),
                        backgroundColor: Colors.green[100],
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      data['year'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  data['description'],
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/museum', arguments: data['museum']),
                    child: Chip(
                      label: Text(data['museum']),
                      backgroundColor: Colors.green[100],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/movement', arguments: data['movement']),
                  child: Chip(
                    label: Text(data['movement']),
                    backgroundColor: Colors.green[100],
                  ),
                ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
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
