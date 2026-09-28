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
    return [
      // 1. Catálogo Tatiana (Modo Servicios - Productos terminados)
      CatalogItemModel(
        id: 'cat_serv_1',
        name: 'Agendas 2026 Personalizadas',
        salePrice: 45000,
        costPrice: 18000,
        stock: 12,
        category: 'Papelería',
        businessType: 'servicios',
      ),
      CatalogItemModel(
        id: 'cat_serv_2',
        name: 'Cake Topper Acrílico & Foil',
        salePrice: 22000,
        costPrice: 7000,
        stock: 8,
        category: 'Fiestas',
        businessType: 'servicios',
      ),
      CatalogItemModel(
        id: 'cat_serv_3',
        name: 'Cajas Sorpresa Ensambladas',
        salePrice: 35000,
        costPrice: 12000,
        stock: 5,
        category: 'Empaques',
        businessType: 'servicios',
      ),
      CatalogItemModel(
        id: 'cat_serv_4',
        name: 'Cuadro Decorativo en Foil',
        salePrice: 55000,
        costPrice: 20000,
        stock: 4,
        category: 'Decoración',
        businessType: 'servicios',
      ),

      // 2. Catálogo Don Pedro (Modo Retail)
      CatalogItemModel(
        id: 'cat_ret_1',
        name: 'Arroz Diana 1kg',
        salePrice: 4200,
        costPrice: 3400,
        stock: 25,
        category: 'Granos',
        businessType: 'retail',
      ),
      CatalogItemModel(
        id: 'cat_ret_2',
        name: 'Aceite Premier 1L',
        salePrice: 9500,
        costPrice: 7800,
        stock: 14,
        category: 'Abarrotes',
        businessType: 'retail',
      ),
      CatalogItemModel(
        id: 'cat_ret_3',
        name: 'Leche Alquería Entera 1L',
        salePrice: 4800,
        costPrice: 3900,
        stock: 18,
        category: 'Lácteos',
        businessType: 'retail',
      ),
      CatalogItemModel(
        id: 'cat_ret_4',
        name: 'Huevos AA x 30',
        salePrice: 18000,
        costPrice: 15200,
        stock: 3,
        category: 'Abarrotes',
        businessType: 'retail',
      ),
    ];
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
