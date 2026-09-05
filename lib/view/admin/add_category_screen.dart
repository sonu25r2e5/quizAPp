import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/category.dart';
import 'package:flutter_application_1/theme/theme.dart';

class AddCategoryScreen extends StatefulWidget {
  final Category? category;

  const AddCategoryScreen({super.key, this.category});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  //creating a key
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // bool value
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _descriptionController = TextEditingController(
      text: widget.category?.description,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final category = widget.category;
      if (category != null) {
        final updatedCategory = category.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
        );

        await _firestore
            .collection("categories")
            .doc(category.id)
            .update(updatedCategory.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category updated successfully')),
        );
      } else {
        await _firestore
            .collection("categories")
            .add(
              Category(
                id: _firestore.collection("categories").doc().id,
                name: _nameController.text.trim(),
                description: _descriptionController.text.trim(),
                createdAt: DateTime.now(),
              ).toMap(),
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category updated successfully')),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      print("error occured: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_nameController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty) {
      return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Discard Changes'),
              content: Text('Do you want to discard changes'),
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
                  child: Text(
                    'Discard',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          title: Text(
            widget.category != null ? "edit Category" : "Add Category",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsetsGeometry.all(12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Category Detail",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "create a new Category for a organizing your quizzes",
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 20),
                      labelText: "category Name",
                      hintText: "enter Category name",
                      prefixIcon: Icon(
                        Icons.category_rounded,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    validator: (value) => value?.trim().isEmpty ?? true
                        ? "Enter Category name"
                        : null,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 20),
                      labelText: "Description",
                      hintText: "enter Description Name",
                      prefixIcon: Icon(
                        Icons.description_rounded,
                        color: AppTheme.primaryColor,
                      ),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 1,
                    validator: (value) => value?.trim().isEmpty ?? true
                        ? "Enter description name"
                        : null,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveCategory,
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.category != null
                                  ? "update Category"
                                  : "Add Category",
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
