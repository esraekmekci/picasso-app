import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picasso/appbar.dart';
import 'package:picasso/navbar.dart';
import 'package:picasso/filter.dart';
import 'package:picasso/artwork.dart';
import 'package:picasso/movement.dart';
import 'package:picasso/museum.dart';
import 'package:picasso/artist.dart';
import 'dart:async';

class CategoryPage extends StatefulWidget {
  final String category;

  const CategoryPage({Key? key, required this.category}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  StreamController<List<dynamic>> _itemsController = StreamController.broadcast();
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _allItems = []; // Store all items initially

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchItems();  // Initially fetch all items
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      _itemsController.add(_allItems);  // Show all items if search query is cleared
    } else {
      _filterItems(_searchController.text);
    }
  }

  void _fetchItems() async {
    FirebaseFirestore.instance.collection(widget.category).get().then((snapshot) {
      _allItems = snapshot.docs.map((doc) => {
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      }).toList();
      _itemsController.add(_allItems);
    }).catchError((error) {
      _itemsController.addError(error);
      print("Error fetching data: $error");
    });
  }

  void _filterItems(String query) {
    print(query);
    final filteredItems = _allItems.where((item) {
      final name = item['name'] as String;
      print(name);
      return name.toLowerCase().contains(query.toLowerCase());
    }).toList();
    print("Filtered items: $filteredItems");
    _itemsController.add(filteredItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _itemsController.close();
    super.dispose();
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
      page = Text("No detail page for this category");
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  Widget buildItemsList() {
    return StreamBuilder<List<dynamic>>(
      stream: _itemsController.stream,
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
              child: buildItemCard(item),
            );
          },
        );
      },
    );
  }

  Widget buildItemCard(Map<String, dynamic> item) {
    return Container(
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
                    controller: _searchController,
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
          Expanded(child: buildItemsList()),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}
