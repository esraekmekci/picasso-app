import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FilterPage extends StatefulWidget {
  final String category;
  final List<String> selectedFiltersProp;
  final String? selectedCountryProp;

  const FilterPage(
      {Key? key, required this.category, required this.selectedFiltersProp, this.selectedCountryProp})
      : super(key: key);

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
  Map<String, bool> showMoreMap = {};

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  void fetchInitialData() {
    if (widget.selectedFiltersProp.isNotEmpty) {
      selectedFilters = widget.selectedFiltersProp;
    }

    selectedCountry = widget.selectedCountryProp;

    if (widget.category == 'artworks' || widget.category == 'artists') {
      fetchMovements();
      fetchPeriods();
    }
    if (widget.category == 'museums') {
      fetchMuseumRegions();
    }
    if (widget.category == 'movements') {
      fetchMovementsPeriods();
    }
  }

  void fetchMovements() async {
    var snapshot =
        await FirebaseFirestore.instance.collection('movements').get();
    setState(() {
      movements =
          snapshot.docs.map((doc) => doc.data()['name'] as String).toList();
      showMoreMap['Movement'] = false;
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
      showMoreMap['Country'] = false;
    });
  }

  void fetchPeriods() async {
    setState(() {
      periods = [
        '1500s',
        '1600s',
        '1700s',
        '1800s',
        '1900s'
      ]; // Example static periods
      showMoreMap['Period'] = false;
    });
  }

  void fetchMovementsPeriods() async {
    setState(() {
      periods = [
        '1300s',
        '1400s',
        '1500s',
        '1600s',
        '1700s',
        '1800s',
        '1900s'
      ]; // Example static periods
      showMoreMap['Period'] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Filter')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.category == 'artists' || widget.category == 'artworks' || widget.category == 'movements')
              buildFilterTile('Period', periods),
            if (widget.category == 'artworks')
              buildFilterTile('Movement', movements),
              
            if (widget.category == 'museums') ...[
              buildFilterTile('Country', regions),
              if (selectedCountry != null) buildCityFilter(selectedCountry!),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[300], // Button color
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text('Apply Filters', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: resetFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[300], // Button color
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text('Reset Filters', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget buildFilterTile(String title, List<String> options) {
  bool showMore = showMoreMap[title] ?? false;
  int itemsPerRow = (MediaQuery.of(context).size.width / 100).floor(); // Ekran genişliğine göre her satırda kaç öğe gösterileceğini belirle
  int initialDisplayCount = itemsPerRow * 2; // İlk gösterilecek öğe sayısı, iki satır

  if (widget.category == 'movements') {
    initialDisplayCount = 8; 
  }
  List<String> displayedOptions = showMore ? options : options.take(initialDisplayCount).toList();

  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: displayedOptions
              .map((option) => FilterChip(
                    label: Text(option),
                    selected: (title == 'Country' && option == selectedCountry) ||
                              (title != 'Country' && selectedFilters.contains(option)),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          if (title == 'Country') {
                            selectedCountry = option;
                            selectedFilters.clear(); // Clear city selection when a new country is selected
                          } else {
                            selectedFilters.add(option);
                          }
                        } else {
                          if (title == 'Country') {
                            selectedCountry = null;
                            selectedFilters.clear(); // Clear city selection when country selection is cleared
                          } else {
                            selectedFilters.remove(option);
                          }
                        }
                      });
                    },
                  ))
              .toList(),
        ),
        if (options.length > initialDisplayCount)
          TextButton(
            onPressed: () {
              setState(() {
                showMoreMap[title] = !showMore;
              });
            },
            child: Text(showMore ? 'Show Less' : 'Show More'),
          ),
      ],
    ),
  );
}


  Widget buildCityFilter(String country) {
    List<String> cities = countryCityMap[country]?.toList() ?? [];
    return buildFilterTile('City', cities);
  }

  void applyFilters() async {
    List<Query> queries = [];
    Query baseQuery = FirebaseFirestore.instance.collection(widget.category);

    Map<String, List<int>> periodYearRanges = {
      '1500s': [1500, 1599],
      '1600s': [1600, 1699],
      '1700s': [1700, 1799],
      '1800s': [1800, 1899],
      '1900s': [1900, 1999]
    };

    Map<String, List<int>> movementPeriodYearRanges = {
    '1300s': [1300, 1399],
    '1400s': [1400, 1499],
    '1500s': [1500, 1599],
    '1600s': [1600, 1699],
    '1700s': [1700, 1799],
    '1800s': [1800, 1899],
    '1900s': [1900, 1999]
  };


    if (widget.category == 'artworks') {
      // Filter by periods as year ranges, if any
      List<String> selectedPeriods =
          selectedFilters.where((f) => periods.contains(f)).toList();
      if (selectedPeriods.isNotEmpty) {
        for (var period in selectedPeriods) {
          if (periodYearRanges.containsKey(period)) {
            List<int> range = periodYearRanges[period]!;
            queries.add(baseQuery.where('year',
                isGreaterThanOrEqualTo: range[0], isLessThanOrEqualTo: range[1]));
          }
        }
      } else {
        // If no period is selected, add the base query as a fallback
        queries.add(baseQuery);
      }

      // Filter by selected movements
      if (selectedFilters.any((f) => movements.contains(f))) {
        var selectedMovements =
            selectedFilters.where((f) => movements.contains(f)).toList();
        var movementSnapshot = await FirebaseFirestore.instance
            .collection('movements')
            .where('name', whereIn: selectedMovements)
            .get();
        List<DocumentReference> movementReferences =
            movementSnapshot.docs.map((doc) => doc.reference).toList();

        if (movementReferences.isNotEmpty) {
          for (var i = 0; i < queries.length; i++) {
            queries[i] = queries[i]
                .where('movement', arrayContainsAny: movementReferences);
          }
        }
      }

      // Execute the queries and combine the results
      List<String> filteredArtworkNames = [];
      for (var query in queries) {
        var snapshot = await query.get();
        filteredArtworkNames.addAll(snapshot.docs
            .map((doc) {
              var data = doc.data();
              return data is Map<String, dynamic>
                  ? data['name'] as String?
                  : null;
            })
            .where((name) => name != null)
            .cast<String>()
            .toList());
      }

      // Remove duplicates, if any
      filteredArtworkNames = filteredArtworkNames.toSet().toList();

      // Navigate back and pass the filtered artwork names
      Navigator.pop(context, {
        'filteredNames': filteredArtworkNames,
        'selectedFilters': selectedFilters,
        'selectedCountry': selectedCountry
      });
    }

    if (widget.category == 'museums') {
      // Filter by selected country and city
      Query museumQuery = baseQuery;
      if (selectedCountry != null) {
        museumQuery = museumQuery.where('country', isEqualTo: selectedCountry);
      }

      if (selectedFilters.isNotEmpty) {
        museumQuery = museumQuery.where('city', whereIn: selectedFilters);
      }

      var snapshot = await museumQuery.get();
      List<String> filteredMuseumNames = snapshot.docs
          .map((doc) {
            var data = doc.data();
            return data is Map<String, dynamic> ? data['name'] as String? : null;
          })
          .where((name) => name != null)
          .cast<String>()
          .toList();

      // Remove duplicates, if any
      filteredMuseumNames = filteredMuseumNames.toSet().toList();

      // Navigate back and pass the filtered museum names
      Navigator.pop(context, {
        'filteredNames': filteredMuseumNames,
        'selectedFilters': selectedFilters,
        'selectedCountry': selectedCountry
      });
    }

    if (widget.category == 'artists') {
      Map<String, List<DateTime>> periodDateRanges = {
        '1500s': [DateTime(1500, 1, 1), DateTime(1599, 12, 31)],
        '1600s': [DateTime(1600, 1, 1), DateTime(1699, 12, 31)],
        '1700s': [DateTime(1700, 1, 1), DateTime(1799, 12, 31)],
        '1800s': [DateTime(1800, 1, 1), DateTime(1899, 12, 31)],
        '1900s': [DateTime(1900, 1, 1), DateTime(1999, 12, 31)]
      };
      // Filter by selected periods
      List<String> selectedPeriods =
      selectedFilters.where((f) => periods.contains(f)).toList();
      if (selectedPeriods.isNotEmpty) {
        for (var period in selectedPeriods) {
          if (periodDateRanges.containsKey(period)) {
            List<DateTime> range = periodDateRanges[period]!;
            queries.add(baseQuery.where('birthdate',
                isGreaterThanOrEqualTo: range[0], isLessThanOrEqualTo: range[1]));
          }
        }
      } else {
        // If no period is selected, add the base query as a fallback
        queries.add(baseQuery);
      }

      // Execute the queries and combine the results
      List<String> filteredArtistNames = [];
      for (var query in queries) {
        var snapshot = await query.get();
        filteredArtistNames.addAll(snapshot.docs
            .map((doc) {
              var data = doc.data();
              return data is Map<String, dynamic> ? data['name'] as String? : null;
            })
            .where((name) => name != null)
            .cast<String>()
            .toList());
      }

      // Remove duplicates, if any
      filteredArtistNames = filteredArtistNames.toSet().toList();

      // If no artists match the selected periods, return an empty list
      if (filteredArtistNames.isEmpty && selectedPeriods.isNotEmpty) {
        Navigator.pop(context, {
          'filteredNames': [],
          'selectedFilters': selectedFilters,
          'selectedCountry': selectedCountry
        });
        return;
      }

      // Navigate back and pass the filtered artist names
      Navigator.pop(context, {
        'filteredNames': filteredArtistNames,
        'selectedFilters': selectedFilters,
        'selectedCountry': selectedCountry
      });
    }
  if (widget.category == 'movements') {
    // Filter by selected periods
    List<String> selectedPeriods = selectedFilters.where((f) => periods.contains(f)).toList();
    if (selectedPeriods.isNotEmpty) {
      List<String> periodList = selectedPeriods.map((period) => period).toList();
      queries.add(baseQuery.where('period', arrayContainsAny: periodList));
    } else {
      // If no period is selected, add the base query as a fallback
      queries.add(baseQuery);
    }

    // Execute the queries and combine the results
    List<String> filteredMovementNames = [];
    for (var query in queries) {
      var snapshot = await query.get();
      filteredMovementNames.addAll(snapshot.docs
          .map((doc) {
            var data = doc.data();
            return data is Map<String, dynamic> ? data['name'] as String? : null;
          })
          .where((name) => name != null)
          .cast<String>()
          .toList());
    }

    // Remove duplicates, if any
    filteredMovementNames = filteredMovementNames.toSet().toList();

    // Navigate back and pass the filtered movement names
    Navigator.pop(context, {
      'filteredNames': filteredMovementNames,
      'selectedFilters': selectedFilters,
      'selectedCountry': selectedCountry
    });
  }

  }

  void resetFilters() {
    setState(() {
      selectedFilters.clear();
      selectedCountry = null;
    });
  }
}
