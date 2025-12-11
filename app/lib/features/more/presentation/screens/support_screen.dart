import "package:flutter/material.dart";
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("고객센터")), body: ListView(children: [
    ListTile(title: const Text("자주 묻는 질문"), trailing: const Icon(Icons.chevron_right)),
    ListTile(title: const Text("1:1 문의"), trailing: const Icon(Icons.chevron_right)),
  ]));
}
