import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:picasso/appbar.dart';
import 'expandable_text.dart';
import 'artwork.dart'; // Yeni oluşturduğumuz sayfanın dosya yolunu ekliyoruz
import 'dart:async';
class ArtistPage extends StatefulWidget {
  final Map<String, dynamic> artistData;
  const ArtistPage({super.key, required this.artistData});

  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  late Future<List<Map<String, dynamic>>>? artworkDataList;
  late Future<String> artistDatas;

  @override
  void initState() {
    super.initState();
    artistDatas = getArtist();
    artistDatas.then((value){
      print(value);
    });
    if (widget.artistData['id'] != null && widget.artistData['id'].isNotEmpty) {
      artworkDataList = getArtworksByArtist(widget.artistData['id']);
    } else {
      print("Artist ID is empty or null");
    }///burası bos geliyo widget.artistData['id'] yerine artistDatas 
  }



  Future<bool> checkIfLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    String aid = '';
    artistDatas.then((value){
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
      }else{
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
        // Remove from favorites
        await userRef.update({
          'favoriteArtists': FieldValue.arrayRemove([artistId])
        });
      } else {
        // Add to favorites
        await userRef.update({
          'favoriteArtists': FieldValue.arrayUnion([artistId])
        });
      }
      setState(() {
        
      });
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
        return doc.data() as Map<String, dynamic>;
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

    // Format the DateTime to a readable string
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
                      Text(
                        widget.artistData['name'] ?? 'Unknown Artist',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
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
                                          artistDatas.then((value){
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
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        itemCount: artworks.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> artwork = artworks[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArtworkDetailPage(artwork: artwork),
                                ),
                              );
                            },
                            child: Container(
                              width: 140,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(artwork['image']),
                                  fit: BoxFit.contain,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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