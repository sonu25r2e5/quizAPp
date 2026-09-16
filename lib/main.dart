// Provides Firebase startup support for the application.
import 'package:firebase_core/firebase_core.dart';
// Provides Flutter's Material Design widgets and application entry points.
import 'package:flutter/material.dart';
// Contains Firebase configuration generated for each supported platform.
import 'package:flutter_application_1/firebase_options.dart';
// Defines the shared visual theme used throughout the application.
import 'package:flutter_application_1/theme/theme.dart';
// Provides the first screen shown to an administrator.
import 'package:flutter_application_1/view/admin/admin_home_screen.dart';
import 'package:flutter_application_1/view/user/home_screen.dart';

// Initializes required services before starting the Flutter application.
void main() async {
  // Ensures Flutter is ready before calling platform or plugin APIs.
  WidgetsFlutterBinding.ensureInitialized();
  // Connects Firebase using the configuration for the current platform.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Mounts the root widget and begins rendering the application.
  runApp(const MyApp());
}

// Defines the root configuration and widget tree for the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Builds the MaterialApp that supplies app-wide configuration.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Sets the application name used by the platform and tooling.
      title: 'Smart Quiz',
      // Applies the shared colors, typography, and component styling.
      theme: AppTheme.theme,
      // Opens the administrator home screen when the app starts.
      // home: HomeScreen(),
      home: HomeScreen(),
      // home: AdminHomeScreen(),
      // Removes Flutter's debug banner from the top-right corner.
      debugShowCheckedModeBanner: false,
    );
  }
}
