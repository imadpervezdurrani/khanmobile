// File generated for project: ile-shop-managment-system
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Android Firebase Config (from your google-services.json)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCv_GabOlvReeSoex6x9oq9xcL1vd4_U0E',
    appId: '1:379678515839:android:4cb6e92694a7828f50954a',
    messagingSenderId: '379678515839',
    projectId: 'ile-shop-managment-system',
    storageBucket: 'ile-shop-managment-system.firebasestorage.app',
  );

  // Web Firebase Config
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCv_GabOlvReeSoex6x9oq9xcL1vd4_U0E',
    appId: '1:379678515839:web:4cb6e92694a7828f50954a',
    messagingSenderId: '379678515839',
    projectId: 'ile-shop-managment-system',
    authDomain: 'ile-shop-managment-system.firebaseapp.com',
    storageBucket: 'ile-shop-managment-system.firebasestorage.app',
  );

  // iOS Firebase Config
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCv_GabOlvReeSoex6x9oq9xcL1vd4_U0E',
    appId: '1:379678515839:ios:4cb6e92694a7828f50954a',
    messagingSenderId: '379678515839',
    projectId: 'ile-shop-managment-system',
    storageBucket: 'ile-shop-managment-system.firebasestorage.app',
    iosBundleId: 'com.mobile',
  );

  // Windows Firebase Config
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCv_GabOlvReeSoex6x9oq9xcL1vd4_U0E',
    appId: '1:379678515839:web:4cb6e92694a7828f50954a',
    messagingSenderId: '379678515839',
    projectId: 'ile-shop-managment-system',
    authDomain: 'ile-shop-managment-system.firebaseapp.com',
    storageBucket: 'ile-shop-managment-system.firebasestorage.app',
  );
}
