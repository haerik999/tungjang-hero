import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class CreateHeroScreen extends ConsumerStatefulWidget {
  const CreateHeroScreen({super.key});

  @override
  ConsumerState<CreateHeroScreen> createState() => _CreateHeroScreenState();
}

class _CreateHeroScreenState extends ConsumerState<CreateHeroScreen> {
  final _nicknameController = TextEditingController();
  String _selectedBuild = 'balance';
  bool _isValid = false;

  final List<(String, IconData, String, String)> _builds = [
    ('physical', Icons.flash_on, '물리형', '공격력 중심, 빠른 사냥'),
    ('magic', Icons.auto_fix_high, '마법형', '마법 공격, 범위 공격 특화'),
    ('tank', Icons.shield, '탱커형', '높은 체력, 안정적 사냥'),
    ('balance', Icons.balance, '밸런스', '균형 잡힌 스탯 (추천)'),
  ];

  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(_validateInput);
  }

  void _validateInput() {
    final text = _nicknameController.text;
    setState(() {
      _isValid = text.length >= 2 && text.length <= 12;
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캐릭터 생성'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 캐릭터 미리보기
            Center(
              child: Container(
                width: 120,
                height: 150,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, size: 64, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      _nicknameController.text.isEmpty ? '???' : _nicknameController.text,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 닉네임 입력
            const Text(
              '닉네임',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nicknameController,
              maxLength: 12,
              decoration: InputDecoration(
                hintText: '2~12자, 한글/영문/숫자',
                counterText: '',
                suffixIcon: _isValid
                    ? const Icon(Icons.check_circle, color: AppTheme.accentColor)
                    : null,
              ),
            ),
            Text(
              '* 2~12자, 한글/영문/숫자 사용 가능',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 32),

            // 빌드 선택
            const Text(
              '시작 빌드 선택',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '나중에 언제든 무료로 변경할 수 있어요!',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: _builds.map((build) {
                final isSelected = _selectedBuild == build.$1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedBuild = build.$1),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor.withValues(alpha: 0.1)
                          : AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(build.$2, size: 24, color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              build.$3,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          build.$4,
                          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        if (build.$1 == 'balance')
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '추천',
                              style: TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // 생성 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isValid ? _createHero : null,
                child: const Text('모험 시작!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createHero() {
    // TODO: 캐릭터 생성 로직
    context.go('/tutorial');
  }
}
