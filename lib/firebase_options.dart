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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDdcT4cSaVpHIlzxa6ycDNFW9FYgN4b6xI',
    appId: '1:128315909385:web:fdbcf85ea79ac7c9d5dfd8',
    messagingSenderId: '128315909385',
    projectId: 'rickfeed-chicks',
    authDomain: 'rickfeed-chicks.firebaseapp.com',
    storageBucket: 'rickfeed-chicks.appspot.com',
    measurementId: 'G-SZM7L8RC9G',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBRGIga_ZmscJgN6gq9ONrkb6q6ylUvrgw',
    appId: '1:128315909385:android:7832866fa0c78d76d5dfd8',
    messagingSenderId: '128315909385',
    projectId: 'rickfeed-chicks',
    storageBucket: 'rickfeed-chicks.appspot.com',
  );
}
