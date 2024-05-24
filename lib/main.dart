import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'discover.dart';
import 'daily.dart';
import 'favorites.dart';
import 'artist.dart';
import 'museum.dart';
import 'style.dart';
import 'login.dart';
import 'signup.dart';
import 'filter.dart';

Future <void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const PicassoApp());
}

class PicassoApp extends StatelessWidget {
  const PicassoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:  LoginPage(),
      routes: {
        '/login': (context) =>  LoginPage(),
        '/signup': (context) =>  SignUpPage(),
        '/daily': (context) => const ArtDetailsPage(),
        '/discover': (context) => const DiscoverPage(),
        '/favorites': (context) => const FavoritesPage(),
        '/artist': (context) => const ArtistPage(),
        '/museum': (context) => const MuseumPage(),
        '/style': (context) => const StylePage(),
        '/filter': (context) => const FilterPage(),
      },
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:picasso/daily.dart';

// void main() {
//   runApp(const NavBar());
// }

// class NavBar extends StatelessWidget {
//   const NavBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(useMaterial3: true),
//       home: const NavigationExample(),
//     );
//   }
// }

// class NavigationExample extends StatefulWidget {
//   const NavigationExample({super.key});

//   @override
//   State<NavigationExample> createState() => _NavigationExampleState();
// }

// class _NavigationExampleState extends State<NavigationExample> {
//   int currentPageIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: NavigationBar(
//         onDestinationSelected: (int index) {
//           setState(() {
//             currentPageIndex = index;
//           });
//         },
//         indicatorColor: Colors.amber,
//         selectedIndex: currentPageIndex,
//         destinations: const <Widget>[
//           NavigationDestination(
//             selectedIcon: Icon(Icons.home),
//             icon: Icon(Icons.search),
//             label: 'Discover',
//           ),
//           NavigationDestination(
//             icon: Badge(child: Icon(Icons.notifications_sharp)),
//             label: 'Notifications',
//           ),
//           NavigationDestination(
//             icon: Badge(
//               label: Text('2'),
//               child: Icon(Icons.messenger_sharp),
//             ),
//             label: 'Messages',
//           ),
//         ],
//       ),
//       body: <Widget>[
//         const PicassoApp(),
//         const PicassoApp(),
//         const PicassoApp(),
//       ][currentPageIndex],
//     );
//   }
// }
