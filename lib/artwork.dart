import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Ensure you have the intl package installed
import 'package:picasso/appbar.dart';
import 'package:picasso/loading.dart';
import 'artist.dart'; // Make sure this import path is correct
import 'package:picasso/navbar.dart';
import 'main.dart'; // Import the main file to access routeObserver
import 'package:google_fonts/google_fonts.dart';

class ArtworkDetailPage extends StatefulWidget {
  final String artworkId;

  const ArtworkDetailPage({super.key, required this.artworkId});

  @override
  _ArtworkDetailPageState createState() => _ArtworkDetailPageState();
}

class _ArtworkDetailPageState extends State<ArtworkDetailPage> with RouteAware {
  late Future<Map<String, dynamic>> artworkData;
  bool isLiked = false;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    artworkData = getArtwork(widget.artworkId);
    checkIfLiked(widget.artworkId);
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
      artworkData = getArtwork(widget.artworkId);
      checkIfLiked(widget.artworkId); // Recheck if the artwork is liked
    });
  }

  Future<Map<String, dynamic>> getArtwork(String artworkId) async {
    final DocumentSnapshot artworkSnapshot = await FirebaseFirestore.instance
        .collection('artworks')
        .doc(artworkId)
        .get();

    if (!artworkSnapshot.exists) {
      throw Exception('Artwork not found');
    }

    final Map<String, dynamic> artworkInfo =
        artworkSnapshot.data() as Map<String, dynamic>;
    final DocumentReference artistRef =
        artworkInfo['artist'] as DocumentReference;
    final List<DocumentReference> movementRefs =
        (artworkInfo['movement'] as List).cast<DocumentReference>();
    final DocumentReference museumRef =
        artworkInfo['museum'] as DocumentReference;

    final DocumentSnapshot artistSnapshot = await artistRef.get();
    final List<DocumentSnapshot> movementSnapshots =
        await Future.wait(movementRefs.map((ref) => ref.get()));
    final DocumentSnapshot museumSnapshot = await museumRef.get();

    return {
      'id': artworkSnapshot.id,
      'image': artworkInfo['framedImage'] ?? 'Unknown',
      'name': artworkInfo['name'] ?? 'Unknown',
      'year': artworkInfo['year'] ?? 'Unknown',
      'description': artworkInfo['description'] ?? 'No description available',
      'artist': {
        'id': artistSnapshot.id, // Document id
        'image': artistSnapshot['image'],
        'name': artistSnapshot['name'],
        'deathdate': artistSnapshot['deathdate'],
        'birthdate': artistSnapshot['birthdate'],
        'description': artistSnapshot['description'],
      },
      'movements': movementSnapshots.map((snapshot) {
        return {
          'id': snapshot.id,
          'name': snapshot['name'],
          'description': snapshot['description'],
          'image': snapshot['image'],
        };
      }).toList(),
      'museum': {
        'id': museumSnapshot.id, // Document id
        'city': museumSnapshot['city'],
        'country': museumSnapshot['country'],
        'image': museumSnapshot['image'],
        'name': museumSnapshot['name'],
        'description': museumSnapshot['description'],
      },
    };
  }

  Future<void> toggleFavorite(String artworkId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
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
        isLiked = !isLiked;
      });
    }
  }

  Future<void> checkIfLiked(String artworkId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (doc.exists) {
      List<dynamic> favorites = doc.data()?['favorites'] ?? [];
      setState(() {
        isLiked = favorites.contains(artworkId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: artworkData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: LoadingGif());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load art details'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('Artwork not found'));
          }

          final data = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(15),
            child: ListView(
              children: [
                SizedBox(height: 10),
                Image.asset(data['image']),
                SizedBox(height: 20),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Light grey background
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                // Ensure text does not overflow and wraps to the next line
                                child: Text(
                                  data['name'],
                                  style: GoogleFonts.cormorantUpright(
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  softWrap: true, // Allow text to wrap
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color:
                                      Colors.grey[200], // Light grey background
                                  borderRadius: BorderRadius.circular(
                                      25), // Rounded corners
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 245, 228, 78)
                                          .withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: Offset(
                                          0, 1), // changes position of shadow
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArtistPage(
                                      artistData: {
                                        'id': data['artist']['id'],
                                        'image': data['artist']['image'],
                                        'name': data['artist']['name'],
                                        'deathdate': data['artist']
                                            ['deathdate'],
                                        'birthdate': data['artist']
                                            ['birthdate'],
                                        'description': data['artist']
                                            ['description']
                                      },
                                    ),
                                  ),
                                ),
                                child: Chip(
                                  label: Text(data['artist']['name']),
                                  backgroundColor: Colors.green[100],
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                data['year']?.toString() ?? 'Unknown Year',
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
                              Wrap(
                                spacing: 8.0,
                                children:
                                    data['movements'].map<Widget>((movement) {
                                  return GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                        context, '/movement',
                                        arguments: movement),
                                    child: Chip(
                                      label: Text(movement['name']),
                                      backgroundColor: Colors.green[100],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                    context, '/museum',
                                    arguments: data['museum']),
                                child: Chip(
                                  label: Text(data['museum']['name']),
                                  backgroundColor: Colors.green[100],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -15,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // Light grey background
                          borderRadius:
                              BorderRadius.circular(25), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(255, 245, 228, 78)
                                  .withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset:
                                  Offset(0, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border),
                          color: Colors.red,
                          onPressed: () {
                            toggleFavorite(data['id']);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: null),
    );
  }
}
