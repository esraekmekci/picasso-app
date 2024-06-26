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
    apiKey: //customize,
    appId: //customize,
    messagingSenderId: //customize,
    projectId: //customize,
    authDomain: //customize,
    storageBucket: //customize,
    measurementId: //customize,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: //customize,
    appId: //customize,
    messagingSenderId: //customize,
    projectId: //customize,
    storageBucket: //customize,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: //customize,
    appId: //customize,
    messagingSenderId: //customize,
    projectId: //customize,
    storageBucket: //customize,
    iosBundleId: //customize,
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: //customize,
    appId: //customize,
    messagingSenderId: //customize,
    projectId: //customize,
    storageBucket: //customize,
    iosBundleId: //customize,
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: //customize,
    appId: //customize,
    messagingSenderId: //customize,
    projectId: //customize,
    authDomain: //customize,
    storageBucket: //customize,
    measurementId: //customize,
  );

}
