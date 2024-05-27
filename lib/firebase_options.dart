// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAPFsYHpUlY3lObYK8E7NUGtHAmfeS9rBQ',
    appId: '1:575277623254:web:8e3feb8aea8c424cad6677',
    messagingSenderId: '575277623254',
    projectId: 'picasso-app-8af58',
    authDomain: 'picasso-app-8af58.firebaseapp.com',
    storageBucket: 'picasso-app-8af58.appspot.com',
    measurementId: 'G-CH2S3FED8L',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCiEI0ZQPRmuC_tzSucBKlUD_IzPus0_1w',
    appId: '1:575277623254:android:d9f85c1ac597e99dad6677',
    messagingSenderId: '575277623254',
    projectId: 'picasso-app-8af58',
    storageBucket: 'picasso-app-8af58.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCe71VHsaEieA9FOnJID5gjdKelvrHpjeQ',
    appId: '1:575277623254:ios:5ec3bf004c1e9b6aad6677',
    messagingSenderId: '575277623254',
    projectId: 'picasso-app-8af58',
    storageBucket: 'picasso-app-8af58.appspot.com',
    iosBundleId: 'com.example.picasso',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCe71VHsaEieA9FOnJID5gjdKelvrHpjeQ',
    appId: '1:575277623254:ios:5ec3bf004c1e9b6aad6677',
    messagingSenderId: '575277623254',
    projectId: 'picasso-app-8af58',
    storageBucket: 'picasso-app-8af58.appspot.com',
    iosBundleId: 'com.example.picasso',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAPFsYHpUlY3lObYK8E7NUGtHAmfeS9rBQ',
    appId: '1:575277623254:web:8f1a6b2bbc934ff5ad6677',
    messagingSenderId: '575277623254',
    projectId: 'picasso-app-8af58',
    authDomain: 'picasso-app-8af58.firebaseapp.com',
    storageBucket: 'picasso-app-8af58.appspot.com',
    measurementId: 'G-1X2BELFWX5',
  );

}