import "package:flutter/material.dart";
import "../../../../core/theme/app_theme.dart";

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});
  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 3,
    child: Scaffold(
      appBar: AppBar(title: const Text("상점"), bottom: const TabBar(tabs: [Tab(text: "골드"), Tab(text: "캐시"), Tab(text: "패키지")])),
      body: TabBarView(children: [
        Center(child: Text("골드 상점", style: TextStyle(color: AppTheme.textSecondary))),
        Center(child: Text("캐시 상점", style: TextStyle(color: AppTheme.textSecondary))),
        Center(child: Text("패키지", style: TextStyle(color: AppTheme.textSecondary))),
      ]),
    ),
  );
}
