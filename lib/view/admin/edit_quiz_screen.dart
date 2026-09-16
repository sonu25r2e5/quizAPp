import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/question.dart';
import 'package:flutter_application_1/model/quiz.dart';
import 'package:flutter_application_1/theme/theme.dart';

// Displays the editing screen for an existing quiz.
class EditQuizScreen extends StatefulWidget {
  // Quiz data used to pre-fill the editing form.
  final Quiz quiz;

  const EditQuizScreen({super.key, required this.quiz});

  @override
  State<EditQuizScreen> createState() => _EditQuizScreenState();
}

class QuestionFormItem {
  // Controllers represent the question text and its answer options.
  final TextEditingController questionControllers;
  final List<TextEditingController> optionsControllers;
  int correctOptionsIndex;

  QuestionFormItem(
    this.questionControllers,
    this.optionsControllers,
    this.correctOptionsIndex,
  );

  // Releases the controllers owned by this question row.
  void dispose() {
    questionControllers.dispose();
    for (var element in optionsControllers) {
      element.dispose();
    }
  }
}

class _EditQuizScreenState extends State<EditQuizScreen> {
  // Stores the form controls and editable question rows.
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _timeLimitController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  late List<QuestionFormItem> _questionsItems;

  @override
  void initState() {
    // Converts the quiz model into editable controller values.
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    // Releases all controllers when editing ends.
    _titleController.dispose();
    _timeLimitController.dispose();
    for (var item in _questionsItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _initData() {
    // Initializes the quiz title and time limit fields.
    _titleController = TextEditingController(text: widget.quiz.title);
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
    // Adds a blank question row with four answer options.
    setState(() {
      _questionsItems.add(
        QuestionFormItem(
          TextEditingController(),
          List.generate(4, (e) => TextEditingController()),
          0,
        ),
      );
    });
  }

  // Removes a question row while keeping at least one question available.
  void _removeQuestion(int index) {
    if (_questionsItems.length > 1) {
      setState(() {
        _questionsItems[index].dispose();
        _questionsItems.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("you must typo at least one question ")),
      );
    }
  }

  Future<void> _updateQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      final questions = _questionsItems
          .map(
            (item) => Question(
              text: item.questionControllers.text.trim(),
              options: item.optionsControllers
                  .map((e) => e.text.trim())
                  .toList(),
              correctOptionsIndex: item.correctOptionsIndex,
            ),
          )
          .toList();

      final updateQuiz = widget.quiz.copyWith(
        title: _titleController.text.trim(),
        timeLimit: int.parse(_timeLimitController.text),
        questions: questions,
      );

      // Creates a document reference so the generated ID is stored in the model.
      await _firestore
          .collection("quizzes")
          .doc(widget.quiz.id)
          .update(updateQuiz.toMap());

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Quizes Update  succesfully')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Quizes failed succesfully',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Builds the current editing scaffold; form controls can be added here.
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Quiz"),
        backgroundColor: AppTheme.backgroundColor,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _updateQuiz,
            icon: Icon(Icons.save, color: AppTheme.secondaryColor),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Text(
              'Quiz Details',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Quiz Tilte',
                hintText: 'Enter quiz title',
                prefixIcon: Icon(Icons.title, color: AppTheme.primaryColor),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quiz title you can\'t left empty ';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _timeLimitController,
              decoration: InputDecoration(
                labelText: 'Enter your time limit ( in minute)',
                hintText: 'Enter Time limit',
                prefixIcon: Icon(Icons.timer, color: AppTheme.primaryColor),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter time limit';
                }
                final number = int.tryParse(value);
                if (number == null || number <= 0) {
                  return "please enter a valid time limit";
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Questions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addQuestion,
                      label: Text('Add Question'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ..._questionsItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final QuestionFormItem question = entry.value;

                  return Card(
                    color: AppTheme.backgroundColor,
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Question ${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              // only if the question length is greater than one then this buttons shows up
                              if (_questionsItems.length > 1)
                                IconButton(
                                  onPressed: () {
                                    _removeQuestion(index);
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: question.questionControllers,
                            decoration: InputDecoration(
                              labelText: "Question Title ",
                              hintText: "Enter Question",
                              prefixIcon: Icon(
                                Icons.question_mark,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your question";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          ...question.optionsControllers.asMap().entries.map((
                            entry,
                          ) {
                            final optionIndex = entry.key;
                            final controller = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Radio<int>(
                                    activeColor: AppTheme.secondaryColor,
                                    value: optionIndex,
                                    groupValue: question.correctOptionsIndex,
                                    onChanged: (value) {
                                      setState(() {
                                        question.correctOptionsIndex = value!;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: controller,
                                      decoration: InputDecoration(
                                        labelText: 'Option ${optionIndex + 1}',
                                        hintText: 'Enter option',
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter option";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }),
                SizedBox(height: 12),
                Center(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateQuiz,
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Update Quiz',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
