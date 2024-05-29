import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picasso/appbar.dart';
import 'package:picasso/navbar.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final int _currentIndex = 0;

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: CustomAppBar(),
    body: Center( // Tüm içeriği merkeze alır
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GridView.count(
                shrinkWrap: true, // GridView'i kapsayan en küçük boyuta sığdırır
                physics: NeverScrollableScrollPhysics(), // GridView içinde kaydırmayı devre dışı bırakır
                padding: const EdgeInsets.all(20),
                crossAxisCount: 2,
                childAspectRatio: 3 / 5,
                children: <Widget>[
                  _buildCategoryCard('Artworks', 'assets/artworks.jpg'),
                  _buildCategoryCard('Artists', 'assets/artists.webp'),
                  _buildCategoryCard('Museums', 'assets/museums.jpg'),
                  _buildCategoryCard('Movements', 'assets/post-impressionism.webp'),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: CustomBottomNavBar(currentIndex: _currentIndex),
  );
}



Widget _buildCategoryCard(String title, String image) {
  return GestureDetector(
    onTap: () => navigateToCategoryPage(title),
    child: Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                  stops: [0.6, 1.0]
                ),
              ),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void navigateToCategoryPage(String category) {
  switch (category.toLowerCase()) {
    case 'artists':
      Navigator.pushNamed(context, '/category', arguments: "artists");
      break;
    case 'artworks':
      Navigator.pushNamed(context, '/category', arguments: "artworks");
      break;
    case 'museums':
      Navigator.pushNamed(context, '/category', arguments: "museums");
      break;
    case 'movements':
      Navigator.pushNamed(context, '/category', arguments: "movements");
      break;
    default:
      break;
  }
}

}
