import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // this is from the console store collection
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // map
  Future<Map<String, dynamic>> _fetchStatistics() async {
    final categoriesCount = await _firestore
        .collection('categories')
        .count()
        .get();

    final quizzesCount = await _firestore.collection('quizzes').count().get();

    final latestQuizzes = await _firestore
        .collection('quizzes')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    final categories = await _firestore.collection('categories').get();
    // categories data
    final categoryData = await Future.wait(
      categories.docs.map((category) async {
        final quizCount = await _firestore
            .collection("quizzes")
            .where('categoryId', isEqualTo: category.id)
            .count()
            .get();

        return {
          'id': category.id,
          'name': category.data()['name'] as String,
          'count': quizCount.count,
        };
      }),
    );
    return {
      'totalCatogries': categoriesCount.count,
      'totalQuizes': quizzesCount.count,
      'latestQuizzes': latestQuizzes.docs,
      'categoryData': categoryData,
    };
  }

  // for sformat data we make a function

  String _formatData(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStatCard(String title, String value, String Icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsetsGeometry.all(12),
        child: Column(
          children: [
            Container(
              padding: EdgeInsetsDirectional.all(12),

              decoration: BoxDecoration(
                color: color.withValues(green: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('hi hellow')),
      body: Center(child: Text('data')),
    );
  }
}
