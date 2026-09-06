import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/category.dart';
import 'package:flutter_application_1/model/quiz.dart';
import 'package:flutter_application_1/theme/theme.dart';
import 'package:flutter_application_1/view/admin/add_quiz_screen.dart';

class MangeQuizScreen extends StatefulWidget {
  final String? categoryId;

  const new({super.key, this.categoryId});

  @override
  State<MangeQuizScreen> createState() => _MangeQuizScreenState();
}

class _MangeQuizScreenState extends State<MangeQuizScreen> {
  // firestore instance \
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String? _selectedCategoryId;
  List<Category> _categories = [];
  Category? _initialCategory;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // for fetching the categories
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final querySnapshot = await _firestore.collection("categories").get();
      final categories = querySnapshot.docs
          .map((doc) => Category.fromMap(doc.id, doc.data()))
          .toList();
      setState(() {
        _categories = categories;
        if (widget.categoryId != null) {
          _initialCategory = _categories.firstWhere(
            (element) => element.id == widget.categoryId,
            orElse: () => Category(
              id: widget.categoryId!,
              name: "Don'tknow",
              description: '',
            ),
          );
          _selectedCategoryId = _initialCategory!.id;
        }
      });
    } catch (e) {
      // SnackBar
      print('Error while fetching your categories $e');
    }
  }

  // stream
  Stream<QuerySnapshot> _getQuizStream() {
    Query query = _firestore.collection("quizzes");

    String? filterCategoryId = _selectedCategoryId ?? widget.categoryId;

    // conddition case
    if (filterCategoryId != null) {
      query = query.where("categoryId", isEqualTo: filterCategoryId);
    }

    // // another condition

    return query.snapshots();
  }

  Widget _buildTitle() {
    String? categoryId = _selectedCategoryId ?? widget.categoryId;
    if (categoryId == null) {
      return Text(
        'All Quizes available',
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('categories').doc(categoryId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text(
            "Loading....",
            style: TextStyle(fontWeight: FontWeight.bold),
          );
        }
        final category = Category.fromMap(
          categoryId,
          snapshot.data!.data() as Map<String, dynamic>,
        );

        return Text(
          category.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: _buildTitle(),
        actions: [
          IconButton(
            // QUiz app content to shows
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddQuizScreen(categoryId: widget.categoryId),
                ),
              );
            },
            icon: Icon(Icons.add_circle_outline),
            color: AppTheme.primaryColor,
          ),
        ],
      ),
      body: Column(
        children: [
          //
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                hintText: "search quizzes",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 19,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Category',
              ),
              initialValue: _selectedCategoryId,
              items: [
                DropdownMenuItem(value: null, child: Text('All Categories')),
                if (_initialCategory != null &&
                    _categories.every((c) => c.id != _initialCategory!.id))
                  DropdownMenuItem(
                    value: _initialCategory!.id,
                    child: Text(_initialCategory!.name),
                  ),

                ..._categories.map(
                  (category) => DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  ),
                ),
              ],

              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _getQuizStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('it has error'));
                }
                // if it has  a data
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  );
                }
                // final value
                final quizzes = snapshot.data!.docs
                    .map(
                      (doc) => Quiz.fromMap(doc.data() as Map<String, dynamic>),
                    )
                    .where(
                      (quiz) =>
                          _searchQuery.isEmpty ||
                          quiz.title.toLowerCase().contains(_searchQuery),
                    )
                    .toList();

                if (quizzes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          size: 54,
                          color: AppTheme.textSecondaryColor,
                        ),
                        SizedBox(height: 15),
                        Text(
                          'sorry no quizzes are available',

                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddQuizScreen(
                                  categoryId: widget.categoryId,
                                ),
                              ),
                            );
                          },
                          child: Text('Add a Quiz'),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final Quiz quiz = quizzes[index];
                    return Card(
                      margin: EdgeInsets.all(12),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.quiz_rounded),
                        ),
                        title: Text(
                          quiz.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.question_answer_outlined,
                                  size: 16,
                                  color: AppTheme.textSecondaryColor,
                                ),
                                SizedBox(width: 4),
                                Text("${quiz.questions.length} Question"),
                                SizedBox(width: 16),
                                Icon(Icons.timer_outlined, size: 16),
                                SizedBox(width: 4),
                                Text("${quiz.timeLimti} mins"),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: "edit",
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.edit,
                                  color: AppTheme.primaryColor,
                                ),
                                title: Text('Edit'),
                              ),
                            ),
                            PopupMenuItem(
                              value: "delete",
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                title: Text('Edit'),
                              ),
                            ),
                          ],
                          onSelected: (value) =>
                              _handleQuizAction(context, value, quiz),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleQuizAction(
    BuildContext context,
    String value,
    Quiz quiz,
  ) async {
    if (value == "edit") {
      // Navigator .pus(context, MaterialPageRoute(builder: ))
    } else if (value == "delete") {
      // value declaration
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.all(12),
          title: Text("Do you want to delete quiz"),
          content: Text('Are you sure you want to delete this quiz? '),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await _firestore.collection("quizzes").doc(quiz.id).delete();
      }
    }
  }
}
