import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth & Onboarding
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/find_email_screen.dart';
import '../features/auth/presentation/screens/password_reset_screen.dart';
import '../features/auth/presentation/screens/password_reset_confirm_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/onboarding/presentation/screens/splash_screen.dart';
import '../features/onboarding/presentation/screens/create_hero_screen.dart';
import '../features/onboarding/presentation/screens/tutorial_screen.dart';

// Ledger (가계부)
import '../features/ledger/presentation/screens/ledger_screen.dart';
import '../features/ledger/presentation/screens/add_transaction_screen.dart';
import '../features/ledger/presentation/screens/ledger_stats_screen.dart';
import '../features/ledger/presentation/screens/budget_screen.dart';

// Game (게임)
import '../features/game/presentation/screens/game_screen.dart';
import '../features/game/presentation/screens/character_screen.dart';
import '../features/game/presentation/screens/character_stats_screen.dart';
import '../features/game/presentation/screens/character_equipment_screen.dart';
import '../features/game/presentation/screens/inventory_screen.dart';
import '../features/game/presentation/screens/inventory_detail_screen.dart';
import '../features/game/presentation/screens/enhance_screen.dart';
import '../features/game/presentation/screens/skill_screen.dart';
import '../features/game/presentation/screens/pet_screen.dart';
import '../features/game/presentation/screens/pet_detail_screen.dart';
import '../features/game/presentation/screens/boss_screen.dart';
import '../features/game/presentation/screens/boss_battle_screen.dart';
import '../features/game/presentation/screens/gacha_screen.dart';
import '../features/game/presentation/screens/gacha_result_screen.dart';
import '../features/game/presentation/screens/stage_select_screen.dart';

// Challenge (챌린지) - 게임에 통합되지만 하위 라우트는 유지
import '../features/challenge/presentation/screens/challenge_screen.dart';
import '../features/challenge/presentation/screens/daily_quest_screen.dart';
import '../features/challenge/presentation/screens/weekly_quest_screen.dart';
import '../features/challenge/presentation/screens/monthly_quest_screen.dart';
import '../features/challenge/presentation/screens/solo_challenge_screen.dart';
import '../features/challenge/presentation/screens/community_challenge_screen.dart';
import '../features/challenge/presentation/screens/ranking_screen.dart';

