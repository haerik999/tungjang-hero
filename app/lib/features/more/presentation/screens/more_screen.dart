import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_state_service.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/network/sync_service.dart';
import '../../../../core/theme/app_theme.dart';

/// 더보기 내부 탭 종류
enum MoreTab { menu, profile, settings }

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  // 현재 선택된 탭
  MoreTab _currentTab = MoreTab.menu;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f1a2e),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProfileCard(),
            Expanded(child: _buildContent()),
            _buildQuickMenu(),
          ],
        ),
      ),
    );
  }

  /// 메인 콘텐츠 영역 - 탭에 따라 다른 내용 표시
  Widget _buildContent() {
    switch (_currentTab) {
      case MoreTab.menu:
        return _buildMenuPanel();
      case MoreTab.profile:
        return _buildProfilePanel();
      case MoreTab.settings:
        return _buildSettingsPanel();
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
          const Text(
            '더보기',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text('v1.0.0', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('텅장히어로', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Lv.15', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                    const SizedBox(width: 8),
                    const Text('절약의 기사', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.bolt, color: Colors.white70, size: 12),
                    const SizedBox(width: 4),
                    const Text('전투력 12,450', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 메뉴 패널
  // ═══════════════════════════════════════════════════════════
  Widget _buildMenuPanel() {
    return _buildPanel(
      icon: Icons.grid_view,
      title: '메뉴',
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildMenuItem(Icons.store, '상점', '아이템과 재화 구매', const Color(0xFFffd700)),
          _buildMenuItem(Icons.emoji_events, '업적', '달성한 업적 확인', const Color(0xFFa78bfa)),
          _buildMenuItem(Icons.leaderboard, '랭킹', '전체 유저 순위', const Color(0xFF00d9ff)),
          _buildMenuItem(Icons.help_outline, '고객센터', '문의 및 도움말', const Color(0xFF778da9)),
          _buildMenuItem(Icons.campaign, '공지사항', '새로운 소식', const Color(0xFFe94560), badge: 'NEW'),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, Color color, {String? badge}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1b263b),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: 각 메뉴 기능 구현
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppTheme.dangerColor, borderRadius: BorderRadius.circular(4)),
                              child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.3), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 프로필 패널
  // ═══════════════════════════════════════════════════════════
  Widget _buildProfilePanel() {
    return _buildPanel(
      icon: Icons.person,
      title: '내 정보',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildProfileItem('닉네임', '텅장히어로'),
            _buildProfileItem('이메일', 'hero@example.com'),
            _buildProfileItem('가입일', '2024.01.15'),
            _buildProfileItem('플레이 시간', '125시간 32분'),
            const SizedBox(height: 16),
            _buildStatCard(),
            const SizedBox(height: 16),
            _buildActionButton(Icons.edit, '프로필 수정', const Color(0xFF00d9ff)),
            const SizedBox(height: 8),
            _buildActionButton(Icons.logout, '로그아웃', const Color(0xFFe94560)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1b263b),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildStatCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1b263b),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('누적 기록', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatItem('거래 기록', '1,234건', const Color(0xFF00d9ff))),
              Expanded(child: _buildStatItem('인증 횟수', '523회', const Color(0xFF4ade80))),
              Expanded(child: _buildStatItem('몬스터 처치', '8,912', const Color(0xFFe94560))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 설정 패널
  // ═══════════════════════════════════════════════════════════
  Widget _buildSettingsPanel() {
    return _buildPanel(
      icon: Icons.settings,
      title: '설정',
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildSyncSection(),
          const SizedBox(height: 16),
          _buildSettingSection('알림', [
            _buildSwitchSetting('푸시 알림', true),
            _buildSwitchSetting('이벤트 알림', true),
            _buildSwitchSetting('퀘스트 알림', false),
          ]),
          const SizedBox(height: 16),
          _buildSettingSection('게임', [
            _buildSwitchSetting('자동 전투', true),
            _buildSwitchSetting('효과음', true),
            _buildSwitchSetting('배경음악', false),
          ]),
          const SizedBox(height: 16),
          _buildSettingSection('계정', [
            _buildLinkSetting('비밀번호 변경'),
            _buildLinkSetting('계정 연동'),
            _buildLinkSetting('데이터 백업'),
          ]),
          const SizedBox(height: 16),
          _buildSettingSection('기타', [
            _buildLinkSetting('이용약관'),
            _buildLinkSetting('개인정보처리방침'),
            _buildLinkSetting('오픈소스 라이선스'),
          ]),
        ],
      ),
    );
  }

  /// 동기화 섹션 빌드
  Widget _buildSyncSection() {
    final syncState = ref.watch(syncServiceProvider);
    final isGuest = ref.watch(isGuestModeProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final canSync = ref.watch(canSyncProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('데이터 동기화',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1b263b),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // 동기화 상태 표시
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getSyncStatusColor(syncState.status)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: syncState.isSyncing
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF00d9ff),
                            ),
                          )
                        : Icon(
                            _getSyncStatusIcon(syncState.status),
                            color: _getSyncStatusColor(syncState.status),
                            size: 20,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getSyncStatusText(syncState.status, isGuest, isOnline),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        if (syncState.lastSyncTime != null)
                          Text(
                            '마지막 동기화: ${_formatDateTime(syncState.lastSyncTime!)}',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 11),
                          )
                        else if (!isGuest)
                          Text(
                            '동기화한 적 없음',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                  if (syncState.hasPendingChanges)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${syncState.pendingChanges}건 대기',
                        style: TextStyle(
                            color: AppTheme.warningColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // 동기화 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canSync && isOnline && !syncState.isSyncing
                      ? () => _handleManualSync()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00d9ff),
                    disabledBackgroundColor:
                        const Color(0xFF00d9ff).withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: syncState.isSyncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.sync, size: 18),
                  label: Text(
                    syncState.isSyncing ? '동기화 중...' : '지금 동기화',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
              if (isGuest) ...[
                const SizedBox(height: 8),
                Text(
                  '로그인하면 데이터가 클라우드에 백업됩니다',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
              if (!isOnline && !isGuest) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off,
                        color: Colors.white.withValues(alpha: 0.5), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '오프라인 상태입니다',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleManualSync() async {
    final result =
        await ref.read(syncServiceProvider.notifier).manualSync();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.hasErrors
                ? '동기화 완료 (일부 오류: ${result.errors.first})'
                : '동기화 완료 (업로드: ${result.uploaded}, 다운로드: ${result.downloaded})',
          ),
          backgroundColor:
              result.hasErrors ? AppTheme.warningColor : AppTheme.accentColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Color _getSyncStatusColor(SyncStatusType status) {
    switch (status) {
      case SyncStatusType.idle:
        return const Color(0xFF778da9);
      case SyncStatusType.syncing:
        return const Color(0xFF00d9ff);
      case SyncStatusType.success:
        return const Color(0xFF4ade80);
      case SyncStatusType.error:
        return const Color(0xFFe94560);
    }
  }

  IconData _getSyncStatusIcon(SyncStatusType status) {
    switch (status) {
      case SyncStatusType.idle:
        return Icons.cloud_queue;
      case SyncStatusType.syncing:
        return Icons.sync;
      case SyncStatusType.success:
        return Icons.cloud_done;
      case SyncStatusType.error:
        return Icons.cloud_off;
    }
  }

  String _getSyncStatusText(
      SyncStatusType status, bool isGuest, bool isOnline) {
    if (isGuest) return '게스트 모드';
    if (!isOnline) return '오프라인';

    switch (status) {
      case SyncStatusType.idle:
        return '동기화 대기';
      case SyncStatusType.syncing:
        return '동기화 중...';
      case SyncStatusType.success:
        return '동기화 완료';
      case SyncStatusType.error:
        return '동기화 실패';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';

    return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildSettingSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1b263b),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchSetting(String label, bool initialValue) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool value = initialValue;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
              Switch(
                value: value,
                onChanged: (newValue) => setState(() => value = newValue),
                activeColor: AppTheme.primaryColor,
                inactiveThumbColor: Colors.white30,
                inactiveTrackColor: Colors.white10,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLinkSetting(String label) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
              Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.3), size: 18),
            ],
          ),
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
          _buildQuickButton(Icons.grid_view, '메뉴', MoreTab.menu),
          _buildQuickButton(Icons.person, '프로필', MoreTab.profile),
          _buildQuickButton(Icons.settings, '설정', MoreTab.settings),
        ],
      ),
    );
  }

  Widget _buildQuickButton(IconData icon, String label, MoreTab tab) {
    final isSelected = _currentTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = tab),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFe94560).withValues(alpha: 0.2) : const Color(0xFF0f3460),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? const Color(0xFFe94560) : const Color(0xFF1b263b)),
            ),
            child: Icon(icon, color: isSelected ? const Color(0xFFe94560) : const Color(0xFF00d9ff), size: 22),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFe94560) : Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              )),
        ],
      ),
    );
  }
}
