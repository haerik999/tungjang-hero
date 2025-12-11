import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required int id,
    required String title,
    required int amount,
    required bool isIncome,
    required String category,
    String? note,
    required DateTime createdAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}

enum TransactionCategory {
  // 지출 카테고리
  food('식비', Icons.restaurant),
  transport('교통', Icons.directions_bus),
  living('생활', Icons.home),
  shopping('쇼핑', Icons.shopping_bag),
  culture('문화', Icons.movie),
  medical('의료', Icons.local_hospital),
  education('교육', Icons.school),
  other('기타', Icons.category),

  // 수입 카테고리
  salary('급여', Icons.account_balance_wallet),
  allowance('용돈', Icons.wallet),
  investment('투자', Icons.trending_up),
  sideJob('부업', Icons.work),
  otherIncome('기타수입', Icons.card_giftcard);

  final String label;
  final IconData icon;

  const TransactionCategory(this.label, this.icon);

  static List<TransactionCategory> get expenseCategories => [
        food,
        transport,
        living,
        shopping,
        culture,
        medical,
        education,
        other,
      ];

  static List<TransactionCategory> get incomeCategories => [
        salary,
        allowance,
        investment,
        sideJob,
        otherIncome,
      ];
}
