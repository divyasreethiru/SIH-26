// lib/main.dart
// This is the main entry file for your Flutter app.
// STEP 1 for you (later): Add firebase_core and firebase_database packages to pubspec.yaml
// STEP 2 for you (later): Run `flutter pub get`.
// STEP 3 for you (later): Configure Firebase for your Flutter project following Firebase docs.
// Then, come back here and replace the placeholder comments where mentioned.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

// Import your pages and services
import 'models/battery_model.dart';
import 'pages/battery_page.dart';
import 'pages/load_management_page.dart';
import 'pages/cleaning_page.dart';
import 'pages/weather_page.dart';
import 'pages/about_page.dart';
import 'services/weather_service.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized before using any plugins.
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: VERY IMPORTANT
  // Replace this simple Firebase.initializeApp() with your own configuration if needed.
  // After you run `flutterfire configure` or follow Firebase docs, you will usually
  // get a generated firebase_options.dart file. Then you will do something like:
  //
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  //
  // For now, this simple call will work if your android/ios firebase is configured correctly.
  await Firebase.initializeApp(); // [web:1][web:5]

  runApp(const PrakritiGridApp());
}

class PrakritiGridApp extends StatelessWidget {
  const PrakritiGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prakriti Grid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true, // Use Material 3 style. [web:6][web:9]
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const PrakritiHome(),
    );
  }
}

class PrakritiHome extends StatefulWidget {
  const PrakritiHome({super.key});

  @override
  State<PrakritiHome> createState() => _PrakritiHomeState();
}

class _PrakritiHomeState extends State<PrakritiHome> {
  bool _started = false; // Controls whether to show welcome screen or main tabs.
  int _selectedIndex = 0; // Current bottom nav index.

  // A simple shared battery model instance that can be passed to pages if needed.
  // Right now battery pages will read directly from Firebase, but this is here for future.
  BatteryModel? _latestBatteryModel;

  // Example: Listen to battery data at a single place and share it.
  // For simplicity as a beginner project, we will just read in each page instead.
  // You can extend this later.

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // This method returns the correct page widget based on the bottom navigation index.
  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return BatteryMonitoringPage(
          onBatteryModelUpdated: (model) {
            // Receive battery model from BatteryMonitoringPage if you want to share.
            setState(() {
              _latestBatteryModel = model;
            });
          },
        );
      case 1:
        return LoadManagementPage(
          sharedBatteryModel: _latestBatteryModel,
        );
      case 2:
        return const CleaningSystemPage();
      case 3:
        return WeatherPage(
          // Create a WeatherService with your API key (you will change this later).
          weatherService: WeatherService(
            apiKey: WeatherService.openWeatherApiKeyPlaceholder,
          ),
        );
      case 4:
        return const AboutPage();
      default:
        return const BatteryMonitoringPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_started) {
      // Initial welcome screen with "Let's get started" button.
      return Scaffold(
        appBar: AppBar(
          title: const Text('Prakriti Grid'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to Prakriti Grid',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _started = true;
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        "Let's get started",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // After pressing "Let's get started", show bottom navigation with 5 tabs.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prakriti Grid'),
        centerTitle: true,
      ),
      body: _buildPage(),
      bottomNavigationBar: PrakritiBottomNav(
        currentIndex: _selectedIndex,
        onItemTapped: _onNavItemTapped,
      ),
    );
  }
}

// Reusable BottomNavigationBar widget with 5 items.
class PrakritiBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const PrakritiBottomNav({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // Needed when more than 3 items. [web:16]
      currentIndex: currentIndex,
      onTap: onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.battery_full),
          label: 'Battery',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bolt),
          label: 'Load',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.cleaning_services),
          label: 'Cleaning',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.cloud),
          label: 'Weather',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          label: 'About',
        ),
      ],
    );
  }
}
