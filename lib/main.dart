import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'discover.dart';
import 'daily.dart';
import 'favorites.dart';
import 'artist.dart';
import 'museum.dart';
import 'movement.dart';
import 'login.dart';
import 'signup.dart';
import 'filter.dart';

Future<void> main() async {
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
      home: LoginPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/daily': (context) => const ArtDetailsPage(),
        '/discover': (context) => const DiscoverPage(),
        '/favorites': (context) => const FavoritesPage(),
        '/filter': (context) => const FilterPage(),
      },
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/artist') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          //print('Navigating to ArtistPage with args: $args'); // Debugging print statement
          return MaterialPageRoute(
            builder: (context) => ArtistPage(artistData: args),
          );
        }
        if (settings.name == '/museum') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          //print('Navigating to MuseumPage with args: $args'); // Debugging print statement
          return MaterialPageRoute(
            builder: (context) => MuseumPage(museumData: args),
          );
        }
        if (settings.name == '/movement') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          //print('Navigating to MovementPage with args: $args'); // Debugging print statement
          return MaterialPageRoute(
            builder: (context) => MovementPage(movementData: args),
          );
        }
        // Add more generated routes here
        return null;  // Returning null will cause onUnknownRoute to be called
      },
    );
  }
}
