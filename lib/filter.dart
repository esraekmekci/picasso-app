import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  List<String> movements = [];
  List<String> regions = [];
  List<String> periods = [];
  List<String> selectedFilters = [];
  Map<String, Set<String>> countryCityMap = {};
  String? selectedCountry;

  @override
  void initState() {
    super.initState();
    fetchMovements();
    fetchMuseumRegions();
    fetchPeriods();
  }

  void fetchMovements() async {
    var snapshot = await FirebaseFirestore.instance.collection('movements').get();
    setState(() {
      movements = snapshot.docs.map((doc) => doc.data()['name'] as String).toList();
    });
  }

  void fetchMuseumRegions() async {
    var snapshot = await FirebaseFirestore.instance.collection('museums').get();
    Map<String, Set<String>> tempCountryCityMap = {};
    for (var doc in snapshot.docs) {
      var data = doc.data();
      String country = data['country'];
      String city = data['city'];
      if (tempCountryCityMap.containsKey(country)) {
        tempCountryCityMap[country]!.add(city);
      } else {
        tempCountryCityMap[country] = {city};
      }
    }
    setState(() {
      countryCityMap = tempCountryCityMap;
      regions = countryCityMap.keys.toList();
    });
  }

  void fetchPeriods() {
    // Assuming you decide how to handle periods manually
    setState(() {
      periods = ['1800s', '1900s', '2000s'];  // Example static periods
    });
  }

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
            buildFilterTile('Period', periods, () {}),
            buildFilterTile('Movement', movements, () {}),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Museums', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            buildFilterTile('Country', regions, () {}),
            if (selectedCountry != null) buildCityFilter(selectedCountry!),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 20.0),
              child: ElevatedButton(
                onPressed: applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[300], // Button color
                  padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 100),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFilterTile(String title, List<String> options, VoidCallback toggleShowMore) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: options.map((option) => FilterChip(
              label: Text(option),
              selected: selectedFilters.contains(option),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    if (title == 'Country') {
                      selectedCountry = option;
                    } else {
                      selectedFilters.add(option);
                    }
                  } else {
                    if (title == 'Country') {
                      selectedCountry = null;
                    } else {
                      selectedFilters.remove(option);
                    }
                  }
                });
              },
            )).toList(),
          ),
          TextButton(onPressed: toggleShowMore, child: const Text('Show More')),
        ],
      ),
    );
  }

  Widget buildCityFilter(String country) {
    List<String> cities = countryCityMap[country]?.toList() ?? [];
    return buildFilterTile('City', cities, () {});
  }

  void applyFilters() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(selectedFilters),
      ),
    );
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
