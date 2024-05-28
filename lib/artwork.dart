import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArtworkDetailPage extends StatelessWidget {
  final Map<String, dynamic> artwork;

  ArtworkDetailPage({required this.artwork});

  Future<Map<String, dynamic>> fetchArtworkDetails() async {
    DocumentReference artistRef = artwork['artist'] as DocumentReference;
    List<DocumentReference> movementRefs = (artwork['movement'] as List).cast<DocumentReference>();
    DocumentReference museumRef = artwork['museum'] as DocumentReference;

    DocumentSnapshot artistSnapshot = await artistRef.get();
    List<DocumentSnapshot> movementSnapshots = await Future.wait(movementRefs.map((ref) => ref.get()));
    DocumentSnapshot museumSnapshot = await museumRef.get();

    return {
      'artist': artistSnapshot.data() as Map<String, dynamic>,
      'movements': movementSnapshots.map((snapshot) => snapshot.data() as Map<String, dynamic>).toList(),
      'museum': museumSnapshot.data() as Map<String, dynamic>,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(artwork['name'] ?? 'Artwork Detail'),
        backgroundColor: Colors.grey[300],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchArtworkDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load art details'));
          }

          Map<String, dynamic> details = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Image.asset(artwork['image']),
                SizedBox(height: 20),
                Text(
                  artwork['name'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(artwork['description'] ?? 'No description available', style: TextStyle(fontSize: 16)),
                SizedBox(height: 20),
                Text('Artist:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(details['artist']['name']),
                SizedBox(height: 20),
                Text('Movements:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0,
                  children: details['movements'].map<Widget>((movement) {
                    return Chip(
                      label: Text(movement['name']),
                      backgroundColor: Colors.green[100],
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                Text('Museum:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(details['museum']['name']),
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
