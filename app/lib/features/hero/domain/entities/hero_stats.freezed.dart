// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hero_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HeroStats _$HeroStatsFromJson(Map<String, dynamic> json) {
  return _HeroStats.fromJson(json);
}

/// @nodoc
mixin _$HeroStats {
  int get id => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  int get currentXp => throw _privateConstructorUsedError;
  int get requiredXp => throw _privateConstructorUsedError;
  int get currentHp => throw _privateConstructorUsedError;
  int get maxHp => throw _privateConstructorUsedError;
  int get totalSaved => throw _privateConstructorUsedError;
  int get totalSpent => throw _privateConstructorUsedError;
  int get streak => throw _privateConstructorUsedError; // 연속 기록 일수
  DateTime? get lastRecordDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HeroStatsCopyWith<HeroStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HeroStatsCopyWith<$Res> {
  factory $HeroStatsCopyWith(HeroStats value, $Res Function(HeroStats) then) =
      _$HeroStatsCopyWithImpl<$Res, HeroStats>;
  @useResult
  $Res call(
      {int id,
      int level,
      int currentXp,
      int requiredXp,
      int currentHp,
      int maxHp,
      int totalSaved,
      int totalSpent,
      int streak,
      DateTime? lastRecordDate});
}

/// @nodoc
class _$HeroStatsCopyWithImpl<$Res, $Val extends HeroStats>
    implements $HeroStatsCopyWith<$Res> {
  _$HeroStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? level = null,
    Object? currentXp = null,
    Object? requiredXp = null,
    Object? currentHp = null,
    Object? maxHp = null,
    Object? totalSaved = null,
    Object? totalSpent = null,
    Object? streak = null,
    Object? lastRecordDate = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      currentXp: null == currentXp
          ? _value.currentXp
          : currentXp // ignore: cast_nullable_to_non_nullable
              as int,
      requiredXp: null == requiredXp
          ? _value.requiredXp
          : requiredXp // ignore: cast_nullable_to_non_nullable
              as int,
      currentHp: null == currentHp
          ? _value.currentHp
          : currentHp // ignore: cast_nullable_to_non_nullable
              as int,
      maxHp: null == maxHp
          ? _value.maxHp
          : maxHp // ignore: cast_nullable_to_non_nullable
              as int,
      totalSaved: null == totalSaved
          ? _value.totalSaved
          : totalSaved // ignore: cast_nullable_to_non_nullable
              as int,
      totalSpent: null == totalSpent
          ? _value.totalSpent
          : totalSpent // ignore: cast_nullable_to_non_nullable
              as int,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as int,
      lastRecordDate: freezed == lastRecordDate
          ? _value.lastRecordDate
          : lastRecordDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HeroStatsImplCopyWith<$Res>
    implements $HeroStatsCopyWith<$Res> {
  factory _$$HeroStatsImplCopyWith(
          _$HeroStatsImpl value, $Res Function(_$HeroStatsImpl) then) =
      __$$HeroStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int level,
      int currentXp,
      int requiredXp,
      int currentHp,
      int maxHp,
      int totalSaved,
      int totalSpent,
      int streak,
      DateTime? lastRecordDate});
}

