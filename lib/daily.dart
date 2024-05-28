import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Ensure you have the intl package installed

class ArtDetailsPage extends StatefulWidget {
  const ArtDetailsPage({super.key});

  @override
  _ArtDetailsPageState createState() => _ArtDetailsPageState();
}

class _ArtDetailsPageState extends State<ArtDetailsPage> {
  late PageController _pageController;
  late Future<List<Map<String, dynamic>>>? artworkDataList;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0); // Start from today's artwork
    artworkDataList = getArtworks();
  }

  Future<List<Map<String, dynamic>>> getArtworks() async {
    final DateTime now = DateTime.now();
    final List<Map<String, dynamic>> artworks = [];

    for (int i = 0; i <= 7; i++) { // Adjust the range as needed to include more previous days
      DateTime date = now.subtract(Duration(days: i));
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

      var snapshot = await FirebaseFirestore.instance
          .collection('artworks')
          .where('publishdate', isGreaterThanOrEqualTo: startOfDay)
          .where('publishdate', isLessThanOrEqualTo: endOfDay)
          .orderBy('publishdate')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot artwork = snapshot.docs.first;
        Map<String, dynamic> artworkInfo = artwork.data() as Map<String, dynamic>;
        DocumentReference artistRef = artworkInfo['artist'] as DocumentReference;
        DocumentReference movementRef = (artworkInfo['movement'] as List).first as DocumentReference;
        DocumentReference museumRef = artworkInfo['museum'] as DocumentReference;

        DocumentSnapshot artistSnapshot = await artistRef.get();
        DocumentSnapshot movementSnapshot = await movementRef.get();
        DocumentSnapshot museumSnapshot = await museumRef.get();

        // Format the date
        DateTime publishDate = artworkInfo['publishdate']?.toDate();
        String formattedDate = publishDate != null ? DateFormat('dd.MM.yyyy').format(publishDate) : 'Unknown';

        artworks.add({
          'id': artwork.id,
          'image': artworkInfo['image'] ?? 'Unknown',
          'name': artworkInfo['name'] ?? 'Unknown',
          'year': artworkInfo['year'] ?? 'Unknown',
          'description': artworkInfo['description'] ?? 'No description available',
          'artist': (artistSnapshot.data() as Map<String, dynamic>?),
          'movement': (movementSnapshot.data() as Map<String, dynamic>?),
          'museum': (museumSnapshot.data() as Map<String, dynamic>?),
          'formattedDate': formattedDate // Include formatted date in the return data
        });
      }
    }

    return artworks; // No need to reverse the list
  }

  Future<void> toggleFavorite(String artworkId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (doc.exists) {
      List<dynamic> favorites = doc.data()?['favorites'] ?? [];
      if (favorites.contains(artworkId)) {
        // Remove from favorites
        await userRef.update({
          'favorites': FieldValue.arrayRemove([artworkId])
        });
      } else {
        // Add to favorites
        await userRef.update({
          'favorites': FieldValue.arrayUnion([artworkId])
        });
      }
      setState(() {
        // Refresh the page to update the favorite icon
      });
    }
  }

  Future<bool> checkIfLiked(String artworkId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (doc.exists) {
      List<dynamic> favorites = doc.data()?['favorites'] ?? [];
      return favorites.contains(artworkId);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Artwork'),
        backgroundColor: Colors.grey[300],
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: artworkDataList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load art details'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Art for Today'));
          }

          List<Map<String, dynamic>> artworks = snapshot.data!;

          return PageView.builder(
            controller: _pageController,
            itemCount: artworks.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data = artworks[index];

              return Padding(
                padding: const EdgeInsets.all(15),
                child: ListView(
                  children: [
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          data['formattedDate'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Image.network(data['image']),
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Light grey background
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      padding: const EdgeInsets.all(15),
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
                              FutureBuilder<bool>(
                                future: checkIfLiked(data['id']),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Icon(Icons.favorite_border, color: Colors.red);
                                  }
                                  bool isLiked = snapshot.data ?? false;
                                  return IconButton(
                                    icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                                    color: Colors.red,
                                    onPressed: () {
                                      toggleFavorite(data['id']);
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/artist', arguments: data['artist']),
                                child: Chip(
                                  label: Text(data['artist']['name']),
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
                                  label: Text(data['museum']['name']),
                                  backgroundColor: Colors.green[100],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/movement', arguments: data['movement']),
                                child: Chip(
                                  label: Text(data['movement']['name']),
                                  backgroundColor: Colors.green[100],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
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
