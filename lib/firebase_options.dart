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
    apiKey: 'AIzaSyA-q4VNUJf03goon5kdSZ2GSiyMliRBfe4',
    appId: '1:738447027733:web:f21115873ded063b0fa81c',
    messagingSenderId: '738447027733',
    projectId: 'vistr-app',
    authDomain: 'vistr-app.firebaseapp.com',
    storageBucket: 'vistr-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBMBwgvEBr7rC1EiD3oDyqubt70PMzVVEY',
    appId: '1:738447027733:android:d69466ba543e715b0fa81c',
    messagingSenderId: '738447027733',
    projectId: 'vistr-app',
    storageBucket: 'vistr-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBH8ukcpPqwBVC_ctvzrxcLQPKh43oeBFg',
    appId: '1:738447027733:ios:b600d368642b0c270fa81c',
    messagingSenderId: '738447027733',
    projectId: 'vistr-app',
    storageBucket: 'vistr-app.firebasestorage.app',
    iosBundleId: 'com.example.vistrApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBH8ukcpPqwBVC_ctvzrxcLQPKh43oeBFg',
    appId: '1:738447027733:ios:b600d368642b0c270fa81c',
    messagingSenderId: '738447027733',
    projectId: 'vistr-app',
    storageBucket: 'vistr-app.firebasestorage.app',
    iosBundleId: 'com.example.vistrApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA-q4VNUJf03goon5kdSZ2GSiyMliRBfe4',
    appId: '1:738447027733:web:a9a2ccb9b0f45a830fa81c',
    messagingSenderId: '738447027733',
    projectId: 'vistr-app',
    authDomain: 'vistr-app.firebaseapp.com',
    storageBucket: 'vistr-app.firebasestorage.app',
  );

}