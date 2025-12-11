import "package:flutter/material.dart";
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("설정")), body: ListView(children: [
    ListTile(title: const Text("알림 설정"), trailing: const Icon(Icons.chevron_right)),
    ListTile(title: const Text("계정 관리"), trailing: const Icon(Icons.chevron_right)),
    ListTile(title: const Text("화면 설정"), trailing: const Icon(Icons.chevron_right)),
    ListTile(title: const Text("로그아웃"), trailing: const Icon(Icons.logout)),
  ]));
}
