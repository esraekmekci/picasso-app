import 'package:flutter/material.dart';
import 'package:picasso/appbar.dart';
import 'package:picasso/navbar.dart';
import 'expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class MovementPage extends StatefulWidget {
  final dynamic movementData;
  const MovementPage({super.key, required this.movementData});

    @override
    _MovementPageState createState() => _MovementPageState();
}

class _MovementPageState extends State<MovementPage> {
  late Future<String> movementDatas;

  @override
  void initState() {
    super.initState();
    movementDatas = getMovement();
    movementDatas.then((value){
      print(value);
    });
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
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}
