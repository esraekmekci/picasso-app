import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:picasso/appbar.dart';
import 'package:picasso/navbar.dart';
import 'expandable_text.dart';
import 'artwork.dart';
import 'main.dart';

class MuseumPage extends StatefulWidget {
  final dynamic museumData;
  const MuseumPage({super.key, required this.museumData});

  @override
  _MuseumPageState createState() => _MuseumPageState();
}

class _MuseumPageState extends State<MuseumPage> with RouteAware {
  late Future<List<Map<String, dynamic>>>? artworkDataList;
  late Future<String> museumDatas;
  final int _currentIndex = 0;


  @override
  void initState() {
    super.initState();
    museumDatas = getMuseum();
    museumDatas.then((value){
      print(value);
    });
    if (widget.museumData['id'] != null && widget.museumData['id'].isNotEmpty) {
      artworkDataList = getArtworksByMuseum(widget.museumData['id']);
    } else {
      print("Museum ID is empty or null");
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
      museumDatas = getMuseum();
      checkIfLiked(); // Check if the artist is liked again when coming back
    });
  }

  Future<List<Map<String, dynamic>>> getArtworksByMuseum(String museumId) async {
    if (museumId.isEmpty) {
      print('Museum ID is empty');
      return [];
    }

    DocumentReference museumRef = FirebaseFirestore.instance.collection('museums').doc(museumId);

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('artworks')
          .where('museum', isEqualTo: museumRef)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No artworks found for museum');
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

  Future<bool> checkIfLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    String mid = '';
    museumDatas.then((value){
    mid = value;
     });
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (doc.exists) {
      List<dynamic> favoriteMuseums = doc.data()?['favoriteMuseums'] ?? [];

      return favoriteMuseums.contains(mid);
    }
    return false;
  }

  Future<void> toggleFavorite(String museumId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (doc.exists) {
      List<dynamic> favoriteMuseums = doc.data()?['favoriteMuseums'] ?? [];
      if (favoriteMuseums.contains(museumId)) {
        // Remove from favorites
        await userRef.update({
          'favoriteMuseums': FieldValue.arrayRemove([museumId])
        });
      } else {
        // Add to favorites
        await userRef.update({
          'favoriteMuseums': FieldValue.arrayUnion([museumId])
        });
      }
      setState(() {
        
      });
    }
  }


  Future<String> getMuseum() async {
    var snapshot = await FirebaseFirestore.instance
          .collection('museums')
          .where('name', isEqualTo: widget.museumData['name'])
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot museum = snapshot.docs.first;
        print(museum.id);
        return museum.id;
      }else{
        return 'museumInfo';
      }
      
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(widget.museumData['image'], width: double.infinity, height: 300, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.museumData['name'],
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
                                          museumDatas.then((value){
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
                    '${widget.museumData['city']}, ${widget.museumData['country']}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ExpandableTextWidget(text: widget.museumData['description']),
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
                                  builder: (context) => ArtworkDetailPage(artworkId: artwork['id']),
                                ),
                              );
                            },
                            child: Container(
                              width: 140,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(artwork['image']),
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
      bottomNavigationBar: CustomBottomNavBar(currentIndex: _currentIndex),
    );
  }
}