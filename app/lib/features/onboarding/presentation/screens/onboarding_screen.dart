import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      title: '텅장히어로에 오신 것을\n환영합니다!',
      description: '가계부를 쓰면서 RPG 게임을\n즐길 수 있어요',
      icon: Icons.celebration,
    ),
    OnboardingPage(
      title: '지출을 기록하면',
      description: '강화석, 스킬북, 가챠 티켓 등\n게임에 필요한 재화를 얻어요',
      icon: Icons.edit_note,
      rewards: ['강화석', '스킬북', '가챠 티켓', '펫 먹이'],
    ),
    OnboardingPage(
      title: '게임은 자동으로 진행',
      description: '앱을 끄고 있어도 캐릭터가\n자동으로 사냥하며 성장해요',
      icon: Icons.auto_mode,
      rewards: ['자동 사냥', '자동 성장', '골드 획득', '장비 드롭'],
    ),
    OnboardingPage(
      title: '둘 다 해야 최강!',
      description: '가계부 기록 + 게임 플레이\n두 가지를 함께 해야\n캐릭터가 빠르게 성장해요',
      icon: Icons.emoji_events,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (_currentPage < _pages.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => _goToLogin(),
                  child: Text('건너뛰기', style: TextStyle(color: AppTheme.textSecondary)),
                ),
              )
            else
              const SizedBox(height: 48),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppTheme.primaryColor
                        : AppTheme.elevatedColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '(${_currentPage + 1}/${_pages.length})',
              style: TextStyle(color: AppTheme.textSecondary),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('이전'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: _currentPage == 0 ? 1 : 1,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _goToLogin();
                        }
                      },
                      child: Text(
                        _currentPage < _pages.length - 1 ? '다음' : '시작하기',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          if (page.rewards != null) ...[
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: page.rewards!.map((reward) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.elevatedColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Text(
                    reward,
                    style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _goToLogin() {
    context.go('/auth/login');
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final List<String>? rewards;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    this.rewards,
  });
}
