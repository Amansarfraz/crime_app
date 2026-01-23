// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: 'AIzaSyCVQMeBli0qAimTgg5JBs5svht42hrZnUE',
        appId: '1:1013580151230:web:722a9526b8ff007960e1ef',
        messagingSenderId: '1013580151230',
        projectId: 'crime-app-4a26e',
        authDomain: 'crime-app-4a26e.firebaseapp.com',
        storageBucket: 'crime-app-4a26e.appspot.com',
        measurementId: 'G-WVS7LW5L4Y',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: 'AIzaSyCVQMeBli0qAimTgg5JBs5svht42hrZnUE',
          appId: '1:1013580151230:android:722a9526b8ff007960e1ef',
          messagingSenderId: '1013580151230',
          projectId: 'crime-app-4a26e',
          storageBucket: 'crime-app-4a26e.appspot.com',
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return FirebaseOptions(
          apiKey: 'AIzaSyCVQMeBli0qAimTgg5JBs5svht42hrZnUE',
          appId: '1:1013580151230:ios:722a9526b8ff007960e1ef',
          messagingSenderId: '1013580151230',
          projectId: 'crime-app-4a26e',
          storageBucket: 'crime-app-4a26e.appspot.com',
          iosBundleId:
              'com.example.crimeapp', // replace with your iOS bundle ID
          iosClientId: '',
          androidClientId: '',
          measurementId: 'G-WVS7LW5L4Y',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}
