import 'package:flutter/material.dart';
import 'package:picasso/appbar.dart';
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
  final int _currentIndex = 0;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    movementDatas = getMovement();
    movementDatas.then((value){
      print(value);
    });
    checkIfLiked();
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
      checkIfLiked(); // Check if the artist is liked again when coming back
    });
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
    movementDatas.then((value){
    mid = value;
     });
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (doc.exists) {
      List<dynamic> favoriteMovements = doc.data()?['favoriteMovements'] ?? [];

      return favoriteMovements.contains(mid);
    }
    return false;
  }

  Future<void> toggleFavorite(String movementId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (doc.exists) {
      List<dynamic> favoriteMovements = doc.data()?['favoriteMovements'] ?? [];
      if (favoriteMovements.contains(movementId)) {
        // Remove from favorites
        await userRef.update({
          'favoriteMovements': FieldValue.arrayRemove([movementId])
        });
      } else {
        // Add to favorites
        await userRef.update({
          'favoriteMovements': FieldValue.arrayUnion([movementId])
        });
      }
      setState(() {
        isLiked = !isLiked;
      });
    }
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
      }else{
        return 'movementInfo';
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
                      Text(
                        widget.movementData['name'],
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
                                          movementDatas.then((value){
                                          toggleFavorite(value);
                                        });
                                      
                                    },
                                  );
                                },
                              )
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
