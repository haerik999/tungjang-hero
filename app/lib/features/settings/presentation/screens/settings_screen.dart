import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          _buildSection(
            '계정',
            [
              _buildListTile(
                icon: Icons.person,
                title: '프로필 수정',
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.lock,
                title: '비밀번호 변경',
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.cloud_sync,
                title: '데이터 동기화',
                trailing: const Text(
                  '마지막 동기화: 방금 전',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            '게임 설정',
            [
              _buildSwitchTile(
                icon: Icons.notifications,
                title: '알림',
                subtitle: '퀘스트, 업적 알림 받기',
                value: true,
                onChanged: (value) {},
              ),
              _buildSwitchTile(
                icon: Icons.vibration,
                title: '진동',
                subtitle: '레벨업, 업적 달성시 진동',
                value: true,
                onChanged: (value) {},
              ),
              _buildListTile(
                icon: Icons.category,
                title: '카테고리 관리',
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.tune,
                title: '난이도 설정',
                trailing: const Text(
                  '보통',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                  ),
                ),
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            '화면',
            [
              _buildListTile(
                icon: Icons.palette,
                title: '테마',
                trailing: const Text(
                  '다크 모드',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                  ),
                ),
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.language,
                title: '언어',
                trailing: const Text(
                  '한국어',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                  ),
                ),
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            '정보',
            [
              _buildListTile(
                icon: Icons.help_outline,
                title: '도움말',
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.info_outline,
                title: '앱 정보',
                trailing: const Text(
                  'v1.0.0',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                  ),
                ),
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.description_outlined,
                title: '이용약관',
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.privacy_tip_outlined,
                title: '개인정보처리방침',
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            '',
            [
              _buildListTile(
                icon: Icons.logout,
                title: '로그아웃',
                titleColor: AppTheme.dangerColor,
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Color? titleColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: titleColor ?? AppTheme.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppTheme.textPrimary,
        ),
      ),
      trailing: trailing ??
          const Icon(
            Icons.chevron_right,
            color: AppTheme.textSecondary,
          ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(
        icon,
        color: AppTheme.textSecondary,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.textSecondary,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text(
          '로그아웃',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          '정말 로그아웃 하시겠습니까?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // Logout logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerColor,
            ),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}
