import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:racecar_tracker/Presentation/Pages/deals_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/home_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/login_page.dart';
import 'package:racecar_tracker/Presentation/Pages/on_boarding1.dart';
import 'package:racecar_tracker/Presentation/Pages/profile_page.dart';
import 'package:racecar_tracker/Presentation/Pages/race_evets_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/racers_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/sponsers_screen.dart';
import 'package:racecar_tracker/Presentation/Pages/track_map_screen.dart';
import 'package:racecar_tracker/firebase_options.dart';
import 'package:racecar_tracker/models/racer.dart';
import 'package:provider/provider.dart';
import 'package:racecar_tracker/Services/edit_profile_provider.dart';
import 'package:racecar_tracker/Services/event_provider.dart';
import 'package:racecar_tracker/Services/sponsor_provider.dart';
import 'package:racecar_tracker/Services/racer_provider.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase App Check
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider(
      'your-recaptcha-site-key',
    ), // Add your reCAPTCHA site key
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EditProfileProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => SponsorProvider()),
        ChangeNotifierProvider(create: (_) => RacerProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 270,
                height: 122.5,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2730),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Title and subtitle
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 18,
                        left: 16,
                        right: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 238,
                            child: Text(
                              "Exit App",
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                                height: 22 / 17,
                                letterSpacing: -0.41,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          SizedBox(
                            width: 238,
                            child: Text(
                              "Are you sure you want to exit app?",
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                height: 18 / 13,
                                letterSpacing: -0.08,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Buttons
                    Row(
                      children: [
                        // Not Now
                        SizedBox(
                          width: 134.75,
                          height: 44,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 11,
                                horizontal: 8,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(14),
                                ),
                              ),
                              foregroundColor: const Color(0xFF007AFF),
                              backgroundColor: Colors.transparent,
                              textStyle: const TextStyle(
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w400,
                                fontSize: 17,
                                letterSpacing: -0.41,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Not Now"),
                          ),
                        ),
                        // Yes
                        SizedBox(
                          width: 134.75,
                          height: 44,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 11,
                                horizontal: 8,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(14),
                                ),
                              ),
                              foregroundColor: const Color(0xFFF23943),
                              backgroundColor: Colors.transparent,
                              textStyle: const TextStyle(
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w400,
                                fontSize: 17,
                                letterSpacing: -0.41,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              SystemNavigator.pop(); // This will exit the app
                            },
                            child: const Text("Yes"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EditProfileProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => SponsorProvider()),
        ChangeNotifierProvider(create: (_) => RacerProvider()),
      ],
      child: WillPopScope(
        onWillPop: () async {
          // Show exit dialog whenever back button is pressed
          showExitDialog(context);
          return false; // Prevent default back button behavior
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            scaffoldBackgroundColor: Color(0xFF002251),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => OnBoarding1(),
            '/login': (context) => LoginPage(),
            '/home': (context) => HomeScreen(),
            '/deals': (context) => HomeScreen(initialTabIndex: 4),
          },
          onGenerateRoute: (settings) {
            // Handle any other routes
            if (settings.name == '/home') {
              return MaterialPageRoute(
                builder: (context) => HomeScreen(),
                settings: settings,
              );
            }
            if (settings.name == '/deals') {
              return MaterialPageRoute(
                builder: (context) => HomeScreen(initialTabIndex: 4),
                settings: settings,
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}
