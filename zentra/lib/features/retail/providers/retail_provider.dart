import 'package:flutter/material.dart';
import '../models/retail_models.dart';

/// Provider de gestión operativa para el Modo Retail (Don Pedro) en Zentra.
/// Maneja inventario en tiempo real, punto de venta y arqueo de caja diario.
class RetailProvider with ChangeNotifier {
  double _cajaBase = 0.0;
  final List<CashMovement> _movimientosCaja = [];
  final List<CartItem> _cart = [];

  List<ProductItem> _products = [];

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
