import 'package:flutter/material.dart';

import 'package:flutter_application_1/theme/theme.dart';

// Builds the dashboard card that summarizes quizzes grouped by category.
Card categoryStatistics(List<dynamic> categoryData) {
  return Card(
    color: AppTheme.backgroundColor,
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
          // Keeps the category list inside the dashboard's outer scroll view.
          ListView.builder(
            shrinkWrap: true,
            // Prevents nested scrolling conflicts with the parent ListView.
            physics: NeverScrollableScrollPhysics(),
            itemCount: categoryData.length,
            itemBuilder: (context, index) {
              final category = categoryData[index];
              final totalQuizzes = categoryData.fold<int>(
                0,
                (sum, item) => sum + (item['count'] as int),
              );
              // Calculates this category's share of all quizzes.
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
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            // for categoreies. ,
                            "${category['count']} ${(category['count'] as int) == 1 ? 'quiz' : 'quizzess'} ",

                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Highlights the calculated percentage for this category.
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${percentage.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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
