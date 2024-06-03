import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picasso/appbar.dart';
import 'package:picasso/loading.dart';
import 'package:picasso/navbar.dart';
import 'package:picasso/filter.dart';
import 'package:picasso/artwork.dart';
import 'package:picasso/movement.dart';
import 'package:picasso/museum.dart';
import 'package:picasso/artist.dart';
import 'dart:async';

class CategoryPage extends StatefulWidget {
  final String category;

  const CategoryPage({super.key, required this.category});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  var currentFilterState = List<String>.empty();
  var currentSelectedCountry = '';

  final StreamController<List<dynamic>> _itemsController =
      StreamController.broadcast();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allItems = []; // Store all items initially
  List<dynamic> _itemsFromFilterPage = [];

  final Map<String, dynamic> _artistsMap = {}; // Store all artists

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchData(); // Initially fetch all items and artists
  }

  void _onSearchChanged() {
    _filterItems(_searchController.text);
  }

  Future<void> _fetchData() async {
    await Future.wait([_fetchItems(), _fetchArtists()]);
    _filterItems(''); // Initially show all items
  }

  Future<void> _fetchItems() async {
    final snapshot =
        await FirebaseFirestore.instance.collection(widget.category).get();
    _allItems = snapshot.docs
        .map((doc) => {
              ...doc.data(),
              'id': doc.id,
            })
        .toList();
  }

  Future<void> _fetchArtists() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('artists').get();
    for (var doc in snapshot.docs) {
      _artistsMap[doc.id] = doc.data();
    }
  }

  void _filterItems(String query) {
    var _items = _itemsFromFilterPage.isEmpty ? _allItems : _itemsFromFilterPage;

    final filteredItems = _items.where((item) {
      final name = item['name'] as String;
      bool matchesName = name.toLowerCase().contains(query.toLowerCase());

      if (widget.category == 'artworks') {
        final DocumentReference<Object?>? artistRef =
            item['artist']! as DocumentReference?;
        if (artistRef != null) {
          final artistId = artistRef.id;
          if (_artistsMap.containsKey(artistId)) {
            final artistName = _artistsMap[artistId]['name'] as String;
            return matchesName ||
                artistName.toLowerCase().contains(query.toLowerCase());
          }
        }
      }

      return matchesName;
    }).toList();
    
    if (filteredItems.isEmpty && currentFilterState.isNotEmpty) {
      _itemsController.add([]);
    } else {
      _itemsController.add(filteredItems);
    }
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
      page = const Text("No detail page for this category");
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
          return const Center(child: LoadingGif());
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
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              item['image'] ?? 'assets/picaßo.png',
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
                  stops: const [0.6, 1.0],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    item['name'] ?? 'No Name',
                    style: const TextStyle(
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
                  icon: const Icon(Icons.shuffle),
                  onPressed: () async {
                    var allItems = _allItems;
                    var randomItem =
                        allItems[Random().nextInt(allItems.length)];
                    navigateToDetailPage(randomItem);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () async {
                    final filterResult = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FilterPage(
                          category: widget.category,
                          selectedFiltersProp: currentFilterState,
                          selectedCountryProp: currentSelectedCountry,
                        ),
                      ),
                    );
                    if (filterResult != null) {
                      currentFilterState = filterResult["selectedFilters"];
                      currentSelectedCountry = filterResult["selectedCountry"];
                      final filteredItems = filterResult["filteredNames"];
                      _itemsFromFilterPage = filteredItems != null
                          ? _allItems
                              .where(
                                  (item) => filteredItems.contains(item['name']))
                              .toList()
                          : _allItems;

                      _onSearchChanged();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(child: buildItemsList()),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: null),
    );
  }
}
