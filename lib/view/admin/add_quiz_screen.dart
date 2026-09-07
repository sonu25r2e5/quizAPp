import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/category.dart';
import 'package:flutter_application_1/model/question.dart';
import 'package:flutter_application_1/model/quiz.dart';
import 'package:flutter_application_1/theme/theme.dart';

class AddQuizScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const AddQuizScreen({super.key, this.categoryId, this.categoryName});

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
  bool _isLoading = false;
  String? _selectedCategoryId;
  String? _categoryName;
  final List<QuestionFormItem> _questionsItems = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _categoryName = widget.categoryName;
    _addQuestion();
    _loadCategoryName();
  }

  Future<void> _loadCategoryName() async {
    if ((_categoryName?.trim().isNotEmpty ?? false) ||
        widget.categoryId == null) {
      return;
    }

    final categorySnapshot = await _firestore
        .collection('categories')
        .doc(widget.categoryId)
        .get();
    final categoryData = categorySnapshot.data();
    if (!mounted || categoryData == null) {
      return;
    }

    setState(() {
      _categoryName = Category.fromMap(categorySnapshot.id, categoryData).name;
    });
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

  void _addQuestion() {
    setState(() {
      // for adding question
      _questionsItems.add(
        QuestionFormItem(
          TextEditingController(),
          // options controller the amount of option to choose
          List.generate(4, (_) => TextEditingController()),
          0,
        ),
      );
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questionsItems[index].dispose();
      _questionsItems.removeAt(index);
    });
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please select a category')));
      return;
    }
    setState(() {
      _isLoading = true;
    });

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
      // to store in firestore cloud we use this.
      final quizDocument = _firestore.collection("quizzes").doc();
      await quizDocument.set(
        Quiz(
          id: quizDocument.id,
          title: _titleController.text.trim(),
          category: _selectedCategoryId!,
          timeLimit: int.parse(_timeLimitController.text.trim()),
          questions: questions,
          createdAt: DateTime.now(),
        ).toMap(),
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Quizes added succesfully')));
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          _categoryName != null && _categoryName!.trim().isNotEmpty
              ? 'Add ${_categoryName!.trim()}'
              : 'Add Some Quiz Question',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,

        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quiz Details are located here',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
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
                if (widget.categoryId == null)
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('categories').snapshots(),
                    builder: (context, snapshot) {
                      // if it contains error we use this.
                      if (snapshot.hasError) {
                        return Text("error");
                      }
                      // if it has some of the data we use this one .
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                        );
                      }

                      // some of the data is located here.
                      final categories = snapshot.data!.docs
                          .map(
                            (doc) => Category.fromMap(
                              doc.id,
                              doc.data() as Map<String, dynamic>,
                            ),
                          )
                          .toList();
                      // selecting the category function from here.
                      final selectedCategoryId =
                          categories.any(
                            (category) => category.id == _selectedCategoryId,
                          )
                          ? _selectedCategoryId
                          : null;
                      return DropdownButtonFormField<String>(
                        initialValue: selectedCategoryId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(
                            Icons.category_outlined,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        items: categories
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                SizedBox(height: 16),
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
                SizedBox(height: 20),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                              ...question.optionsControllers
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                    final optionIndex = entry.key;
                                    final controller = entry.value;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Radio<int>(
                                            activeColor:
                                                AppTheme.secondaryColor,
                                            value: optionIndex,
                                            groupValue:
                                                question.correctOptionsIndex,
                                            onChanged: (value) {
                                              setState(() {
                                                question.correctOptionsIndex =
                                                    value!;
                                              });
                                            },
                                          ),
                                          Expanded(
                                            child: TextFormField(
                                              controller: controller,
                                              decoration: InputDecoration(
                                                labelText:
                                                    'Option ${optionIndex + 1}',
                                                hintText: 'Enter option',
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
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
                          onPressed: _isLoading ? null : _saveQuiz,
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
                                  'Save Quiz',
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
          ],
        ),
      ),
    );
  }
}
