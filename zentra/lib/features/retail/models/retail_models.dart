/// Modelos de datos para el Modo Retail (Tiendas y Minimercados) en Zentra.
class ProductItem {
  final String id;
  final String name;
  final double price;
  final double cost;
  int stock;
  final String category;

  ProductItem({
    required this.id,
    required this.name,
    required this.price,
    required this.cost,
    required this.stock,
    required this.category,
  });

  bool get isLowStock => stock <= 5;
}

class CartItem {
  final ProductItem product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get subtotal => product.price * quantity;
}

class CashMovement {
  final String id;
  final String type; // 'Venta', 'Entrada', 'Gasto'
  final double amount;
  final String description;
  final DateTime date;

  CashMovement({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
  });
}
