import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  List<String> periods = ['1960 - Now', '1900-1960', '1850-1900'];
  List<String> additionalPeriods = ['1700s', '1600s', '1500s'];
  List<String> movements = ['Renaissance', 'Contemporary', 'Modern'];
  List<String> additionalMovements = ['Futurism', 'Impressionism', 'Baroque'];
  List<String> regions = ['France', 'The Netherlands', 'Japan'];
  List<String> additionalRegions = ['Italy', 'Spain', 'Germany'];
  List<String> selectedFilters = [];

  bool showMorePeriods = false;
  bool showMoreMovements = false;
  bool showMoreRegions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filter')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Art Pieces', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            buildFilterTile('Period', periods, additionalPeriods, showMorePeriods,
                () => setState(() => showMorePeriods = !showMorePeriods)),
            buildFilterTile('Movement', movements, additionalMovements,
                showMoreMovements, () => setState(() => showMoreMovements = !showMoreMovements)),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Museums', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            buildFilterTile('Region', regions, additionalRegions, showMoreRegions,
                () => setState(() => showMoreRegions = !showMoreRegions)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 20.0),
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultsPage(selectedFilters),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[300], // Button color
                  padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 100),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                
                child: const Text('Filter'),
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
      ),
    );
  }

  Widget buildFilterTile(String title, List<String> options, List<String> additionalOptions,
      bool showMore, VoidCallback toggleShowMore) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8.0, // Spacing between chips
            runSpacing: 4.0, // Spacing between lines
            children: buildChips(options, additionalOptions, showMore),
          ),
          TextButton(onPressed: toggleShowMore, child: const Text('...')),
        ],
      ),
    );
  }

  List<Widget> buildChips(List<String> options, List<String> additionalOptions, bool showMore) {
    List<Widget> chips = List<Widget>.from(options.map((option) => FilterChip(
          label: Text(option),
          selected: selectedFilters.contains(option),
          onSelected: (bool selected) {
            setState(() {
              selected ? selectedFilters.add(option) : selectedFilters.remove(option);
            });
          },
        )));

    if (showMore) {
      chips.addAll(additionalOptions.map((option) => FilterChip(
            label: Text(option),
            selected: selectedFilters.contains(option),
            onSelected: (bool selected) {
              setState(() {
                selected ? selectedFilters.add(option) : selectedFilters.remove(option);
              });
            },
          )));
    }

    return chips;
  }
}

class ResultsPage extends StatelessWidget {
  final List<String> selectedFilters;

  const ResultsPage(this.selectedFilters, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selected Filters'),
      ),
      body: ListView(
        children: selectedFilters.map((filter) => ListTile(title: Text(filter))).toList(),
      ),
    );
  }
}
