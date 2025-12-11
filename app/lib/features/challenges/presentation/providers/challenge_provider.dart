import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';

part 'challenge_provider.g.dart';

class ChallengeState {
  final bool isLoading;
  final AppError? error;
  final List<dynamic> challenges;
  final List<dynamic> myChallenges;
  final int total;
  final int page;
  final int totalPages;
  final Map<String, dynamic>? selectedChallenge;
  final Map<String, dynamic>? lastReward;

  const ChallengeState({
    this.isLoading = false,
    this.error,
    this.challenges = const [],
    this.myChallenges = const [],
    this.total = 0,
    this.page = 1,
    this.totalPages = 0,
    this.selectedChallenge,
    this.lastReward,
  });

  ChallengeState copyWith({
    bool? isLoading,
    AppError? error,
    List<dynamic>? challenges,
    List<dynamic>? myChallenges,
    int? total,
    int? page,
    int? totalPages,
    Map<String, dynamic>? selectedChallenge,
    Map<String, dynamic>? lastReward,
    bool clearError = false,
  }) {
    return ChallengeState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      challenges: challenges ?? this.challenges,
      myChallenges: myChallenges ?? this.myChallenges,
      total: total ?? this.total,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      selectedChallenge: selectedChallenge ?? this.selectedChallenge,
      lastReward: lastReward,
    );
  }

  bool get hasError => error != null;
  String? get errorMessage => error?.message;

  // Computed getters
  List<dynamic> get soloChallenges {
    return challenges.where((c) => c['type'] == 'solo').toList();
  }

  List<dynamic> get communityChallenges {
    return challenges.where((c) => c['type'] == 'community').toList();
  }

  List<dynamic> get activeChallenges {
    return myChallenges
        .where((c) => c['challenge']?['status'] == 'active')
        .toList();
  }

  List<dynamic> get availableChallenges {
    return challenges
        .where((c) => c['type'] == 'solo' && c['status'] == 'available')
        .toList();
  }
}

@riverpod
class ChallengeNotifier extends _$ChallengeNotifier {
  @override
  ChallengeState build() {
    return const ChallengeState();
  }

  ApiClient get _apiClient => ref.read(apiClientProvider);

  AppError _handleError(dynamic e) {
    if (e is DioException) {
      return AppError.fromException(_apiClient.convertException(e));
    }
    return AppError.unknown(e);
  }

  Future<void> loadChallenges({
    String? type,
    String? status,
    String? category,
    int page = 1,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiClient.getChallenges(
        type: type,
        status: status,
        category: category,
        page: page,
      );

      final data = response.data;
      state = state.copyWith(
        isLoading: false,
        challenges: data['challenges'] ?? [],
        total: data['total'] ?? 0,
        page: data['page'] ?? 1,
        totalPages: data['total_pages'] ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _handleError(e));
    }
  }

  Future<void> loadMyChallenges() async {
    try {
      final response = await _apiClient.getMyChallenges();
      state = state.copyWith(myChallenges: response.data ?? []);
    } catch (e) {
      state = state.copyWith(error: _handleError(e));
    }
  }

  Future<void> loadChallenge(int id) async {
    try {
      final response = await _apiClient.getChallenge(id);
      state = state.copyWith(selectedChallenge: response.data);
    } catch (e) {
      state = state.copyWith(error: _handleError(e));
    }
  }

  Future<bool> createChallenge({
    required String title,
    String? description,
    String? category,
    required String targetType,
    required int targetValue,
    required String duration,
    int? maxParticipants,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _apiClient.createChallenge({
        'title': title,
        'description': description,
        'category': category,
        'target_type': targetType,
        'target_value': targetValue,
        'duration': duration,
        if (maxParticipants != null) 'max_participants': maxParticipants,
      });

      state = state.copyWith(isLoading: false);
      await loadMyChallenges();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _handleError(e));
      return false;
    }
  }

  Future<bool> joinChallenge(int id) async {
    try {
      await _apiClient.joinChallenge(id);
      await loadMyChallenges();
      return true;
    } catch (e) {
      state = state.copyWith(error: _handleError(e));
      return false;
    }
  }

  Future<Map<String, dynamic>?> claimReward(int id) async {
    try {
      final response = await _apiClient.claimChallengeReward(id);
      final data = response.data;

      state = state.copyWith(lastReward: data);
      await loadMyChallenges();

      return data;
    } catch (e) {
      state = state.copyWith(error: _handleError(e));
      return null;
    }
  }

  void clearLastReward() {
    state = state.copyWith(lastReward: null);
  }
}
