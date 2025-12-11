import 'package:freezed_annotation/freezed_annotation.dart';

part 'hero_stats.freezed.dart';
part 'hero_stats.g.dart';

@freezed
class HeroStats with _$HeroStats {
  const HeroStats._();

  const factory HeroStats({
    @Default(1) int id,
    @Default(1) int level,
    @Default(0) int currentXp,
    @Default(100) int requiredXp,
    @Default(100) int currentHp,
    @Default(100) int maxHp,
    @Default(0) int totalSaved,
    @Default(0) int totalSpent,
    @Default(0) int streak, // 연속 기록 일수
    DateTime? lastRecordDate,
  }) = _HeroStats;

  factory HeroStats.fromJson(Map<String, dynamic> json) =>
      _$HeroStatsFromJson(json);

  /// 현재 레벨에 맞는 칭호
  String get title {
    if (level >= 50) return '절약의 왕';
    if (level >= 30) return '저축 달인';
    if (level >= 20) return '알뜰 전사';
    if (level >= 10) return '절약 수련생';
    if (level >= 5) return '절약 초보자';
    return '텅장 뉴비';
  }

  /// XP 진행률 (0.0 ~ 1.0)
  double get xpProgress => currentXp / requiredXp;

  /// HP 진행률 (0.0 ~ 1.0)
  double get hpProgress => currentHp / maxHp;

  /// HP가 위험 수준인지
  bool get isHpLow => hpProgress < 0.3;

  /// HP가 매우 위험한지
  bool get isHpCritical => hpProgress < 0.1;
}

/// 히어로 스킬
@freezed
class HeroSkill with _$HeroSkill {
  const factory HeroSkill({
    required String id,
    required String name,
    required String description,
    required int level,
    required int maxLevel,
  }) = _HeroSkill;

  factory HeroSkill.fromJson(Map<String, dynamic> json) =>
      _$HeroSkillFromJson(json);
}

/// 기본 스킬 목록
class DefaultSkills {
  static List<HeroSkill> get all => [
        const HeroSkill(
          id: 'thrifty_purchase',
          name: '알뜰 구매',
          description: '구매시 10% 추가 절약',
          level: 1,
          maxLevel: 5,
        ),
        const HeroSkill(
          id: 'steady_saving',
          name: '꾸준한 저축',
          description: '매일 저축시 보너스 XP',
          level: 1,
          maxLevel: 5,
        ),
        const HeroSkill(
          id: 'impulse_defense',
          name: '충동 방어',
          description: '과소비 데미지 20% 감소',
          level: 1,
          maxLevel: 5,
        ),
      ];
}
