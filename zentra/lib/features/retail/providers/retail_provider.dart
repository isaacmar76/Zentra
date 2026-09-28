import 'package:flutter/material.dart';
import '../models/retail_models.dart';

/// Provider de gestión operativa para el Modo Retail (Don Pedro) en Zentra.
/// Maneja inventario en tiempo real, punto de venta y arqueo de caja diario.
class RetailProvider with ChangeNotifier {
  double _cajaBase = 100000.0; // Base de apertura típica en Colombia
  final List<CashMovement> _movimientosCaja = [];
  final List<CartItem> _cart = [];

  List<ProductItem> _products = [
    ProductItem(id: 'prod-1', name: 'Arroz Diana 1kg', price: 4200, cost: 3400, stock: 25, category: 'Granos'),
    ProductItem(id: 'prod-2', name: 'Aceite Premier 1L', price: 9500, cost: 7800, stock: 14, category: 'Abarrotes'),
    ProductItem(id: 'prod-3', name: 'Leche Alquería Entera 1L', price: 4800, cost: 3900, stock: 18, category: 'Lácteos'),
    ProductItem(id: 'prod-4', name: 'Huevos AA x 30', price: 18000, cost: 15200, stock: 3, category: 'Abarrotes'), // Stock bajo
    ProductItem(id: 'prod-5', name: 'Pan Tajado Bimbo', price: 6500, cost: 5200, stock: 8, category: 'Panadería'),
    ProductItem(id: 'prod-6', name: 'Azúcar Incauca 1kg', price: 4000, cost: 3200, stock: 20, category: 'Granos'),
    ProductItem(id: 'prod-7', name: 'Café Sello Rojo 500g', price: 12500, cost: 10400, stock: 4, category: 'Bebidas'), // Stock bajo
    ProductItem(id: 'prod-8', name: 'Gaseosa Coca Cola 1.5L', price: 5500, cost: 4200, stock: 12, category: 'Bebidas'),
  ];

  double get cajaBase => _cajaBase;
  List<ProductItem> get products => _products;
  List<CartItem> get cart => _cart;
  List<CashMovement> get movimientosCaja => _movimientosCaja;

  double get cartTotal => _cart.fold(0.0, (sum, item) => sum + item.subtotal);
  int get cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  double get totalVentasHoy {
    return _movimientosCaja
        .where((m) => m.type == 'Venta')
        .fold(0.0, (sum, m) => sum + m.amount);
  }

  double get totalGastosHoy {
    return _movimientosCaja
        .where((m) => m.type == 'Gasto')
        .fold(0.0, (sum, m) => sum + m.amount);
  }

  // Cuadre de Caja: Base + Ventas en efectivo - Gastos
  double get saldoEsperadoEnCaja => _cajaBase + totalVentasHoy - totalGastosHoy;

  List<ProductItem> get productosBajoStock =>
      _products.where((p) => p.isLowStock).toList();

  // Agregar al carrito
  bool addToCart(ProductItem product) {
    final existingIndex = _cart.indexWhere((c) => c.product.id == product.id);
    final currentQtyInCart = existingIndex != -1 ? _cart[existingIndex].quantity : 0;

    // Regla de Oro Zentra: Si no hay stock suficiente, no deja vender
    if (product.stock <= currentQtyInCart) {
      return false; // Sin stock
    }

    if (existingIndex != -1) {
      _cart[existingIndex].quantity++;
    } else {
      _cart.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
    return true;
  }

  void removeFromCart(ProductItem product) {
    final existingIndex = _cart.indexWhere((c) => c.product.id == product.id);
    if (existingIndex != -1) {
      if (_cart[existingIndex].quantity > 1) {
        _cart[existingIndex].quantity--;
      } else {
        _cart.removeAt(existingIndex);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // Cobrar y procesar venta: descuenta stock y suma a caja
  bool checkout(String paymentMethod) {
    if (_cart.isEmpty) return false;

    final total = cartTotal;

    // Descontar inventario
    for (var item in _cart) {
      final pIndex = _products.indexWhere((p) => p.id == item.product.id);
      if (pIndex != -1) {
        _products[pIndex].stock -= item.quantity;
      }
    }

    // Registrar en caja del día
    _movimientosCaja.insert(
      0,
      CashMovement(
        id: 'mov_${DateTime.now().millisecondsSinceEpoch}',
        type: 'Venta',
        amount: total,
        description: 'Venta POS (${_cart.length} productos) - $paymentMethod',
        date: DateTime.now(),
      ),
    );

    _cart.clear();
    notifyListeners();
    return true;
  }

  // Registrar salida de gasto del local en caja
  void registrarSalidaCaja(String descripcion, double monto) {
    _movimientosCaja.insert(
      0,
      CashMovement(
        id: 'mov_${DateTime.now().millisecondsSinceEpoch}',
        type: 'Gasto',
        amount: monto,
        description: descripcion,
        date: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  // Ajustar base de apertura
  void setBaseApertura(double base) {
    _cajaBase = base;
    notifyListeners();
  }
}
