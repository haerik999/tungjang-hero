import "package:flutter/material.dart";
class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("공지사항")), body: ListView(children: [
    ListTile(title: const Text("[업데이트] v1.0.0 출시"), subtitle: const Text("2025.01.01")),
    ListTile(title: const Text("[이벤트] 출시 기념 이벤트"), subtitle: const Text("2025.01.01")),
  ]));
}
