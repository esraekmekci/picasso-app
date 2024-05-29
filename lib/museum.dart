import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:picasso/appbar.dart';
import 'package:picasso/navbar.dart';
import 'expandable_text.dart';

class MuseumPage extends StatefulWidget {
  final dynamic museumData;
  const MuseumPage({super.key, required this.museumData});

  @override
  _MuseumPageState createState() => _MuseumPageState();
}

class _MuseumPageState extends State<MuseumPage> {
  late Future<String> museumDatas;

  @override
  void initState() {
    super.initState();
    museumDatas = getMuseum();
    museumDatas.then((value){
      print(value);
    });
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
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(6, (index) {
                      return GestureDetector(
                        onTap: () {
                          // Handle artwork tap here
                        },
                        child: Card(
                          child: Container(
                            color: Colors.grey[300],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0)
    );
  }
}
