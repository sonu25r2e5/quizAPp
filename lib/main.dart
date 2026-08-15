import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/theme/theme.dart';
import 'package:flutter_application_1/view/admin/admin_home_screen.dart';

void main() async {
  // binding
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
      title: 'Smart Quiz',
      theme: AppTheme.theme,
      home: AdminHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
