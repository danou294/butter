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
    apiKey: 'AIzaSyCACz8mdgjzvVyRgq2jTp-RV3yhFbVkqRk',
    appId: '1:412954167340:web:1db8838a6e784c446a6989',
    messagingSenderId: '412954167340',
    projectId: 'butter-begin',
    authDomain: 'butter-begin.firebaseapp.com',
    storageBucket: 'butter-begin.firebasestorage.app',
    measurementId: 'G-WGLCMCY936',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCMz5dmP-GxaVbIHY4HXQdeWsWELXz-9vs',
    appId: '1:412954167340:android:793eead7577a30276a6989',
    messagingSenderId: '412954167340',
    projectId: 'butter-begin',
    storageBucket: 'butter-begin.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCKSuRsiWbfiRL3azF7x-kpwffIrYmGoog',
    appId: '1:412954167340:ios:5a66c422784f23e26a6989',
    messagingSenderId: '412954167340',
    projectId: 'butter-begin',
    storageBucket: 'butter-begin.firebasestorage.app',
    iosBundleId: 'com.example.butter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCKSuRsiWbfiRL3azF7x-kpwffIrYmGoog',
    appId: '1:412954167340:ios:5a66c422784f23e26a6989',
    messagingSenderId: '412954167340',
    projectId: 'butter-begin',
    storageBucket: 'butter-begin.firebasestorage.app',
    iosBundleId: 'com.example.butter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCACz8mdgjzvVyRgq2jTp-RV3yhFbVkqRk',
    appId: '1:412954167340:web:7d8f44e8904db0ba6a6989',
    messagingSenderId: '412954167340',
    projectId: 'butter-begin',
    authDomain: 'butter-begin.firebaseapp.com',
    storageBucket: 'butter-begin.firebasestorage.app',
    measurementId: 'G-Q8RK1LFYNV',
  );
}
