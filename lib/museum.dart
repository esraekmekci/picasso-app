import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:picasso/appbar.dart';
import 'package:picasso/loading.dart';
import 'package:picasso/navbar.dart';
import 'expandable_text.dart';
import 'artwork.dart';
import 'main.dart';

class MuseumPage extends StatefulWidget {
  final dynamic museumData;
  const MuseumPage({super.key, required this.museumData});

  @override
  // ignore: library_private_types_in_public_api
  _MuseumPageState createState() => _MuseumPageState();
}

class _MuseumPageState extends State<MuseumPage> with RouteAware {
  late Future<List<Map<String, dynamic>>>? artworkDataList;
  late Future<String> museumDatas;

  @override
  void initState() {
    super.initState();
    museumDatas = getMuseum();
    museumDatas.then((value) {
    });
    if (widget.museumData['id'] != null && widget.museumData['id'].isNotEmpty) {
      artworkDataList = getArtworksByMuseum(widget.museumData['id']);
    } else {
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
    });
  }

  Future<String> getMuseum() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('museums')
        .where('name', isEqualTo: widget.museumData['name'])
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      DocumentSnapshot museum = snapshot.docs.first;
      return museum.id;
    } else {
      return 'museumInfo';
    }
  }

  Future<List<Map<String, dynamic>>> getArtworksByMuseum(String museumId) async {
    if (museumId.isEmpty) {
      return [];
    }

    DocumentReference museumRef = FirebaseFirestore.instance.collection('museums').doc(museumId);

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('artworks')
          .where('museum', isEqualTo: museumRef)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      final artworks = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>
        };
      }).toList();

      return artworks;
    } catch (error) {
      return [];
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
                      Expanded(
                        child: Text(
                          widget.museumData['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                        ),
                      ),
                      // ignore: unnecessary_null_comparison
                      museumDatas != null ? FutureBuilder<String>(
                        future: museumDatas,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Icon(Icons.favorite_border, color: Colors.red);
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            return const Icon(Icons.favorite_border, color: Colors.red);
                          }
                          return FavoriteButton(museumId: snapshot.data!);
                        },
                      ) : const Icon(Icons.favorite_border, color: Colors.red),
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
                        return const Center(child: LoadingGif());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Failed to load artworks: ${snapshot.error}'));
                      }
                      if (snapshot.data == null || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No artworks available'));
                      }

                      List<Map<String, dynamic>> artworks = snapshot.data!;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), // Prevents scrolling within the GridView
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8, // Adjusted for better display
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
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: null),
    );
  }
}

class FavoriteButton extends StatefulWidget {
  final String museumId;

  const FavoriteButton({super.key, required this.museumId});

  @override
  // ignore: library_private_types_in_public_api
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
      List<dynamic> favoriteMuseums = doc.data()?['favoriteMuseums'] ?? [];
      setState(() {
        isLiked = favoriteMuseums.contains(widget.museumId);
      });
    }
  }

  Future<void> toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (doc.exists) {
      List<dynamic> favoriteMuseums = doc.data()?['favoriteMuseums'] ?? [];
      if (favoriteMuseums.contains(widget.museumId)) {
        await userRef.update({
          'favoriteMuseums': FieldValue.arrayRemove([widget.museumId])
        });
      } else {
        await userRef.update({
          'favoriteMuseums': FieldValue.arrayUnion([widget.museumId])
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
