import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/theme.dart';

class AddQuizScreen extends StatefulWidget {
  final String? categoryId;
  const AddQuizScreen({super.key, this.categoryId});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

// question class

class QuestionFormItem {
  // controller stes
  final TextEditingController questionControllers;
  final List<TextEditingController> optionsControllers;
  int correctOptionsIndex;

  QuestionFormItem(
    this.questionControllers,
    this.optionsControllers,
    this.correctOptionsIndex,
  );

  // dispose is used for cleaning up tthe resources that is located in your mobile because you have
  // created a element some size in mobile
  void dispose() {
    questionControllers.dispose();
    for (var element in optionsControllers) {
      element.dispose();
    }
  }
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  // all this property are used by the formfield
  // formstate is used for formfield to save and delete and reset the data that's is nothing more.
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeLimitController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final bool _isLoading = false;
  String? _selectedCategoryId;
  final List<QuestionFormItem> _questionsItem = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _addQuestion();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _titleController.dispose();
    _timeLimitController.dispose();
    for (var item in _questionsItem) {
      item.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      // for adding question
      _questionsItem.add(
        QuestionFormItem(
          TextEditingController(),
          List.generate(4, (_) => TextEditingController()),
          0,
        ),
      );
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questionsItem[index].dispose();
      _questionsItem.removeAt(index);
    });
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please select a category')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text('Add Some Quiz Question'),
      ),
    );
  }
}
