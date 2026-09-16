import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/theme.dart';
import 'package:flutter_application_1/view/admin/categoryStatisc.dart';
import 'package:flutter_application_1/view/admin/create_quiz_screen.dart';
import 'package:flutter_application_1/view/admin/manage_categories_screen.dart';
import 'package:flutter_application_1/view/admin/manage_quiz_screen.dart';
import 'package:flutter_application_1/view/admin/recentActivites.dart';

// Displays the administrator dashboard and its Firestore-backed statistics.
class AdminHomeScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // Uses Firestore to load category, quiz, and activity data.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchStatistics();
  }

  Future<void> _refreshDashboard() async {
    // Replaces the future so FutureBuilder requests fresh dashboard data.
    setState(() {
      _statsFuture = _fetchStatistics();
    });
    await _statsFuture;
  }

  DateTime? _readTimestamp(dynamic value) {
    // Converts the timestamp formats that may be stored in Firestore.
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  // Loads dashboard counts, recent quizzes, and quiz totals by category.
  Future<Map<String, dynamic>> _fetchStatistics() async {
    final categoriesCount = await _firestore
        .collection('categories')
        .count()
        .get();

    final quizzesCount = await _firestore.collection('quizzes').count().get();

    final allQuizzes = await _firestore.collection('quizzes').get();
    final latestQuizzes = allQuizzes.docs.toList()
      ..sort((a, b) {
        final aDate =
            _readTimestamp((a.data())['createdAt']) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            _readTimestamp((b.data())['createdAt']) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    final categories = await _firestore.collection('categories').get();
    // Builds the quiz count for every category shown in the statistics card.
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
      'latestQuizzes': latestQuizzes.take(5).toList(),
      'categoryData': categoryData,
    };
  }

  // Formats activity dates for display in the recent activity card.
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Creates a reusable card for a dashboard summary value.
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: AppTheme.backgroundColor,
      child: Padding(
        padding: EdgeInsetsGeometry.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsetsDirectional.all(10),
              margin: EdgeInsets.only(top: 12, left: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 40),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
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
    Color color,
  ) {
    // Creates a reusable quick-action tile that navigates to an admin screen.
    return Card(
      color: AppTheme.backgroundColor,
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
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 35),
                ),
                SizedBox(height: 9),
                Text(
                  title,
                  textAlign: TextAlign.start,
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
    // Builds the dashboard, loading state, error state, and statistics view.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,

        title: Text(
          'Admin DashBoard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        color: AppTheme.primaryColor,
        child: FutureBuilder(
          future: _statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('error has occured sorry for loss'));
            }

            final Map<String, dynamic> stats = snapshot.data!;
            final List<dynamic> categoryData = stats['categoryData'];
            final List<QueryDocumentSnapshot> latestQuizzes =
                stats['latestQuizzes'];

            return SafeArea(
              child: ListView(
                padding: EdgeInsets.all(12),
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
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          stats['totalCatogries'].toString(),
                          'Total Categories',
                          Icons.category_outlined,
                          AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          stats['totalQuizes'].toString(),
                          'Total Quizzes',
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
                    color: AppTheme.backgroundColor,
                    child: Padding(
                      padding: EdgeInsetsGeometry.all(10),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                            mainAxisSpacing: 8,
                            childAspectRatio: .9,
                            crossAxisSpacing: 16,
                            crossAxisCount: 2,
                            children: [
                              _buildDashBoard(
                                context,
                                'Manage_Quizzes',
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MangeQuizScreen(),
                                    ),
                                  );
                                },
                                Icons.quiz_rounded,
                                Colors.green,
                              ),
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
                                Colors.purple,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
