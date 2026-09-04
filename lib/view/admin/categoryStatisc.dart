import 'package:flutter/material.dart';

import 'package:flutter_application_1/theme/theme.dart';

Card categoryStatistics(List<dynamic> categoryData) {
  return Card(
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
                'Category Statistics ',
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
            itemCount: categoryData.length,
            itemBuilder: (context, index) {
              final category = categoryData[index];
              final totalQuizzes = categoryData.fold<int>(
                0,
                (sum, item) => sum + (item['count'] as int),
              );
              // percentage for calculating the number of quizzes we use it .
              final percentage = totalQuizzes > 0
                  ? (category['count'] as int) / totalQuizzes * 100
                  : 0.0;
              return Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category['name'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w100,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            // for categoreies. ,
                            "${category['count']} ${(category['count'] as int) == 1 ? 'quiz' : 'quizzess'} ",

                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w100,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // for onle row ,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      ),
                      child: Text(
                        percentage.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w100,
                          color: AppTheme.primaryColor,
                        ),
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
