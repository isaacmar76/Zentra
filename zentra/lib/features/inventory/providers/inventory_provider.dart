import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/catalog_item_model.dart';

/// Provider central de Inventario y Catálogo en Zentra.
/// Compartido entre el Modo Servicios (productos terminados) y Modo Retail (tienda/POS).
class InventoryProvider with ChangeNotifier {
  static const String _storageKey = 'zentra_catalog_inventory_v1';

  List<CatalogItemModel> _items = [];

  List<CatalogItemModel> get items => _items;

  InventoryProvider() {
    _loadItems();
  }

  // Filtrar según el modo activo
  List<CatalogItemModel> getItemsForMode(String mode) {
    return _items.where((i) => i.businessType == mode || i.businessType == 'ambos').toList();
  }

  List<CatalogItemModel> get lowStockItems => _items.where((i) => i.isLowStock).toList();

  Future<void> _loadItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_storageKey);

      if (str != null && str.isNotEmpty) {
        final List<dynamic> list = jsonDecode(str);
        _items = list.map((m) => CatalogItemModel.fromMap(m)).toList();
      } else {
        _items = _getDefaultInitialItems();
        await _saveItems();
      }
    } catch (e) {
      debugPrint('Error cargando inventario: $e');
      _items = _getDefaultInitialItems();
    }
    notifyListeners();
  }

  Future<void> _saveItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = jsonEncode(_items.map((i) => i.toMap()).toList());
      await prefs.setString(_storageKey, str);
    } catch (e) {
      debugPrint('Error guardando inventario: $e');
    }
  }

  List<CatalogItemModel> _getDefaultInitialItems() {
    return [];
  }

  Future<void> clearAllInventory() async {
    _items = [];
    await _saveItems();
    notifyListeners();
  }

  Future<void> addItem(CatalogItemModel item) async {
    _items.insert(0, item);
    await _saveItems();
    notifyListeners();
  }

  Future<void> updateItem(CatalogItemModel item) async {
    final idx = _items.indexWhere((i) => i.id == item.id);
    if (idx != -1) {
      _items[idx] = item;
      await _saveItems();
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _saveItems();
    notifyListeners();
  }

  // Venta directa de producto en inventario (descuenta stock)
  Future<bool> sellItem(String id, {int quantity = 1}) async {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1) {
      if (_items[idx].stock >= quantity) {
        _items[idx].stock -= quantity;
        await _saveItems();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<void> adjustStock(String id, int newStock) async {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1) {
      _items[idx].stock = newStock;
      await _saveItems();
      notifyListeners();
    }
  }
}
