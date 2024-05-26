import 'package:flutter/material.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});
  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}


class _DiscoverPageState extends State<DiscoverPage> {
  int _currentIndex = 0; // Set the default index to 0 for "Discover"


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,

      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(children: [Expanded(
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
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              Navigator.pushNamed(context, '/filter'); // Filtreleme sayfasına yönlendirme
            },
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: () {
              // Shuffle işlevi ekleyebilirsiniz
            },
          ),
          ],
          )

            ),
            _buildSection(title: 'Artworks', itemCount: 10),
            _buildSection(title: 'Artists', itemCount: 8),
            _buildSection(title: 'Movements', itemCount: 5),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) { // Check if the current index is different
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
                Navigator.pushNamed(context, '/favorites');
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
      ),
    );
  }

  Widget _buildSection({required String title, required int itemCount}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
}
