import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/theme.dart';

// Placeholder screen for the dashboard's create-quiz quick action.
class CreateQuizScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    // Builds the screen scaffold and its app bar.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text('Create Quiz Widget'),
      ),
    );
  }
}
