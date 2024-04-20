import 'package:flutter/material.dart';

import 'package:meetoplay/wrapper.dart';
import 'global_variables.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBlue,
          foregroundColor: white,
          titleTextStyle: TextStyle(
            fontFamily: 'Opensans',
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'Opensans',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: white,
          ),
        ),
        scaffoldBackgroundColor: lightBlue,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}
