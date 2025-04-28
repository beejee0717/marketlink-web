import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marketlinkweb/home.dart';
import 'package:marketlinkweb/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyB4UWfGlb8m4qvfYcaI3JMSff0h7FFHQc4',
      appId: '1:1023416116583:android:33965ef7c9d74f2f1cfbc2',
      messagingSenderId: '1023416116583',
      projectId: 'marketlink-app',
    ),
  );
  runApp(const MarketLinkWeb());
}

class MarketLinkWeb extends StatelessWidget {
  const MarketLinkWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'MarketLink',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
