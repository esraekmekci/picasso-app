import 'package:picasso/navbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:picasso/appbar.dart';
import 'expandable_text.dart';
import 'artwork.dart';
import 'main.dart'; // Import the main file to access routeObserver
import 'dart:async';

class ArtistPage extends StatefulWidget {
  final Map<String, dynamic> artistData;
  const ArtistPage({super.key, required this.artistData});

  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> with RouteAware {
  late Future<List<Map<String, dynamic>>>? artworkDataList;
  late Future<String> artistDatas;
  final int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    artistDatas = getArtist();
    artistDatas.then((value) {
      print(value);
    });
    if (widget.artistData['id'] != null && widget.artistData['id'].isNotEmpty) {
      artworkDataList = getArtworksByArtist(widget.artistData['id']);
    } else {
      print("Artist ID is empty or null");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the current route has been popped off, and the user returns to this route
    setState(() {
      artistDatas = getArtist();
      checkIfLiked(); // Check if the artist is liked again when coming back
    });
  }

  Future<bool> checkIfLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    String aid = '';
    await artistDatas.then((value) {
      aid = value;
    });
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (doc.exists) {
      List<dynamic> favoriteArtists = doc.data()?['favoriteArtists'] ?? [];
      return favoriteArtists.contains(aid);
    }
    return false;
  }

  Future<String> getArtist() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('artists')
        .where('name', isEqualTo: widget.artistData['name'])
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      DocumentSnapshot artist = snapshot.docs.first;
      print(artist.id);
      return artist.id;
    } else {
      return 'artistInfo';
    }
  }

  Future<void> toggleFavorite(String artistId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (doc.exists) {
      List<dynamic> favoriteArtists = doc.data()?['favoriteArtists'] ?? [];
      if (favoriteArtists.contains(artistId)) {
        await userRef.update({
          'favoriteArtists': FieldValue.arrayRemove([artistId])
        });
      } else {
        await userRef.update({
          'favoriteArtists': FieldValue.arrayUnion([artistId])
        }); 
      }
      setState(() {});
    }
  }

  Future<List<Map<String, dynamic>>> getArtworksByArtist(String artistId) async {
    if (artistId.isEmpty) {
      print('Artist ID is empty');
      return [];
    }

    DocumentReference artistRef = FirebaseFirestore.instance.collection('artists').doc(artistId);

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('artworks')
          .where('artist', isEqualTo: artistRef)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No artworks found for artist');
        return [];
      }

      final artworks = snapshot.docs.map((doc) {
        print('Artwork found: ${doc.data()}');
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>
        };
      }).toList();

      return artworks;
    } catch (error) {
      print('Error fetching artworks: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime birthDate = DateTime.fromMillisecondsSinceEpoch(
      (widget.artistData['birthdate']?.seconds ?? 0) * 1000,
    );
    DateTime deathDate = DateTime.fromMillisecondsSinceEpoch(
      (widget.artistData['deathdate']?.seconds ?? 0) * 1000,
    );

    String formattedBirthDate = DateFormat('dd MMM yyyy').format(birthDate);
    String formattedDeathDate = DateFormat('dd MMM yyyy').format(deathDate);
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(widget.artistData['image'] ?? '', width: double.infinity, height: 300, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child:Text(
                          widget.artistData['name'] ?? 'Unknown Artist',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                        ), 
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
                            onPressed: () {
                              artistDatas.then((value) {
                                toggleFavorite(value);
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$formattedBirthDate - $formattedDeathDate',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ExpandableTextWidget(text: widget.artistData['description'] ?? 'No description available'),
                  const SizedBox(height: 20),
                  const Text(
                    'Artworks',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: artworkDataList,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Failed to load artworks: ${snapshot.error}'));
                      }
                      if (snapshot.data == null || snapshot.data!.isEmpty) {
                        return Center(child: Text('No artworks available'));
                      }

                      List<Map<String, dynamic>> artworks = snapshot.data!;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), // Prevents scrolling within the GridView
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,  // Adjusted for better display
                        ),
                        itemCount: artworks.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> artwork = artworks[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArtworkDetailPage(artworkId: artwork['id']),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(artwork['image']),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: _currentIndex),
    );
  }
}
