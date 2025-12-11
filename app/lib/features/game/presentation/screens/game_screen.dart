import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_state_service.dart';
import '../../../../core/network/connectivity_provider.dart';

/// 게임 내부 탭 종류
enum GameTab { battle, character, inventory, skill, quest, boss }

/// 텍스트 RPG 메인 화면
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final ScrollController _logScrollController = ScrollController();
  final List<BattleLog> _battleLogs = [];
  Timer? _battleTimer;
  bool _isAutoMode = true;
  final Random _random = Random();

  // 현재 선택된 탭
  GameTab _currentTab = GameTab.battle;

  // 캐릭터 상태
  int _heroHp = 850;
  int _heroMaxHp = 1000;
  int _heroMp = 200;
  int _heroMaxMp = 300;
  int _heroLevel = 15;
  int _heroExp = 2500;
  int _heroMaxExp = 5000;
  String _heroName = '절약의 기사';
  int _heroAtk = 120;
  int _heroDef = 80;
  int _heroSpd = 45;

  // 현재 몬스터
  String _monsterName = '슬라임';
  int _monsterHp = 0;
  int _monsterMaxHp = 0;
  int _monsterLevel = 12;

  // 던전 정보
  String _currentStage = '초원';
  int _stageFloor = 1;
  int _killCount = 0;

  // 재화
  int _gold = 125340;
  int _diamond = 23;

  // 인벤토리 (더미 데이터)
  final List<Map<String, dynamic>> _inventory = [
    {'name': '철검 +3', 'type': 'weapon', 'rarity': 'rare', 'equipped': true},
    {'name': '가죽 갑옷', 'type': 'armor', 'rarity': 'common', 'equipped': true},
    {'name': '체력 포션', 'type': 'consumable', 'rarity': 'common', 'count': 5},
    {'name': '강화석', 'type': 'material', 'rarity': 'uncommon', 'count': 23},
    {'name': '스킬북 조각', 'type': 'material', 'rarity': 'rare', 'count': 7},
    {'name': '낡은 반지', 'type': 'accessory', 'rarity': 'common', 'equipped': false},
  ];

  // 스킬 (더미 데이터)
  final List<Map<String, dynamic>> _skills = [
    {'name': '강타', 'level': 5, 'maxLevel': 10, 'desc': '강력한 일격으로 150% 데미지', 'cooldown': 3},
    {'name': '회복', 'level': 3, 'maxLevel': 10, 'desc': 'HP 20% 회복', 'cooldown': 10},
    {'name': '분노', 'level': 1, 'maxLevel': 5, 'desc': '10초간 공격력 30% 증가', 'cooldown': 30},
  ];

  // 퀘스트 (더미 데이터)
  final List<Map<String, dynamic>> _quests = [
    {'name': '오늘의 기록', 'desc': '거래 1건 기록', 'progress': 1, 'max': 1, 'reward': '강화석 x3', 'completed': true},
    {'name': '성실한 기록', 'desc': '거래 5건 기록', 'progress': 3, 'max': 5, 'reward': '강화석 x5', 'completed': false},
    {'name': '인증왕', 'desc': '영수증 인증 3건', 'progress': 1, 'max': 3, 'reward': '가챠 티켓 x1', 'completed': false},
  ];

  @override
  void initState() {
    super.initState();
    _spawnMonster();
    _addLog(BattleLog.system('[$_currentStage $_stageFloor층]에 도착했다.'));
    _startAutoBattle();
  }

  @override
  void dispose() {
    _battleTimer?.cancel();
    _logScrollController.dispose();
    super.dispose();
  }

  void _startAutoBattle() {
    _battleTimer?.cancel();
    if (_isAutoMode) {
      _battleTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
        _processBattle();
      });
    }
  }

  void _spawnMonster() {
    final monsters = ['슬라임', '고블린', '늑대', '박쥐', '버섯맨', '좀비'];
    _monsterName = monsters[_random.nextInt(monsters.length)];
    _monsterLevel = _stageFloor + _random.nextInt(3);
    _monsterMaxHp = 100 + (_monsterLevel * 20) + _random.nextInt(50);
    _monsterHp = _monsterMaxHp;
  }

  void _processBattle() {
    if (_monsterHp <= 0) {
      _spawnMonster();
      _addLog(BattleLog.system('Lv.$_monsterLevel $_monsterName이(가) 나타났다!'));
      return;
    }

    final playerDamage = 50 + _random.nextInt(30) + (_heroLevel * 2);
    final isCritical = _random.nextDouble() < 0.15;
    final finalDamage = isCritical ? (playerDamage * 1.5).toInt() : playerDamage;

    setState(() {
      _monsterHp = max(0, _monsterHp - finalDamage);
    });

    if (isCritical) {
      _addLog(BattleLog.playerCritical(_heroName, _monsterName, finalDamage));
    } else {
      _addLog(BattleLog.playerAttack(_heroName, _monsterName, finalDamage));
    }

    if (_monsterHp <= 0) {
      _onMonsterDefeated();
      return;
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final monsterDamage = 10 + _random.nextInt(20) + (_monsterLevel * 2);
      setState(() {
        _heroHp = max(0, _heroHp - monsterDamage);
      });
      _addLog(BattleLog.monsterAttack(_monsterName, _heroName, monsterDamage));

      if (_heroHp <= 0) {
        _onPlayerDefeated();
      }
    });
  }

  void _onMonsterDefeated() {
    final expGain = 20 + (_monsterLevel * 5) + _random.nextInt(10);
    final goldGain = 10 + (_monsterLevel * 3) + _random.nextInt(20);

    setState(() {
      _killCount++;
      _heroExp += expGain;
      _gold += goldGain;

      if (_heroExp >= _heroMaxExp) {
        _heroExp -= _heroMaxExp;
        _heroLevel++;
        _heroMaxHp += 50;
        _heroHp = _heroMaxHp;
        _heroMaxExp = (_heroMaxExp * 1.2).toInt();
        _heroAtk += 5;
        _heroDef += 3;
        _addLog(BattleLog.levelUp(_heroName, _heroLevel));
      }

      if (_killCount % 5 == 0) {
        _stageFloor++;
        _addLog(BattleLog.system('[$_currentStage $_stageFloor층]으로 진입했다.'));
      }
    });

    _addLog(BattleLog.defeat(_monsterName, expGain, goldGain));

    if (_random.nextDouble() < 0.2) {
      final items = ['낡은 검', '가죽 갑옷', '체력 포션', '강화석', '스킬북 조각'];
      final droppedItem = items[_random.nextInt(items.length)];
      _addLog(BattleLog.itemDrop(droppedItem));
    }
  }

  void _onPlayerDefeated() {
    _battleTimer?.cancel();
    _addLog(BattleLog.system('$_heroName이(가) 쓰러졌다...'));
    _addLog(BattleLog.system('마을로 귀환합니다.'));

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _heroHp = _heroMaxHp;
        _stageFloor = max(1, _stageFloor - 1);
      });
      _addLog(BattleLog.system('체력이 회복되었다.'));
      _addLog(BattleLog.system('[$_currentStage $_stageFloor층]에서 다시 시작한다.'));
      _spawnMonster();
      _startAutoBattle();
    });
  }

  void _addLog(BattleLog log) {
    setState(() {
      _battleLogs.add(log);
      if (_battleLogs.length > 100) {
        _battleLogs.removeAt(0);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScrollController.hasClients) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 온라인 전용 체크
    final isOnline = ref.watch(isOnlineProvider);
    final isGuest = ref.watch(isGuestModeProvider);
    final canPlay = isOnline && !isGuest;

    if (!canPlay) {
      return Scaffold(
        backgroundColor: const Color(0xFF0f1a2e),
        body: SafeArea(
          child: _buildOfflineOverlay(isOnline: isOnline, isGuest: isGuest),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0f1a2e),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildHeroStatus(),
            if (_currentTab == GameTab.battle && _monsterHp > 0) _buildMonsterStatus(),
            Expanded(child: _buildContent()),
            _buildQuickMenu(),
          ],
        ),
      ),
    );
  }

  /// 오프라인/게스트 모드 오버레이
  Widget _buildOfflineOverlay({required bool isOnline, required bool isGuest}) {
    final String title;
    final String message;
    final IconData icon;
    final Color iconColor;

    if (!isOnline) {
      title = '인터넷 연결이 필요합니다';
      message = '게임 기능은 온라인 상태에서만 이용할 수 있습니다.\n네트워크 연결을 확인해주세요.';
      icon = Icons.wifi_off;
      iconColor = const Color(0xFFe94560);
    } else if (isGuest) {
      title = '로그인이 필요합니다';
      message = '게임 기능을 이용하려면 로그인이 필요합니다.\n게임 데이터는 서버에서 관리됩니다.';
      icon = Icons.lock_outline;
      iconColor = const Color(0xFFffd700);
    } else {
      title = '접근 불가';
      message = '현재 게임에 접근할 수 없습니다.';
      icon = Icons.error_outline;
      iconColor = const Color(0xFFe94560);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(icon, size: 64, color: iconColor),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (isGuest) ...[
              ElevatedButton.icon(
                onPressed: () => context.push('/auth/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFe94560),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                icon: const Icon(Icons.login),
                label: const Text(
                  '로그인하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: () {
                // 가계부 탭으로 이동 (MainScreen의 탭 인덱스 변경 필요)
                // 간단히 뒤로 가기로 처리
                if (context.canPop()) {
                  context.pop();
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00d9ff),
                side: const BorderSide(color: Color(0xFF00d9ff)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              icon: const Icon(Icons.receipt_long),
              label: const Text(
                '가계부로 이동',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 메인 콘텐츠 영역 - 탭에 따라 다른 내용 표시
  Widget _buildContent() {
    switch (_currentTab) {
      case GameTab.battle:
        return _buildBattleLog();
      case GameTab.character:
        return _buildCharacterPanel();
      case GameTab.inventory:
        return _buildInventoryPanel();
      case GameTab.skill:
        return _buildSkillPanel();
      case GameTab.quest:
        return _buildQuestPanel();
      case GameTab.boss:
        return _buildBossPanel();
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFFe94560), size: 20),
                const SizedBox(width: 8),
                Text(
                  '$_currentStage $_stageFloor층',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _buildCurrency(Icons.monetization_on, _gold, const Color(0xFFffd700)),
          const SizedBox(width: 16),
          _buildCurrency(Icons.diamond, _diamond, const Color(0xFF00d9ff)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() => _isAutoMode = !_isAutoMode);
              if (_isAutoMode) {
                _startAutoBattle();
              } else {
                _battleTimer?.cancel();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isAutoMode ? const Color(0xFFe94560) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _isAutoMode ? const Color(0xFFe94560) : Colors.white30),
              ),
              child: Text(
                'AUTO',
                style: TextStyle(
                  color: _isAutoMode ? Colors.white : Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrency(IconData icon, int amount, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          _formatNumber(amount),
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  Widget _buildHeroStatus() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0f3460)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFe94560), Color(0xFF0f3460)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.shield, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Lv.$_heroLevel $_heroName',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text('처치: $_killCount',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                _buildStatusBar('HP', _heroHp, _heroMaxHp, const Color(0xFFe94560)),
                const SizedBox(height: 4),
                _buildStatusBar('EXP', _heroExp, _heroMaxExp, const Color(0xFF00d9ff)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonsterStatus() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0f3460).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFe94560).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.pest_control, color: Color(0xFFe94560), size: 20),
          const SizedBox(width: 8),
          Text('Lv.$_monsterLevel $_monsterName',
              style: const TextStyle(color: Color(0xFFe94560), fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _monsterMaxHp > 0 ? _monsterHp / _monsterMaxHp : 0,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFe94560)),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$_monsterHp/$_monsterMaxHp',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildStatusBar(String label, int current, int max, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: max > 0 ? current / max : 0,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$current/$max', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 전투 로그 패널
  // ═══════════════════════════════════════════════════════════
  Widget _buildBattleLog() {
    return _buildPanel(
      icon: Icons.menu_book,
      title: '모험 기록',
      trailing: GestureDetector(
        onTap: () => setState(() => _battleLogs.clear()),
        child: Text('지우기', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
      ),
      child: ListView.builder(
        controller: _logScrollController,
        padding: const EdgeInsets.all(12),
        itemCount: _battleLogs.length,
        itemBuilder: (context, index) {
          final log = _battleLogs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(log.message, style: TextStyle(color: log.color, fontSize: 13, height: 1.4)),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 캐릭터 패널
  // ═══════════════════════════════════════════════════════════
  Widget _buildCharacterPanel() {
    return _buildPanel(
      icon: Icons.person,
      title: '캐릭터 정보',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildStatRow('공격력', _heroAtk, Icons.flash_on, const Color(0xFFe94560)),
            _buildStatRow('방어력', _heroDef, Icons.shield, const Color(0xFF00d9ff)),
            _buildStatRow('속도', _heroSpd, Icons.speed, const Color(0xFF4ade80)),
            _buildStatRow('최대 HP', _heroMaxHp, Icons.favorite, const Color(0xFFe94560)),
            _buildStatRow('최대 MP', _heroMaxMp, Icons.auto_fix_high, const Color(0xFF818cf8)),
            const Divider(color: Color(0xFF1b263b), height: 24),
            _buildStatRow('전투력', _heroAtk + _heroDef + _heroSpd + (_heroLevel * 10), Icons.bolt, const Color(0xFFffd700)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
          const Spacer(),
          Text('$value', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 인벤토리 패널
  // ═══════════════════════════════════════════════════════════
  Widget _buildInventoryPanel() {
    return _buildPanel(
      icon: Icons.inventory_2,
      title: '인벤토리',
      trailing: Text('${_inventory.length}/50', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _inventory.length,
        itemBuilder: (context, index) {
          final item = _inventory[index];
          final color = _getRarityColor(item['rarity']);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1b263b),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getItemIcon(item['type']), color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'], style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
                      if (item['equipped'] == true)
                        Text('장착중', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
                    ],
                  ),
                ),
                if (item['count'] != null)
                  Text('x${item['count']}', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'legendary': return const Color(0xFFffd700);
      case 'epic': return const Color(0xFFa78bfa);
      case 'rare': return const Color(0xFF00d9ff);
      case 'uncommon': return const Color(0xFF4ade80);
      default: return const Color(0xFF778da9);
    }
  }

  IconData _getItemIcon(String type) {
    switch (type) {
      case 'weapon': return Icons.gavel;
      case 'armor': return Icons.shield;
      case 'accessory': return Icons.stars;
      case 'consumable': return Icons.local_drink;
      default: return Icons.inventory;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 스킬 패널
  // ═══════════════════════════════════════════════════════════
  Widget _buildSkillPanel() {
    return _buildPanel(
      icon: Icons.auto_fix_high,
      title: '스킬',
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _skills.length,
        itemBuilder: (context, index) {
          final skill = _skills[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1b263b),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_fix_high, color: Color(0xFF818cf8), size: 20),
                    const SizedBox(width: 8),
                    Text(skill['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text('Lv.${skill['level']}/${skill['maxLevel']}',
                        style: const TextStyle(color: Color(0xFF00d9ff), fontSize: 12)),
                    const Spacer(),
                    Text('${skill['cooldown']}초', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(skill['desc'], style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 퀘스트 패널
  // ═══════════════════════════════════════════════════════════
  Widget _buildQuestPanel() {
    return _buildPanel(
      icon: Icons.emoji_events,
      title: '일일 퀘스트',
      trailing: Text('2/3 완료', style: TextStyle(color: const Color(0xFF4ade80), fontSize: 11)),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _quests.length,
        itemBuilder: (context, index) {
          final quest = _quests[index];
          final completed = quest['completed'] as bool;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: completed ? const Color(0xFF4ade80).withValues(alpha: 0.1) : const Color(0xFF1b263b),
              borderRadius: BorderRadius.circular(8),
              border: completed ? Border.all(color: const Color(0xFF4ade80).withValues(alpha: 0.3)) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(completed ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: completed ? const Color(0xFF4ade80) : Colors.white38, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(quest['name'],
                          style: TextStyle(
                            color: completed ? const Color(0xFF4ade80) : Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: completed ? TextDecoration.lineThrough : null,
                          )),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFffd700).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(quest['reward'], style: const TextStyle(color: Color(0xFFffd700), fontSize: 10)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(quest['desc'], style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: quest['progress'] / quest['max'],
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              completed ? const Color(0xFF4ade80) : const Color(0xFF00d9ff)),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${quest['progress']}/${quest['max']}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 보스 패널
  // ═══════════════════════════════════════════════════════════
  Widget _buildBossPanel() {
    return _buildPanel(
      icon: Icons.whatshot,
      title: '보스 도전',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFe94560).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock, color: Color(0xFFe94560), size: 40),
            ),
            const SizedBox(height: 16),
            const Text('초원 보스', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('10층 도달 시 해금', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
            const SizedBox(height: 4),
            Text('현재: $_stageFloor층 / 10층', style: const TextStyle(color: Color(0xFF00d9ff), fontSize: 14)),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 150,
                child: LinearProgressIndicator(
                  value: _stageFloor / 10,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFe94560)),
                  minHeight: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 공통 패널 위젯
  Widget _buildPanel({
    required IconData icon,
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1b2a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1b263b)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF1b263b),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(11), topRight: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF778da9), size: 16),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(color: Color(0xFF778da9), fontSize: 13, fontWeight: FontWeight.w600)),
                const Spacer(),
                if (trailing != null) trailing,
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildQuickMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickButton(Icons.menu_book, '전투', GameTab.battle),
          _buildQuickButton(Icons.person, '캐릭터', GameTab.character),
          _buildQuickButton(Icons.inventory_2, '인벤', GameTab.inventory),
          _buildQuickButton(Icons.auto_fix_high, '스킬', GameTab.skill),
          _buildQuickButton(Icons.emoji_events, '퀘스트', GameTab.quest, badge: true),
          _buildQuickButton(Icons.whatshot, '보스', GameTab.boss),
        ],
      ),
    );
  }

  Widget _buildQuickButton(IconData icon, String label, GameTab tab, {bool badge = false}) {
    final isSelected = _currentTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = tab),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFe94560).withValues(alpha: 0.2) : const Color(0xFF0f3460),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? const Color(0xFFe94560) : const Color(0xFF1b263b)),
                ),
                child: Icon(icon, color: isSelected ? const Color(0xFFe94560) : const Color(0xFF00d9ff), size: 20),
              ),
              if (badge)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Color(0xFFe94560), shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFe94560) : Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              )),
        ],
      ),
    );
  }
}

/// 전투 로그 데이터
class BattleLog {
  final String message;
  final Color color;

  BattleLog(this.message, this.color);

  factory BattleLog.system(String message) => BattleLog('▶ $message', const Color(0xFF778da9));
  factory BattleLog.playerAttack(String player, String target, int damage) =>
      BattleLog('$player의 공격! $target에게 $damage 데미지!', const Color(0xFF00d9ff));
  factory BattleLog.playerCritical(String player, String target, int damage) =>
      BattleLog('★ $player의 치명타! $target에게 $damage 데미지!', const Color(0xFFffd700));
  factory BattleLog.monsterAttack(String monster, String target, int damage) =>
      BattleLog('$monster의 반격! $target에게 $damage 데미지.', const Color(0xFFe94560));
  factory BattleLog.defeat(String monster, int exp, int gold) =>
      BattleLog('✓ $monster 처치! +$exp EXP, +$gold G', const Color(0xFF4ade80));
  factory BattleLog.levelUp(String player, int level) =>
      BattleLog('★★★ $player 레벨 업! Lv.$level ★★★', const Color(0xFFffd700));
  factory BattleLog.itemDrop(String item) => BattleLog('♦ 아이템 획득: $item', const Color(0xFFa78bfa));
}
