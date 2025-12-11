import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = '텅장히어로';
  static const String appVersion = '1.0.0';

  // API
  static const String apiBaseUrl = 'http://100.115.250.107:8080/api/v1';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';

  // Hero Stats
  static const int maxLevel = 100;
  static const int baseXpPerLevel = 100;
  static const double xpMultiplier = 1.8;

  // Game Mechanics
  static const int savingXpMultiplier = 10;
  static const int questCompletionBonus = 50;
  static const double overspendingDamageMultiplier = 0.5; // HP damage when overspending

  // Transaction
  static const int minTransactionAmount = 1000;
  static const int maxDailyRecords = 10;
  static const int maxDailyRecordsWithReceipt = 20;

  // Categories - IconData
  static const Map<String, IconData> categoryIcons = {
    'food': Icons.restaurant,
    'transport': Icons.directions_bus,
    'shopping': Icons.shopping_cart,
    'cafe': Icons.local_cafe,
    'entertainment': Icons.movie,
    'medical': Icons.medical_services,
    'telecom': Icons.phone_android,
    'housing': Icons.home,
    'education': Icons.school,
    'savings': Icons.savings,
    'salary': Icons.account_balance_wallet,
    'other': Icons.category,
  };

  static const Map<String, String> categoryNames = {
    'food': '식비',
    'transport': '교통',
    'shopping': '쇼핑',
    'cafe': '카페',
    'entertainment': '문화/여가',
    'medical': '의료',
    'telecom': '통신',
    'housing': '주거/관리비',
    'education': '교육',
    'savings': '저축',
    'salary': '급여',
    'other': '기타',
  };

  // Equipment Grades
  static const Map<String, int> gradeColors = {
    'normal': 0xFFFFFFFF,
    'uncommon': 0xFF4CAF50,
    'rare': 0xFF2196F3,
    'epic': 0xFF9C27B0,
    'legendary': 0xFFFF9800,
    'mythic': 0xFFF44336,
  };
}
