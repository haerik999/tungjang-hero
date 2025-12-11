import 'package:freezed_annotation/freezed_annotation.dart';

part 'quest.freezed.dart';

/// 퀘스트 타입
enum QuestType {
  daily('daily', '일일'),
  weekly('weekly', '주간'),
  challenge('challenge', '챌린지');

  final String value;
  final String label;
  const QuestType(this.value, this.label);

  static QuestType fromString(String value) {
    return QuestType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => QuestType.daily,
    );
  }
}

/// 퀘스트 카테고리
enum QuestCategory {
  record('record', '기록', '오늘의 지출/수입을 기록하세요'),
  save('save', '절약', '지출을 줄이고 저축하세요'),
  streak('streak', '연속', '꾸준히 기록하세요'),
  limit('limit', '제한', '특정 금액 이하로 지출하세요');

  final String value;
  final String label;
  final String description;
  const QuestCategory(this.value, this.label, this.description);
}

/// 퀘스트 엔티티 (UI용, Drift의 Quest와 별도)
@freezed
class QuestEntity with _$QuestEntity {
  const QuestEntity._();

  const factory QuestEntity({
    required int id,
    required QuestType questType,
    required String title,
    required String description,
    required int targetAmount,
    @Default(0) int currentAmount,
    required int rewardXp,
    @Default(false) bool isCompleted,
    @Default(false) bool isRewardClaimed,
    required DateTime startDate,
    required DateTime endDate,
  }) = _QuestEntity;

  /// 진행률 (0.0 ~ 1.0)
  double get progress {
    if (targetAmount == 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  /// 진행률 퍼센트 문자열
  String get progressText {
    if (isCompleted) return '완료!';
    return '$currentAmount / $targetAmount';
  }

  /// 완료 가능 여부
  bool get canClaim => isCompleted && !isRewardClaimed;

  /// 남은 시간 문자열
  String get remainingTimeText {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return '만료됨';

    final diff = endDate.difference(now);
    if (diff.inDays > 0) return '${diff.inDays}일 남음';
    if (diff.inHours > 0) return '${diff.inHours}시간 남음';
    if (diff.inMinutes > 0) return '${diff.inMinutes}분 남음';
    return '곧 만료';
  }

  /// 만료 여부
  bool get isExpired => DateTime.now().isAfter(endDate);
}
