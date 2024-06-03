import 'package:flutter/material.dart';
import 'package:picasso/appbar.dart';
import 'package:picasso/loading.dart';
import 'package:picasso/navbar.dart';
import 'expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'artwork.dart';
import 'main.dart';

class MovementPage extends StatefulWidget {
  final dynamic movementData;
  const MovementPage({super.key, required this.movementData});

  @override
  _MovementPageState createState() => _MovementPageState();
}

class _MovementPageState extends State<MovementPage> with RouteAware {
  late Future<String> movementDatas;
  late Future<List<Map<String, dynamic>>>? artworkDataList;

  @override
  void initState() {
    super.initState();
    movementDatas = getMovement();
    movementDatas.then((value) {
      print(value);
    });
    if (widget.movementData['id'] != null && widget.movementData['id'].isNotEmpty) {
      artworkDataList = getArtworksByMovement(widget.movementData['id']);
    } else {
      print("Movement ID is empty or null");
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
      movementDatas = getMovement();
    });
  }

  Future<String> getMovement() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('movements')
        .where('name', isEqualTo: widget.movementData['name'])
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      DocumentSnapshot movement = snapshot.docs.first;
      print(movement.id);
      return movement.id;
    } else {
      return 'movementInfo';
    }
  }

  Future<List<Map<String, dynamic>>> getArtworksByMovement(String movementId) async {
    if (movementId.isEmpty) {
      print('Movement ID is empty');
      return [];
    }

    DocumentReference movementRef = FirebaseFirestore.instance.collection('movements').doc(movementId);

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('artworks')
          .where('movement', arrayContains: movementRef)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No artworks found for movement');
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
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(widget.movementData['image'], width: double.infinity, height: 300, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between elements
                    children: [
                      Expanded(
                        child: Text(
                          widget.movementData['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                        ),
                      ),
                      // ignore: unnecessary_null_comparison
                      movementDatas != null ? FutureBuilder<String>(
                        future: movementDatas,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Icon(Icons.favorite_border, color: Colors.red);
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            return const Icon(Icons.favorite_border, color: Colors.red);
                          }
                          return FavoriteButton(movementId: snapshot.data!);
                        },
                      ) : const Icon(Icons.favorite_border, color: Colors.red),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ExpandableTextWidget(text: widget.movementData['description']),
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
                        return Center(child: LoadingGif());
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
  final String movementId;

  const FavoriteButton({Key? key, required this.movementId}) : super(key: key);

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
      List<dynamic> favoriteMovements = doc.data()?['favoriteMovements'] ?? [];
      setState(() {
        isLiked = favoriteMovements.contains(widget.movementId);
      });
    }
  }

  Future<void> toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (doc.exists) {
      List<dynamic> favoriteMovements = doc.data()?['favoriteMovements'] ?? [];
      if (favoriteMovements.contains(widget.movementId)) {
        await userRef.update({
          'favoriteMovements': FieldValue.arrayRemove([widget.movementId])
        });
      } else {
        await userRef.update({
          'favoriteMovements': FieldValue.arrayUnion([widget.movementId])
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
