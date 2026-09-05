import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/theme.dart';

class CreateQuizScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text('Create Quiz Widget'),
      ),
    );
  }
}
