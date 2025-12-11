// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hero_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HeroStatsImpl _$$HeroStatsImplFromJson(Map<String, dynamic> json) =>
    _$HeroStatsImpl(
      id: (json['id'] as num?)?.toInt() ?? 1,
      level: (json['level'] as num?)?.toInt() ?? 1,
      currentXp: (json['currentXp'] as num?)?.toInt() ?? 0,
      requiredXp: (json['requiredXp'] as num?)?.toInt() ?? 100,
      currentHp: (json['currentHp'] as num?)?.toInt() ?? 100,
      maxHp: (json['maxHp'] as num?)?.toInt() ?? 100,
      totalSaved: (json['totalSaved'] as num?)?.toInt() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      lastRecordDate: json['lastRecordDate'] == null
          ? null
          : DateTime.parse(json['lastRecordDate'] as String),
    );

Map<String, dynamic> _$$HeroStatsImplToJson(_$HeroStatsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'level': instance.level,
      'currentXp': instance.currentXp,
      'requiredXp': instance.requiredXp,
      'currentHp': instance.currentHp,
      'maxHp': instance.maxHp,
      'totalSaved': instance.totalSaved,
      'totalSpent': instance.totalSpent,
      'streak': instance.streak,
      'lastRecordDate': instance.lastRecordDate?.toIso8601String(),
    };

_$HeroSkillImpl _$$HeroSkillImplFromJson(Map<String, dynamic> json) =>
    _$HeroSkillImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      level: (json['level'] as num).toInt(),
      maxLevel: (json['maxLevel'] as num).toInt(),
    );

Map<String, dynamic> _$$HeroSkillImplToJson(_$HeroSkillImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'level': instance.level,
      'maxLevel': instance.maxLevel,
    };
