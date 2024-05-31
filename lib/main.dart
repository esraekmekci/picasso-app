import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picasso/category.dart';
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
import 'artwork.dart';
import 'admin.dart';


final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

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
      title: 'Picasßo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: GoogleFonts.quicksand().fontFamily,
      ),
      home: LoginPage(),
      navigatorObservers: [routeObserver], // Add the RouteObserver here
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/daily': (context) => const ArtDetailsPage(),
        '/discover': (context) => const DiscoverPage(),
        '/favorites': (context) => const FavoritesPage(),
        '/admin': (context) =>  AddArtworkPage(),

      },
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/artist') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => ArtistPage(artistData: args),
          );
        }
        if (settings.name == '/museum') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => MuseumPage(museumData: args),
          );
        }
        if (settings.name == '/movement') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => MovementPage(movementData: args),
          );
        }
        if (settings.name == '/artwork') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return ArtworkDetailPage(artworkId: args['artworkId']);
            },
          );
        }
        if (settings.name == '/category') {
          final args = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) {
              return CategoryPage(category: args);
            },
          );
        }
        if (settings.name == '/filter') {
          final args = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) {
              return FilterPage(category: args);
            },
          );
        }
        return null; // Returning null will cause onUnknownRoute to be called
      },
    );
  }
}

        