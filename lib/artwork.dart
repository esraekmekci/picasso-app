import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'artist.dart';

class ArtworkDetailPage extends StatefulWidget {
  final Map<String, dynamic> artwork;
  const ArtworkDetailPage({Key? key, required this.artwork}) : super(key: key);

  @override
  _ArtworkDetailPageState createState() => _ArtworkDetailPageState();
}

class _ArtworkDetailPageState extends State<ArtworkDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> fetchArtworkDetails() async {
    DocumentReference artistRef = widget.artwork['artist'] as DocumentReference;
    List<DocumentReference> movementRefs = (widget.artwork['movement'] as List).cast<DocumentReference>();
    DocumentReference museumRef = widget.artwork['museum'] as DocumentReference;

    DocumentSnapshot artistSnapshot = await artistRef.get();
    List<DocumentSnapshot> movementSnapshots = await Future.wait(movementRefs.map((ref) => ref.get()));
    DocumentSnapshot museumSnapshot = await museumRef.get();

    print(artistSnapshot.data());
    //print(artistSnapshot.id);

    widget.artwork['id'] = widget.artwork['id'] ?? artistSnapshot.id;

    return {
      'artist': {
        'id': artistSnapshot.id, // Document id
        'image': artistSnapshot['image'],
        'name': artistSnapshot['name'],
        'deathdate': artistSnapshot['deathdate'],
        'birthdate': artistSnapshot['birthdate'],
        'description': artistSnapshot['description'],
      },
      'movements': movementSnapshots.map((snapshot) => snapshot.data() as Map<String, dynamic>).toList(),
      'museum': museumSnapshot.data() as Map<String, dynamic>,
    };
  }

  Future<bool> checkIfLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await docRef.get();
    print(widget.artwork['id']);
    print(widget.artwork['name']);
    if (doc.exists) {
      List<dynamic> favoriteArtworks = doc.data()?['favorites'] ?? [];
      return favoriteArtworks.contains(widget.artwork['id']);
    }
    return false;
  }

  Future<void> toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (doc.exists) {
      List<dynamic> favoriteArtworks = doc.data()?['favorites'] ?? [];
      if (favoriteArtworks.contains(widget.artwork['id'])) {
        await docRef.update({
          'favorites': FieldValue.arrayRemove([widget.artwork['id']])
        });
      } else {
        await docRef.update({
          'favorites': FieldValue.arrayUnion([widget.artwork['id']])
        });
      }
      setState(() {
        // Refresh the page to update the favorite icon
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.artwork['name'] ?? 'Artwork Detail'),
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
                Image.asset(widget.artwork['image']),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.artwork['name'],
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          FutureBuilder<bool>(
                            future: checkIfLiked(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Icon(Icons.favorite_border, color: Colors.red);
                              }
                              bool isLiked = snapshot.data ?? false;
                              return IconButton(
                                icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                                color: Colors.red,
                                onPressed: toggleFavorite,
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        widget.artwork['description'] ?? 'No description available',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArtistPage(
                                    artistData: details['artist'],
                                  ),
                                ),
                              );
                            },
                            child: Chip(
                              label: Text(details['artist']['name']),
                              backgroundColor: Colors.green[100],
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            widget.artwork['year']?.toString() ?? 'Unknown Year',
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
