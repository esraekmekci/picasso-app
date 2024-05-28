import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:picasso/appbar.dart';
import 'expandable_text.dart';

class ArtistPage extends StatefulWidget {
  final dynamic artistData;
  const ArtistPage({super.key, required this.artistData});

  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  bool _isLiked = false; // Boolean to manage like button state

  @override
  Widget build(BuildContext context) {
    DateTime birthDate = DateTime.fromMillisecondsSinceEpoch(
      widget.artistData['birthdate'].seconds * 1000,
    );
    DateTime deathDate = DateTime.fromMillisecondsSinceEpoch(
      widget.artistData['deathdate'].seconds * 1000,
    );

    // Format the DateTime to a readable string
    String formattedBirthDate = DateFormat('dd MMM yyyy').format(birthDate);
    String formattedDeathDate = DateFormat('dd MMM yyyy').format(deathDate);
    return Scaffold(
      appBar: CustomAppBar(),
      
      body: SingleChildScrollView(
        child: Column(
          
          children: [
            
            Image.asset(widget.artistData['image'], width: double.infinity, height: 300, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between elements
                    children: [
                      Text(
                        widget.artistData['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
                        color: Colors.red,
                        onPressed: () {
                          setState(() {
                            _isLiked = !_isLiked; // Toggle the like state
                          });
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$formattedBirthDate - $formattedDeathDate',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ExpandableTextWidget(text: widget.artistData['description']),
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

      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/discover');
              break;
            case 1:
              Navigator.pushNamed(context, '/daily');
              break;
            case 2:
              Navigator.pushNamed(context, '/favorites');
              break;
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
      )
    );
  }
}
