import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Ensure you have the intl package installed
import 'package:picasso/appbar.dart';
import 'package:picasso/loading.dart';
import 'package:picasso/navbar.dart';
import 'artist.dart';
import 'main.dart'; // Make sure this import path is correct
import 'package:google_fonts/google_fonts.dart';

class ArtDetailsPage extends StatefulWidget {
  const ArtDetailsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ArtDetailsPageState createState() => _ArtDetailsPageState();
}

class _ArtDetailsPageState extends State<ArtDetailsPage> with RouteAware {
  late PageController _pageController;
  late Future<List<Map<String, dynamic>>>? artworkDataList;
  final int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 7); // Start from today's artwork
    artworkDataList = getArtworks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
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
        List<DocumentReference> movementRefs = (artworkInfo['movement'] as List).cast<DocumentReference>();
        DocumentReference museumRef = artworkInfo['museum'] as DocumentReference;

        DocumentSnapshot artistSnapshot = await artistRef.get();
        List<DocumentSnapshot> movementSnapshots = await Future.wait(movementRefs.map((ref) => ref.get()));
        DocumentSnapshot museumSnapshot = await museumRef.get();

        // Format the date
        DateTime publishDate = artworkInfo['publishdate']?.toDate();
        // ignore: unnecessary_null_comparison
        String formattedDate = publishDate != null ? DateFormat('MMM d').format(publishDate) : 'Unknown';

        artworks.add({
          'id': artwork.id,
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
          'formattedDate': formattedDate // Include formatted date in the return data
        });
      }
    }

    return artworks.reversed.toList(); // Reverse the list to show today first
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: artworkDataList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: LoadingGif());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load art details'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Art for Today'));
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
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          margin: const EdgeInsets.only(top: 5, right: 0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(181, 255, 255, 255), // Change background color as needed
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Text(
                            data['formattedDate'],
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Image.asset(data['image']),
                    const SizedBox(height: 10),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 240, 240, 240), // Light grey background
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                          ),
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded( // Ensure text does not overflow and wraps to the next line
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
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color.fromARGB(255, 96, 137, 96), // Background color
                                      foregroundColor: Colors.white, // Text color
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    ),
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ArtistPage(
                                          artistData: {
                                            'id': data['artist']['id'],
                                            'image': data['artist']['image'],
                                            'name': data['artist']['name'],
                                            'deathdate': data['artist']['deathdate'],
                                            'birthdate': data['artist']['birthdate'],
                                            'description': data['artist']['description']
                                          },
                                        ),
                                      ),
                                    ),
                                    child: Text(data['artist']['name']),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    data['year']?.toString() ?? 'Unknown Year',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                data['description'],
                                style: const TextStyle(fontSize: 16),
                              ),
                             const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("Movements:   ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Wrap(
                                  spacing: 8.0,
                                  children: List<Widget>.generate(data['movements'].length, (int index) {
                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 96, 137, 96), // Background color
                                        foregroundColor: Colors.white, // Text color
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      ),
                                      onPressed: () => Navigator.pushNamed(context, '/movement', arguments: data['movements'][index]),
                                      child: Text(data['movements'][index]['name']),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),

                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  const Text("Museum:       ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 96, 137, 96), // Background color
                                      foregroundColor: Colors.white, // Text color
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    ),
                                    onPressed: () => Navigator.pushNamed(context, '/museum', arguments: data['museum']),
                                    child: Text(data['museum']['name']),
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
                              borderRadius: BorderRadius.circular(25), // Rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 245, 228, 78).withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 1), // changes position of shadow
                                ),
                              ],
                            ),
                            child: FavoriteButton(artworkId: data['id']),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: _currentIndex),
    );
  }
}

class FavoriteButton extends StatefulWidget {
  final String artworkId;

  const FavoriteButton({Key? key, required this.artworkId}) : super(key: key);

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    checkIfLiked();
  }

  Future<void> checkIfLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (doc.exists) {
      List<dynamic> favorites = doc.data()?['favorites'] ?? [];
      setState(() {
        isLiked = favorites.contains(widget.artworkId);
      });
    }
  }

  Future<void> toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (doc.exists) {
      List<dynamic> favorites = doc.data()?['favorites'] ?? [];
      if (favorites.contains(widget.artworkId)) {
        // Remove from favorites
        await userRef.update({
          'favorites': FieldValue.arrayRemove([widget.artworkId])
        });
      } else {
        // Add to favorites
        await userRef.update({
          'favorites': FieldValue.arrayUnion([widget.artworkId])
        });
      }
      setState(() {
        isLiked = !isLiked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
      color: Colors.red,
      onPressed: toggleFavorite,
    );
  }
}
