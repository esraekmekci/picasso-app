import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picasso/appbar.dart';
import 'package:picasso/navbar.dart';
import 'package:picasso/filter.dart';
import 'package:picasso/artwork.dart';
import 'package:picasso/movement.dart';
import 'package:picasso/museum.dart';
import 'package:picasso/artist.dart';

class CategoryPage extends StatefulWidget {
  final String category;

  const CategoryPage({Key? key, required this.category}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<dynamic>> items;

  @override
  void initState() {
    super.initState();
    items = fetchItems();
  }

  Future<List<dynamic>> fetchItems() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(widget.category).get();
    return snapshot.docs.map((doc) => {
      ...doc.data() as Map<String, dynamic>,
      'id': doc.id,
    }).toList();
  }

  void navigateToDetailPage(Map<String, dynamic> itemData) {
    Widget page;
    if (widget.category == 'artworks') {
      page = ArtworkDetailPage(artworkId: itemData['id']);
    } else if (widget.category == 'movements') {
      page = MovementPage(movementData: itemData);
    } else if (widget.category == 'museums') {
      page = MuseumPage(museumData: itemData);
    } else if (widget.category == 'artists') {
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
      appBar: CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FilterPage(category: widget.category),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: items,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("An error occurred: ${snapshot.error}"));
                }
                if (snapshot.data!.isEmpty) {
                  return const Center(child: Text("No items found"));
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var item = snapshot.data![index];
                    return GestureDetector(
                      onTap: () => navigateToDetailPage(item),
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
                                item['image'] != null ? item['image'] : 'assets/picaßo.png',
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
                                    padding: EdgeInsets.only(left: 8.0),  // Metne sol taraftan boşluk eklemek için
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
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}
