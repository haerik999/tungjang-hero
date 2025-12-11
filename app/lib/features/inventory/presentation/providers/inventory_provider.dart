import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';

part 'inventory_provider.g.dart';

class InventoryState {
  final bool isLoading;
  final String? error;
  final List<dynamic> items;
  final int gold;
  final List<dynamic> equippedItems;
  final List<dynamic> inventoryEquipments;

  const InventoryState({
    this.isLoading = false,
    this.error,
    this.items = const [],
    this.gold = 0,
    this.equippedItems = const [],
    this.inventoryEquipments = const [],
  });

  InventoryState copyWith({
    bool? isLoading,
    String? error,
    List<dynamic>? items,
    int? gold,
    List<dynamic>? equippedItems,
    List<dynamic>? inventoryEquipments,
  }) {
    return InventoryState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      items: items ?? this.items,
      gold: gold ?? this.gold,
      equippedItems: equippedItems ?? this.equippedItems,
      inventoryEquipments: inventoryEquipments ?? this.inventoryEquipments,
    );
  }
}

@riverpod
class InventoryNotifier extends _$InventoryNotifier {
  @override
  InventoryState build() {
    return const InventoryState();
  }

  ApiClient get _apiClient => ref.read(apiClientProvider);

  Future<void> loadInventory() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiClient.getInventory();
      final data = response.data;

      state = state.copyWith(
        isLoading: false,
        items: data['items'] ?? [],
        gold: data['gold'] ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadEquipments() async {
    try {
      final response = await _apiClient.getEquipments();
      final data = response.data;

      state = state.copyWith(
        equippedItems: data['equipped'] ?? [],
        inventoryEquipments: data['inventory'] ?? [],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> useItem(String itemType, int quantity) async {
    try {
      await _apiClient.useItem(itemType, quantity);
      await loadInventory();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> sellItems(String itemType, int quantity) async {
    try {
      final response = await _apiClient.sellItems(itemType, quantity);
      final data = response.data;

      state = state.copyWith(gold: data['total_gold']);
      await loadInventory();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> equipItem(int equipmentId) async {
    try {
      await _apiClient.equipItem(equipmentId);
      await loadEquipments();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> unequipItem(int id) async {
    try {
      await _apiClient.unequipItem(id);
      await loadEquipments();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<Map<String, dynamic>?> enhanceEquipment(int equipmentId) async {
    try {
      final response = await _apiClient.enhanceEquipment(equipmentId);
      await loadEquipments();
      await loadInventory(); // Refresh stones count
      return response.data;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> sellEquipment(int id) async {
    try {
      await _apiClient.sellEquipment(id);
      await loadEquipments();
      await loadInventory(); // Refresh gold
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Get item count by type
  int getItemCount(String itemType) {
    final item = state.items.firstWhere(
      (i) => i['item_type'] == itemType,
      orElse: () => {'quantity': 0},
    );
    return item['quantity'] ?? 0;
  }

  // Get equipped item by slot
  dynamic getEquippedBySlot(String slot) {
    return state.equippedItems.firstWhere(
      (e) => e['slot'] == slot,
      orElse: () => null,
    );
  }
}
