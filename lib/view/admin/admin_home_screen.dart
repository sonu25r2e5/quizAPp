import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/theme.dart';
import 'package:flutter_application_1/view/admin/categoryStatisc.dart';
import 'package:flutter_application_1/view/admin/create_quiz_screen.dart';
import 'package:flutter_application_1/view/admin/manage_categories_screen.dart';
import 'package:flutter_application_1/view/admin/manage_quiz_screen.dart';
import 'package:flutter_application_1/view/admin/recentActivites.dart';

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
        // for getting the data from fire store we use this.
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // for building statecard
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsetsGeometry.all(12),
        child: Column(
          children: [
            Container(
              padding: EdgeInsetsDirectional.all(20),
              decoration: BoxDecoration(
                color: color.withValues(green: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 25),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashBoard(
    BuildContext context,
    String title,
    VoidCallback onTap,
    IconData icon,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsetsGeometry.all(20),
          child: Container(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor, size: 12),
                ),
                SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,

        title: Text(
          'Admin DashBoard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _fetchStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('error has occured sorry for loss'));
          }
          final Map<String, dynamic> stats = snapshot.data!;
          final List<dynamic> categoryData = stats['categoryData'];
          final List<QueryDocumentSnapshot> latestQuizzes =
              stats['latestQuizzes'];
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "Welcome Back admin",
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Here's your quiz sample you been taken on",
                    style: TextStyle(
                      fontSize: 17,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Categories',
                          stats['totalCatogries'].toString(),
                          Icons.category_outlined,
                          AppTheme.secondaryColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Total Quizzes',
                          stats['totalQuizes'].toString(),
                          Icons.quiz_rounded,
                          AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  categoryStatistics(categoryData),
                  SizedBox(height: 24),
                  recentlyActivites(latestQuizzes, _formatDate),
                  SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: EdgeInsetsGeometry.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.pie_chart_rounded,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Quick Actions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          GridView.count(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                            crossAxisSpacing: 16,
                            crossAxisCount: 2,
                            children: [
                              _buildDashBoard(context, 'CreateQuiz', () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateQuizScreen(),
                                  ),
                                );
                              }, Icons.add_rounded),
                              _buildDashBoard(context, 'Manage_Quizzes', () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MangeQuizScreen(),
                                  ),
                                );
                              }, Icons.quiz_rounded),
                              _buildDashBoard(
                                context,
                                'Manages_Categories',
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ManageCategoriesScreen(),
                                    ),
                                  );
                                },
                                Icons.category_rounded,
                              ),
                            ],
                          ),

                          // listview
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
