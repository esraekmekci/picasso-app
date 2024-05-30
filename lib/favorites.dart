import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:picasso/artist.dart';
import 'package:picasso/movement.dart';
import 'package:picasso/museum.dart';
import 'package:picasso/navbar.dart';
import 'login.dart';
import 'artwork.dart';
import 'main.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with RouteAware, SingleTickerProviderStateMixin {
  final int _currentIndex = 2;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void navigateToDetailPage(Map<String, dynamic> itemData, String category) {
    Widget page;
    if (category == 'artworks') {
      page = ArtworkDetailPage(artworkId: itemData['id']);
    } else if (category == 'movements') {
      page = MovementPage(movementData: itemData);
    } else if (category == 'museums') {
      page = MuseumPage(museumData: itemData);
    } else if (category == 'artists') {
      page = ArtistPage(artistData: itemData);
    } else {
      // Default to a generic detail page or an error page
      page = Text("No detail page for this category");
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Please log in to see your favorites.'));
          }

          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('Please log in to see your favorites.'));
          }

          return Column(
            children: [
              _buildProfileHeader(user),
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Artwork'),
                  Tab(text: 'Artist'),
                  Tab(text: 'Museum'),
                  Tab(text: 'Movement'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFavoritesSection(user, 'favorites', 'artworks'),
                    _buildFavoritesSection(user, 'favoriteArtists', 'artists'),
                    _buildFavoritesSection(user, 'favoriteMuseums', 'museums'),
                    _buildFavoritesSection(user, 'favoriteMovements', 'movements'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: _currentIndex),
    );
  }

  Widget _buildProfileHeader(User user) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var userData = snapshot.data?.data() as Map<String, dynamic>?; 
          if (userData != null) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.transparent,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage("assets/user.png"),
                          fit: BoxFit.contain,
                          scale: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData['username'] ?? 'Unknown',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(userData['email'] ?? 'No email available'),
                      ],
                    ),
                  )
                ],
              ),
            );
          } else {
            return const Text("No user data available");
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          return const Text("Unable to load user data");
        }
      },
    );
  }

  Widget _buildFavoritesSection(User user, String favoriteField, String collectionName) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var userData = snapshot.data?.data() as Map<String, dynamic>?; 
          if (userData != null && userData[favoriteField] != null && userData[favoriteField].isNotEmpty) {  
            List<dynamic> favoriteIds = userData[favoriteField];
            favoriteIds = favoriteIds.where((id) => id != null).toList();

            return favoriteIds.isEmpty ? Text("No favorite $collectionName found.") : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection(collectionName).where(FieldPath.documentId, whereIn: favoriteIds).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var item = snapshot.data!.docs[index]; // Assuming snapshot.data is a QuerySnapshot.
                      return GestureDetector(
                        onTap: () => navigateToDetailPage(item.data() as Map<String, dynamic>, collectionName), // Implement or replace navigateToDetailPage function accordingly.
                        child: Container(
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  item['image'] != null ? item['image'] : 'assets/picaßo.png', // Default image if 'image' key is null.
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: 50,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.6),
                                        Colors.transparent,
                                      ],
                                      stops: [0.6, 1.0],
                                    ),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        item['name'] ?? 'No Name',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );

                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  return const CircularProgressIndicator();
                }
              },
            );
          } else {
            return Text("No favorite $collectionName found.");
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          return Text("Unable to load favorite $collectionName.");
        }
      },
    );
  }
}
