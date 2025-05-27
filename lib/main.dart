import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:racecar_tracker/Presentation/Pages/deals_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/home_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/login_page.dart';
import 'package:racecar_tracker/Presentation/Pages/on_boarding1.dart';
import 'package:racecar_tracker/Presentation/Pages/race_evets_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/racers_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/sponsers_screen.dart';
import 'package:racecar_tracker/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF002251),

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: DealsScreen(),
    );
  }
}
