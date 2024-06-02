//import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:picasso/appbar.dart';
import 'package:picasso/loading.dart';
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
      appBar: CustomAppBar(isFavoritesPage: true), // Add isFavoritesPage parameter to CustomAppBar(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingGif();
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
                  Tab(text: 'Movement'),
                  Tab(text: 'Museum'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFavoritesSection(user, 'favorites', 'artworks'),
                    _buildFavoritesSection(user, 'favoriteArtists', 'artists'),
                    _buildFavoritesSection(user, 'favoriteMovements', 'movements'),
                    _buildFavoritesSection(user, 'favoriteMuseums', 'museums'),
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
        
          return Center( // Merkeze almak için Center widget'ını kullan
          
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _showIconSelectionDialog(context, user.uid),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage(userData['icon'] ?? "assets/user1.png"),
                  ),
                ),
                SizedBox(height: 10), // Dikey boşluk
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        userData['username'] ?? 'Unknown',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () {
                        Navigator.pushNamed(context, '/settings'); // Ayarlar sayfasına yönlendirme
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10), // Dikey boşluk
                
              ],
            ),
          );
        } else {
          return Text("No user data available");
        }
      } else if (snapshot.connectionState == ConnectionState.waiting) {
        return LoadingGif();
      } else {
        return Text("Unable to load user data");
      }
    },
  );
}


  void _showIconSelectionDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("select an icon"),
          content: Container(
            width: double.minPositive, // Diyalogun genişliğini sınırla
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: 6, // Toplam ikon sayısı
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Bir satırda gösterilecek ikon sayısı
                crossAxisSpacing: 10, // Yatay boşluk
                mainAxisSpacing: 10, // Dikey boşluk
                childAspectRatio: 1, // İkonların boy/en oranı
              ),
              itemBuilder: (context, index) {
                String iconName = 'assets/user${index + 1}.png';
                return GestureDetector(
                  onTap: () {
                    _updateUserIcon(iconName, userId);
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(iconName, width: 50, height: 50),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }


  Future<void> _updateUserIcon(String iconName, String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'icon': iconName,
    });
    setState(() {});
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
                                      Navigator.pushNamed(context, '/museum', arguments: {
                                        'id': item.id, // Document id
                                        'city': item['city'],
                                        'country': item['country'],
                                        'image': item['image'],
                                        'name': item['name'],
                                        'description': item['description'],
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 5),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width * 2.4 / 5,
                                            height: 150,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage(item['image']),
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
                                  childAspectRatio: 4 / 5,
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
                                        Navigator.pushNamed(context, '/movement', arguments: 
                                          {
                                            'id': item.id,
                                            'name': item['name'],
                                            'description': item['description'],
                                            'image': item['image'],
                                          });
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
                                        borderRadius: BorderRadius.circular(13),
                                        image: DecorationImage(
                                          image: AssetImage(item['image']),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: Align(
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
                                              bottomLeft: Radius.circular(13),
                                              bottomRight: Radius.circular(13),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: EdgeInsets.only(left: 6.0),
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
                                    ),
                                  );
                                },
                              ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else {
                      return Center(child: LoadingGif());
                    }
                  },
                );
        } else {
          return Center(child: Text("No favorite $collectionName found."));
        }
      } else if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: LoadingGif());
      } else {
        return Center(child: Text("Unable to load favorite $collectionName."));
      }
    },
  );
}
}
