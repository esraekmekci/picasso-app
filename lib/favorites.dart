import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:picasso/navbar.dart';
import 'login.dart';
import 'artwork.dart';
import 'main.dart'; // Import the main file to access routeObserver

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with TickerProviderStateMixin, RouteAware {
  final int _currentIndex = 2;
  late TabController _tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the current route has been popped off, and the user returns to this route
    setState(() {
      // Trigger a rebuild to refresh the favorites list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );

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
          var userData = snapshot.data?.data() as Map<String, dynamic>?; // Safe access using '?.'
          if (userData != null) { // Check if userData is not null before using it
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
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

  Widget _buildFavoritesSection(User user, String favoriteField, String collectionName) {
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        var userData = snapshot.data?.data() as Map<String, dynamic>?; // Safe access using '?.'
        if (userData != null && userData[favoriteField] != null && userData[favoriteField].isNotEmpty) { // Check if userData is not null before using it
          List<dynamic> favoriteIds = userData[favoriteField];
          favoriteIds = favoriteIds.where((id) => id != null).toList(); // Filter out null values

          return favoriteIds.isEmpty
              ? Center(child: Text("No favorite $collectionName found."))
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(collectionName)
                      .where(FieldPath.documentId, whereIn: favoriteIds)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.all(5),
                        child: collectionName == 'museums'
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  var item = snapshot.data!.docs[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/museum', arguments: item.data());
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 5),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width * 2 / 3,
                                            height: 200,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(item['image']),
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['name'],
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  '${item['city']}, ${item['country']}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 3 / 5,
                                ),
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  var item = snapshot.data!.docs[index];
                                  return GestureDetector(
                                    onTap: () {
                                      if (collectionName == 'artworks') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ArtworkDetailPage(artworkId: item.id),
                                          ),
                                        );
                                      } else if (collectionName == 'movements') {
                                        Navigator.pushNamed(context, '/movement', arguments: item.data());
                                      } else if (collectionName == 'artists') {
                                        Navigator.pushNamed(context, '/artist', arguments: {
                                          'id': item.id, // Document id
                                          'image': item['image'],
                                          'name': item['name'],
                                          'deathdate': item['deathdate'],
                                          'birthdate': item['birthdate'],
                                          'description': item['description']
                                        });
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: NetworkImage(item['image']),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                            ),
                                            gradient: LinearGradient(
                                              colors: [Colors.black54, Colors.transparent],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                          child: Text(
                                            item['name'],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                );
        } else {
          return Center(child: Text("No favorite $collectionName found."));
        }
      } else if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else {
        return Center(child: Text("Unable to load favorite $collectionName."));
      }
    },
  );
}
}
