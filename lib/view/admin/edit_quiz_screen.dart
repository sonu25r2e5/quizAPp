import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/question.dart';
import 'package:flutter_application_1/model/quiz.dart';
import 'package:flutter_application_1/theme/theme.dart';

class EditQuizScreen extends StatefulWidget {
  // categores vairalbe
  final Quiz quiz;

  const EditQuizScreen({super.key, required this.quiz});

  @override
  State<EditQuizScreen> createState() => _EditQuizScreenState();
}

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

class _EditQuizScreenState extends State<EditQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _timeLimitController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final bool _isLoading = false;
  late List<QuestionFormItem> _questionsItems;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _titleController.dispose();
    _timeLimitController.dispose();
    for (var item in _questionsItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _initData() {
    // title controller
    _titleController = TextEditingController(text: widget.quiz.title);
    // time limit controller
    _timeLimitController = TextEditingController(
      text: widget.quiz.timeLimit.toString(),
    );

    _questionsItems = widget.quiz.questions.map((question) {
      return QuestionFormItem(
        TextEditingController(text: question.text),
        question.options
            .map((option) => TextEditingController(text: option))
            .toList(),
        question.correctOptionsIndex,
      );
    }).toList();
  }

  void _addQuestion() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        backgroundColor: AppTheme.backgroundColor,
      ),
    );
  }
}