// More (더보기)
import '../features/more/presentation/screens/more_screen.dart';
import '../features/more/presentation/screens/shop_screen.dart';
import '../features/more/presentation/screens/achievements_screen.dart';
import '../features/more/presentation/screens/profile_screen.dart';
import '../features/more/presentation/screens/settings_screen.dart';
import '../features/more/presentation/screens/support_screen.dart';
import '../features/more/presentation/screens/notice_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      if (state.uri.path == '/') {
        return '/main';
      }
      return null;
    },
    routes: [
      // ═══════════════════════════════════════════════════════════
      // AUTH & ONBOARDING
      // ═══════════════════════════════════════════════════════════
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/find-email',
        name: 'findEmail',
        builder: (context, state) => const FindEmailScreen(),
      ),
      GoRoute(
        path: '/auth/password-reset',
        name: 'passwordReset',
        builder: (context, state) => const PasswordResetScreen(),
      ),
      GoRoute(
        path: '/auth/password-reset/confirm',
        name: 'passwordResetConfirm',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return PasswordResetConfirmScreen(token: token);
        },
      ),
      GoRoute(
        path: '/create-hero',
        name: 'createHero',
        builder: (context, state) => const CreateHeroScreen(),
      ),
      GoRoute(
        path: '/tutorial',
        name: 'tutorial',
        builder: (context, state) => const TutorialScreen(),
      ),

      // ═══════════════════════════════════════════════════════════
      // MAIN APP (스와이프 네비게이션)
      // ═══════════════════════════════════════════════════════════
      GoRoute(
        path: '/main',
        name: 'main',
        builder: (context, state) => const MainSwipeShell(),
      ),

      // 가계부 하위 라우트
      GoRoute(
        path: '/ledger/add',
        name: 'addTransaction',
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/ledger/stats',
        name: 'ledgerStats',
        builder: (context, state) => const LedgerStatsScreen(),
      ),
      GoRoute(
        path: '/ledger/budget',
        name: 'budget',
        builder: (context, state) => const BudgetScreen(),
      ),

      // 게임 하위 라우트
      GoRoute(
        path: '/game/character',
        name: 'character',
        builder: (context, state) => const CharacterScreen(),
      ),
      GoRoute(
        path: '/game/character/stats',
        name: 'characterStats',
        builder: (context, state) => const CharacterStatsScreen(),
      ),
      GoRoute(
        path: '/game/character/equipment',
        name: 'characterEquipment',
        builder: (context, state) => const CharacterEquipmentScreen(),
      ),
      GoRoute(
        path: '/game/inventory',
        name: 'inventory',
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: '/game/inventory/detail/:id',
        name: 'inventoryDetail',
        builder: (context, state) => InventoryDetailScreen(
          itemId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/game/inventory/enhance/:id',
        name: 'enhance',
        builder: (context, state) => EnhanceScreen(
          itemId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/game/skill',
        name: 'skill',
        builder: (context, state) => const SkillScreen(),
      ),
      GoRoute(
        path: '/game/pet',
        name: 'pet',
        builder: (context, state) => const PetScreen(),
      ),
      GoRoute(
        path: '/game/pet/detail/:id',
        name: 'petDetail',
        builder: (context, state) => PetDetailScreen(
          petId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/game/boss',
        name: 'boss',
        builder: (context, state) => const BossScreen(),
      ),
      GoRoute(
        path: '/game/boss/battle/:id',
        name: 'bossBattle',
        builder: (context, state) => BossBattleScreen(
          bossId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/game/gacha',
        name: 'gacha',
        builder: (context, state) => const GachaScreen(),
      ),
      GoRoute(
        path: '/game/gacha/result',
        name: 'gachaResult',
        builder: (context, state) => const GachaResultScreen(),
      ),
      GoRoute(
        path: '/game/stage',
        name: 'stageSelect',
        builder: (context, state) => const StageSelectScreen(),
      ),

      // 챌린지 하위 라우트 (게임에서 접근)
      GoRoute(
        path: '/challenge',
        name: 'challenge',
        builder: (context, state) => const ChallengeScreen(),
      ),
      GoRoute(
        path: '/challenge/daily',
        name: 'dailyQuest',
        builder: (context, state) => const DailyQuestScreen(),
      ),
      GoRoute(
        path: '/challenge/weekly',
        name: 'weeklyQuest',
        builder: (context, state) => const WeeklyQuestScreen(),
      ),
      GoRoute(
        path: '/challenge/monthly',
        name: 'monthlyQuest',
        builder: (context, state) => const MonthlyQuestScreen(),
      ),
      GoRoute(
        path: '/challenge/solo',
        name: 'soloChallenge',
        builder: (context, state) => const SoloChallengeScreen(),
      ),
      GoRoute(
        path: '/challenge/community',
        name: 'communityChallenge',
        builder: (context, state) => const CommunityChallengeScreen(),
      ),
      GoRoute(
        path: '/challenge/ranking',
        name: 'ranking',
        builder: (context, state) => const RankingScreen(),
      ),

      // 더보기 하위 라우트
      GoRoute(
        path: '/more/shop',
        name: 'shop',
        builder: (context, state) => const ShopScreen(),
      ),
      GoRoute(
        path: '/more/achievements',
        name: 'achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/more/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/more/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/more/support',
        name: 'support',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: '/more/notice',
        name: 'notice',
        builder: (context, state) => const NoticeScreen(),
      ),
    ],
  );
});

/// 메인 스와이프 쉘 - 엣지 힌트 스타일
class MainSwipeShell extends StatefulWidget {
  const MainSwipeShell({super.key});

  @override
  State<MainSwipeShell> createState() => _MainSwipeShellState();
}

class _MainSwipeShellState extends State<MainSwipeShell> {
  late PageController _pageController;
  int _currentPage = 0; // 가계부가 기본
  double _pageOffset = 0.0;

  final List<Widget> _pages = const [
    LedgerScreen(),
    GameScreen(),
    MoreScreen(),
  ];

  final List<String> _pageLabels = const ['가계부', '게임', '더보기'];
  final List<IconData> _pageIcons = const [
    Icons.receipt_long,
    Icons.sports_esports,
    Icons.more_horiz,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.92, // 엣지 힌트를 위해 살짝 작게
    );
    _pageController.addListener(_onPageScroll);
  }

  void _onPageScroll() {
    setState(() {
      _pageOffset = _pageController.page ?? 0.0;
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF253550),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 페이지 인디케이터
            _buildPageIndicator(),
            // 메인 컨텐츠 (스와이프 가능)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                clipBehavior: Clip.none,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPageCard(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_pages.length, (index) {
          final isActive = _currentPage == index;
          final distance = (_pageOffset - index).abs();
          final scale = 1.0 - (distance * 0.15).clamp(0.0, 0.3);
          final opacity = 1.0 - (distance * 0.4).clamp(0.0, 0.6);

          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 16 : 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFe94560).withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFFe94560)
                      : Colors.white.withValues(alpha: 0.2),
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _pageIcons[index],
                        size: 16,
                        color: isActive ? const Color(0xFFe94560) : Colors.white54,
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Text(
                          _pageLabels[index],
                          style: const TextStyle(
                            color: Color(0xFFe94560),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPageCard(int index) {
    final distance = (_pageOffset - index).abs();
    final scale = 1.0 - (distance * 0.05).clamp(0.0, 0.1);
    final opacity = 1.0 - (distance * 0.3).clamp(0.0, 0.5);

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0f1a2e),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0a1420).withValues(alpha: 0.6),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: _pages[index],
        ),
      ),
    );
  }
}
