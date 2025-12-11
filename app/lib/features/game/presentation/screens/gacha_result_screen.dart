import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class GachaResultScreen extends StatefulWidget {
  const GachaResultScreen({super.key});

  @override
  State<GachaResultScreen> createState() => _GachaResultScreenState();
}

class _GachaResultScreenState extends State<GachaResultScreen> {
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _revealed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text('가챠 결과', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Expanded(
              child: Center(
                child: _revealed ? _buildRevealedItem() : _buildUnrevealedItem(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnrevealedItem() {
    return Container(
      width: 150, height: 200,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: const Icon(Icons.help_outline, size: 64, color: Colors.white24),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1000.ms, color: Colors.white24);
  }

  Widget _buildRevealedItem() {
    // 랜덤 결과 (영웅 등급 예시)
    const grade = '영웅';
    const color = Color(0xFF9C27B0);
    const itemName = '영웅의 검';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 등급 표시
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
          child: const Text(grade, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ).animate().fadeIn().scale(begin: const Offset(0.5, 0.5)),
        const SizedBox(height: 24),
        // 아이템 카드
        Container(
          width: 180, height: 240,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 3),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 30, spreadRadius: 5)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.gavel, size: 80, color: color),
              const SizedBox(height: 16),
              const Text(itemName, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms)
            .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        // 스탯 정보
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              _buildStatRow('공격력', '+95'),
              _buildStatRow('치명타', '+5%'),
            ],
          ),
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(width: 16),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
