import 'package:flutter/material.dart';
import 'package:meetoplay/home_page.dart';
import 'global_variables.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const HomePage(),
    );
  }
}
