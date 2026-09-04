import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/theme.dart';

Card recentlyActivites(
  List<QueryDocumentSnapshot<Object?>> latestQuizzes,
  String Function(DateTime) formatDate,
) {
  return Card(
    child: Padding(
      padding: EdgeInsetsGeometry.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Recently Activities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // listview
          ListView.builder(
            shrinkWrap: true,
            //physis
            physics: NeverScrollableScrollPhysics(),
            itemCount: latestQuizzes.length,
            itemBuilder: (context, index) {
              final quiz = latestQuizzes[index].data() as Map<String, dynamic>;

              return Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.quiz_rounded,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'created on ${formatDate(quiz['createdAt'].toDate())}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
