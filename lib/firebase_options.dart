
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;

      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }



  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAPgdDummr3MyYv2nQLuGLEvwKxGZ4uS_w',
    appId: '1:861511305498:android:b93fb1c39b238857b404a3',
    messagingSenderId: '861511305498',
    projectId: 'sunway-originals',
    databaseURL: 'https://sunway-originals-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'sunway-originals.appspot.com',
  );


}
