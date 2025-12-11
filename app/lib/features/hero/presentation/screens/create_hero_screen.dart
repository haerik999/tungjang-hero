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
  bool _isLoading = false;

  final List<BuildOption> _builds = const [
    BuildOption(
      id: 'physical',
      name: '물리형',
      icon: Icons.fitness_center,
      description: 'ATK/HP/SPD 집중\n높은 물리 데미지',
      color: Colors.red,
    ),
    BuildOption(
      id: 'magic',
      name: '마법형',
      icon: Icons.auto_fix_high,
      description: 'MAG/MP/MDF 집중\n강력한 마법 스킬',
      color: Colors.purple,
    ),
    BuildOption(
      id: 'tank',
      name: '탱커형',
      icon: Icons.shield,
      description: 'HP/DEF/MDF 집중\n높은 생존력',
      color: Colors.blue,
    ),
    BuildOption(
      id: 'balance',
      name: '밸런스',
      icon: Icons.balance,
      description: '균형 잡힌 스탯\n초보자 추천',
      color: Colors.green,
    ),
  ];

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
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '나의 히어로를 만들어요',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Character preview
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: _builds
                        .firstWhere((b) => b.id == _selectedBuild)
                        .color
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _builds
                          .firstWhere((b) => b.id == _selectedBuild)
                          .color,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    _builds
                        .firstWhere((b) => b.id == _selectedBuild)
                        .icon,
                    size: 80,
                    color: _builds
                        .firstWhere((b) => b.id == _selectedBuild)
                        .color,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Nickname field
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: '닉네임',
                  border: OutlineInputBorder(),
                  helperText: '2~12자, 한글/영문/숫자',
                ),
                maxLength: 12,
              ),

              const SizedBox(height: 24),

              // Build selection
              const Text(
                '시작 빌드 선택 (나중에 변경 가능)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: _builds.length,
                itemBuilder: (context, index) {
                  final build = _builds[index];
                  final isSelected = _selectedBuild == build.id;

                  return InkWell(
                    onTap: () => setState(() => _selectedBuild = build.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? build.color.withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? build.color : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            build.icon,
                            size: 32,
                            color: isSelected ? build.color : Colors.grey[600],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            build.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? build.color : Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            build.description,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (isSelected) ...[
                            const SizedBox(height: 4),
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: build.color,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Info text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '스탯은 언제든 무료로 초기화 가능해요!',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Create button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        '모험 시작!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCreate() async {
    final nickname = _nicknameController.text.trim();

    if (nickname.isEmpty || nickname.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임을 2자 이상 입력해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Call API to create hero
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    if (mounted) {
      context.go('/');
    }
  }
}

class BuildOption {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final Color color;

  const BuildOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.color,
  });
}
