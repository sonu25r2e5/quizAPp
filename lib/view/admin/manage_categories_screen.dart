import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/theme.dart';
import 'package:flutter_application_1/model/category.dart';
import 'package:flutter_application_1/view/admin/add_category_screen.dart';
import 'package:flutter_application_1/view/admin/manage_quiz_screen.dart';

// Lists categories and provides add, edit, delete, and quiz navigation actions.
class ManageCategoriesScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  // Reads category documents and performs category mutations.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    // Builds a live category list from the Firestore categories collection.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          'ManageCategoriesScreen',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCategoryScreen()),
              );
            },
            icon: Icon(Icons.add_circle_outline),
            color: AppTheme.primaryColor,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _firestore.collection('categories').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'You got some error in your network i think \n please check it ',
              ),
            );
          }

          // Shows a loading state until the first snapshot is available.
          final data = snapshot.data;
          if (data == null) {
            return Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Your data is loading \n please be patients'),
                ],
              ),
            );
          }
          // Converts Firestore documents into strongly typed category models.
          final categories = data.docs
              .map((doc) => Category.fromMap(doc.id, doc.data()))
              .toList();

          // Offers a direct add action when no categories exist yet.
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: AppTheme.textPrimaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No categories has been created do insert some of quiz \n question what are you waiting for boys\n',
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddCategoryScreen(),
                        ),
                      );
                    },
                    child: Text('Just add A Category'),
                  ),
                ],
              ),
            );
          }

          // Renders each category with edit, delete, and quiz-list actions.
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (BuildContext context, index) {
              final Category category = categories[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                color: AppTheme.backgroundColor,
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: SizedBox(
                    width: 48,
                    height: 48,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      ),
                      child: Icon(Icons.quiz_rounded),
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(category.description),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: "edit",
                        child: ListTile(
                          leading: Icon(
                            Icons.edit,
                            color: AppTheme.primaryColor,
                          ),
                          title: Text("Edit"),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: "delete",
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.redAccent),
                          title: Text("Delete"),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      _handleCategoryAction(context, value, category);
                    },
                  ),
                  onTap: () {
                    // QuizListScreen(categoryId: )
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MangeQuizScreen(
                          categoryId: category.id,
                          categoryName: category.name,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleCategoryAction(
    BuildContext context,
    String action,
    Category category,
  ) async {
    // Routes the selected popup action to edit or delete behavior.
    if (action == "edit") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddCategoryScreen(category: category),
        ),
      );
    } else if (action == "delete") {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Do you want to delete Category"),
          content: Text('Are you sure you want to delete this category'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('cancel'),
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
        // Deletes the category only after explicit confirmation.
        await _firestore.collection('categories').doc(category.id).delete();
      }
    }
  }
}
