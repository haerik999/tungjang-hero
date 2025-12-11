import 'package:flutter/material.dart';

class DailyQuestScreen extends StatelessWidget {
  const DailyQuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('일일 퀘스트')),
      body: const Center(child: Text('일일 퀘스트 상세')),
    );
  }
}
