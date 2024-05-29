import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:picasso/navbar.dart';
import 'login.dart';
import 'artwork.dart';
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final int _currentIndex = 2; // Keep this if the bottom navigation is needed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              // Navigate to the login page immediately after logging out
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );

              // Show a SnackBar after navigating to the login page
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("You have successfully logged out"),
                    duration: Duration(seconds: 2),
                  ),
                );
              });
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                _buildProfileHeader(user),
                _buildFavoritesSection(user, 'Artworks', 'favorites', 'artworks'),
                _buildFavoritesSection(user, 'Museums', 'favoriteMuseums', 'museums'),
                _buildFavoritesSection(user, 'Movements', 'favoriteMovements', 'movements'),
                _buildFavoritesSection(user, 'Artists', 'favoriteArtists', 'artists'),
              ],
            ),
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
          var userData = snapshot.data?.data() as Map<String, dynamic>?;  // Safe access using '?.'
          if (userData != null) {  // Check if userData is not null before using it
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40, // Keep the avatar size
                    backgroundColor: Colors.transparent, // Optional: Set background color if needed
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage("assets/user.png"),
                          fit: BoxFit.contain, // This will make sure the image is scaled down to fit inside the circle
                          scale: 1.5, // Adjust the scale to make image smaller inside the CircleAvatar
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData['username'] ?? 'Unknown', // Display the username
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(userData['email'] ?? 'No email available'), // Display the email
                      ],
                    ),
                  )
                ],
              ),
            );
          } else {
            return Text("No user data available");
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          return Text("Unable to load user data");
        }
      },
    );
  }

  Widget _buildFavoritesSection(User user, String title, String favoriteField, String collectionName) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var userData = snapshot.data?.data() as Map<String, dynamic>?;  // Safe access using '?.'
          if (userData != null && userData[favoriteField] != null && userData[favoriteField].isNotEmpty) {  // Check if userData is not null before using it
            List<dynamic> favoriteIds = userData[favoriteField];
            favoriteIds = favoriteIds.where((id) => id != null).toList(); // Filter out null values

            return favoriteIds.isEmpty ? Text("No favorite $collectionName found.") : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection(collectionName).where(FieldPath.documentId, whereIn: favoriteIds).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        
                      ),
                      SizedBox(
                        height: 200, // Add this to make sure the ListView.builder has a height constraint
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var item = snapshot.data!.docs[index];
                            return GestureDetector(
                              onTap: () {
                                if (collectionName == 'artworks') {
                                  Navigator.pushNamed(context, '/artwork', arguments: item.data());
                                } else if (collectionName == 'museums') {
                                  Navigator.pushNamed(context, '/museum', arguments: item.data());
                                } else if (collectionName == 'movements') {
                                  Navigator.pushNamed(context, '/movement', arguments: item.data());
                                } else if (collectionName == 'artists') {
                                  Navigator.pushNamed(context, '/artist', arguments: {
                                  'id': item.id, // Document id
                                  'image': item['image'],
                                  'name': item['name'],
                                  'deathdate': item['deathdate'],
                                  'birthdate': item['birthdate'],
                                  'description': item['description']});
                                }
                              },
                              child: Container(
                                width: 140,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(item['image']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                alignment: Alignment.center,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  return CircularProgressIndicator();
                }
              },
            );
          } else {
            return Text("No favorite $collectionName found.");
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          return Text("Unable to load favorite $collectionName.");
        }
      },
    );
  }

}