/// @nodoc
class __$$HeroStatsImplCopyWithImpl<$Res>
    extends _$HeroStatsCopyWithImpl<$Res, _$HeroStatsImpl>
    implements _$$HeroStatsImplCopyWith<$Res> {
  __$$HeroStatsImplCopyWithImpl(
      _$HeroStatsImpl _value, $Res Function(_$HeroStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? level = null,
    Object? currentXp = null,
    Object? requiredXp = null,
    Object? currentHp = null,
    Object? maxHp = null,
    Object? totalSaved = null,
    Object? totalSpent = null,
    Object? streak = null,
    Object? lastRecordDate = freezed,
  }) {
    return _then(_$HeroStatsImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      currentXp: null == currentXp
          ? _value.currentXp
          : currentXp // ignore: cast_nullable_to_non_nullable
              as int,
      requiredXp: null == requiredXp
          ? _value.requiredXp
          : requiredXp // ignore: cast_nullable_to_non_nullable
              as int,
      currentHp: null == currentHp
          ? _value.currentHp
          : currentHp // ignore: cast_nullable_to_non_nullable
              as int,
      maxHp: null == maxHp
          ? _value.maxHp
          : maxHp // ignore: cast_nullable_to_non_nullable
              as int,
      totalSaved: null == totalSaved
          ? _value.totalSaved
          : totalSaved // ignore: cast_nullable_to_non_nullable
              as int,
      totalSpent: null == totalSpent
          ? _value.totalSpent
          : totalSpent // ignore: cast_nullable_to_non_nullable
              as int,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as int,
      lastRecordDate: freezed == lastRecordDate
          ? _value.lastRecordDate
          : lastRecordDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HeroStatsImpl extends _HeroStats {
  const _$HeroStatsImpl(
      {this.id = 1,
      this.level = 1,
      this.currentXp = 0,
      this.requiredXp = 100,
      this.currentHp = 100,
      this.maxHp = 100,
      this.totalSaved = 0,
      this.totalSpent = 0,
      this.streak = 0,
      this.lastRecordDate})
      : super._();

  factory _$HeroStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$HeroStatsImplFromJson(json);

  @override
  @JsonKey()
  final int id;
  @override
  @JsonKey()
  final int level;
  @override
  @JsonKey()
  final int currentXp;
  @override
  @JsonKey()
  final int requiredXp;
  @override
  @JsonKey()
  final int currentHp;
  @override
  @JsonKey()
  final int maxHp;
  @override
  @JsonKey()
  final int totalSaved;
  @override
  @JsonKey()
  final int totalSpent;
  @override
  @JsonKey()
  final int streak;
// 연속 기록 일수
  @override
  final DateTime? lastRecordDate;

  @override
  String toString() {
    return 'HeroStats(id: $id, level: $level, currentXp: $currentXp, requiredXp: $requiredXp, currentHp: $currentHp, maxHp: $maxHp, totalSaved: $totalSaved, totalSpent: $totalSpent, streak: $streak, lastRecordDate: $lastRecordDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HeroStatsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.currentXp, currentXp) ||
                other.currentXp == currentXp) &&
            (identical(other.requiredXp, requiredXp) ||
                other.requiredXp == requiredXp) &&
            (identical(other.currentHp, currentHp) ||
                other.currentHp == currentHp) &&
            (identical(other.maxHp, maxHp) || other.maxHp == maxHp) &&
            (identical(other.totalSaved, totalSaved) ||
                other.totalSaved == totalSaved) &&
            (identical(other.totalSpent, totalSpent) ||
                other.totalSpent == totalSpent) &&
            (identical(other.streak, streak) || other.streak == streak) &&
            (identical(other.lastRecordDate, lastRecordDate) ||
                other.lastRecordDate == lastRecordDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, level, currentXp, requiredXp,
      currentHp, maxHp, totalSaved, totalSpent, streak, lastRecordDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HeroStatsImplCopyWith<_$HeroStatsImpl> get copyWith =>
      __$$HeroStatsImplCopyWithImpl<_$HeroStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HeroStatsImplToJson(
      this,
    );
  }
}

abstract class _HeroStats extends HeroStats {
  const factory _HeroStats(
      {final int id,
      final int level,
      final int currentXp,
      final int requiredXp,
      final int currentHp,
      final int maxHp,
      final int totalSaved,
      final int totalSpent,
      final int streak,
      final DateTime? lastRecordDate}) = _$HeroStatsImpl;
  const _HeroStats._() : super._();

  factory _HeroStats.fromJson(Map<String, dynamic> json) =
      _$HeroStatsImpl.fromJson;

  @override
  int get id;
  @override
  int get level;
  @override
  int get currentXp;
  @override
  int get requiredXp;
  @override
  int get currentHp;
  @override
  int get maxHp;
  @override
  int get totalSaved;
  @override
  int get totalSpent;
  @override
  int get streak;
  @override // 연속 기록 일수
  DateTime? get lastRecordDate;
  @override
  @JsonKey(ignore: true)
  _$$HeroStatsImplCopyWith<_$HeroStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HeroSkill _$HeroSkillFromJson(Map<String, dynamic> json) {
  return _HeroSkill.fromJson(json);
}

/// @nodoc
mixin _$HeroSkill {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  int get maxLevel => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HeroSkillCopyWith<HeroSkill> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HeroSkillCopyWith<$Res> {
  factory $HeroSkillCopyWith(HeroSkill value, $Res Function(HeroSkill) then) =
      _$HeroSkillCopyWithImpl<$Res, HeroSkill>;
  @useResult
  $Res call(
      {String id, String name, String description, int level, int maxLevel});
}

/// @nodoc
class _$HeroSkillCopyWithImpl<$Res, $Val extends HeroSkill>
    implements $HeroSkillCopyWith<$Res> {
  _$HeroSkillCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? level = null,
    Object? maxLevel = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      maxLevel: null == maxLevel
          ? _value.maxLevel
          : maxLevel // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HeroSkillImplCopyWith<$Res>
    implements $HeroSkillCopyWith<$Res> {
  factory _$$HeroSkillImplCopyWith(
          _$HeroSkillImpl value, $Res Function(_$HeroSkillImpl) then) =
      __$$HeroSkillImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, String name, String description, int level, int maxLevel});
}

/// @nodoc
class __$$HeroSkillImplCopyWithImpl<$Res>
    extends _$HeroSkillCopyWithImpl<$Res, _$HeroSkillImpl>
    implements _$$HeroSkillImplCopyWith<$Res> {
  __$$HeroSkillImplCopyWithImpl(
      _$HeroSkillImpl _value, $Res Function(_$HeroSkillImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? level = null,
    Object? maxLevel = null,
  }) {
    return _then(_$HeroSkillImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      maxLevel: null == maxLevel
          ? _value.maxLevel
          : maxLevel // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HeroSkillImpl implements _HeroSkill {
  const _$HeroSkillImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.level,
      required this.maxLevel});

  factory _$HeroSkillImpl.fromJson(Map<String, dynamic> json) =>
      _$$HeroSkillImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final int level;
  @override
  final int maxLevel;

  @override
  String toString() {
    return 'HeroSkill(id: $id, name: $name, description: $description, level: $level, maxLevel: $maxLevel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HeroSkillImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.maxLevel, maxLevel) ||
                other.maxLevel == maxLevel));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, description, level, maxLevel);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HeroSkillImplCopyWith<_$HeroSkillImpl> get copyWith =>
      __$$HeroSkillImplCopyWithImpl<_$HeroSkillImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HeroSkillImplToJson(
      this,
    );
  }
}

abstract class _HeroSkill implements HeroSkill {
  const factory _HeroSkill(
      {required final String id,
      required final String name,
      required final String description,
      required final int level,
      required final int maxLevel}) = _$HeroSkillImpl;

  factory _HeroSkill.fromJson(Map<String, dynamic> json) =
      _$HeroSkillImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  int get level;
  @override
  int get maxLevel;
  @override
  @JsonKey(ignore: true)
  _$$HeroSkillImplCopyWith<_$HeroSkillImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
