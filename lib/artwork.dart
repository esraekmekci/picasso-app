import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'artist.dart'; 
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

          if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          }

          Map<String, dynamic> details = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Image.network(artwork['image']),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artwork['name'],
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),

                      
                      Text(
                        artwork['description'] ?? 'No description available',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArtistPage(
                                  artistData: {
                                    'id': details['artist']['id'],
                                    'image': details['artist']['image'],
                                    'name': details['artist']['name'],
                                    'deathdate': details['artist']['deathdate'],
                                    'birthdate': details['artist']['birthdate'],
                                    'description': details['artist']['description']
                                  },
                                ),
                              ),
                            ),
                            child: Chip(
                              label: Text(details['artist']['name']),
                              backgroundColor: Colors.green[100],
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            artwork['year']?.toString() ?? 'Unknown Year',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Wrap(
                        spacing: 8.0,
                        children: List<Widget>.generate(details['movements'].length, (int index) {
                          return GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/movement', arguments: details['movements'][index]),
                            child: Chip(
                              label: Text(details['movements'][index]['name']),
                              backgroundColor: Colors.green[100],
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/museum', arguments: details['museum']),
                        child: Chip(
                          label: Text(details['museum']['name']),
                          backgroundColor: Colors.green[100],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Set the correct index for the current page
        onTap: (index) {
          if (index == 1) {
            // Navigate to the daily page
            Navigator.pushNamed(context, '/daily');
          } else if (index != 1) {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/discover');
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