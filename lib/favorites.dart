import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  int _currentIndex = 2; // Keep this if the bottom navigation is needed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            _buildProfileHeader(), // New method to build the profile header
            _buildSection(title: 'Favorite Artworks', itemCount: 10),
            _buildSection(title: 'Favorite Artists', itemCount: 8),
            _buildSection(title: 'Favorite Museums', itemCount: 5),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

Widget _buildProfileHeader() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return SizedBox();

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
                  radius: 40,
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder image
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData['username'], // Display the username
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(userData['email']), // Display the email
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



  Widget _buildSection({required String title, required int itemCount}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return Container(
                width: 140,
                margin: const EdgeInsets.all(8),
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: Text('$title ${index + 1}'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index != _currentIndex) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/discover');
              break;
            case 1:
              Navigator.pushNamed(context, '/daily');
              break;
            case 2:
              Navigator.pushNamed(context, '/profile'); // Assuming '/profile' is the route for this page
              break;
          }
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
    );
  }
}
