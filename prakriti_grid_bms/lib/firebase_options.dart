import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
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
        return linux;
      case TargetPlatform.fuchsia:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCRGMmN8tZ7PPW0vws9ucofYkZkY2BsUXA",
    authDomain: "prakriti-grid-bms.firebaseapp.com",
    databaseURL:
    "https://prakriti-grid-bms-default-rtdb.asia-southeast1.firebasedatabase.app",
    projectId: "prakriti-grid-bms",
    storageBucket: "prakriti-grid-bms.firebasestorage.app",
    messagingSenderId: "603012503468",
    appId: "1:603012503468:web:c82b818a78bcf05fbc8c09",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCRGMmN8tZ7PPW0vws9ucofYkZkY2BsUXA",
    appId: "1:603012503468:android:c82b818a78bcf05fbc8c09",
    messagingSenderId: "603012503468",
    projectId: "prakriti-grid-bms",
    storageBucket: "prakriti-grid-bms.firebasestorage.app",
    databaseURL:
    "https://prakriti-grid-bms-default-rtdb.asia-southeast1.firebasedatabase.app",
  );

  static const FirebaseOptions ios = android;
  static const FirebaseOptions macos = android;
  static const FirebaseOptions windows = android;
  static const FirebaseOptions linux = android;
}
