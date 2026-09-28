/// Modelo de datos para productos del Catálogo e Inventario en Zentra.
/// Aplica tanto para Modo Servicios (productos terminados de Tatiana)
/// como para Modo Retail (víveres y abarrotes de Don Pedro).
class CatalogItemModel {
  final String id;
  final String name;
  final double salePrice;
  final double costPrice;
  int stock;
  final String category;
  final String businessType; // 'servicios', 'retail', 'ambos'

  CatalogItemModel({
    required this.id,
    required this.name,
    required this.salePrice,
    required this.costPrice,
    required this.stock,
    required this.category,
    this.businessType = 'ambos',
  });

  bool get isLowStock => stock <= 5;
  double get profitMargin => salePrice > 0 ? ((salePrice - costPrice) / salePrice) * 100 : 0.0;
  double get unitProfit => salePrice - costPrice;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'salePrice': salePrice,
      'costPrice': costPrice,
      'stock': stock,
      'category': category,
      'businessType': businessType,
    };
  }

  factory CatalogItemModel.fromMap(Map<String, dynamic> map) {
    return CatalogItemModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      salePrice: (map['salePrice'] as num?)?.toDouble() ?? 0.0,
      costPrice: (map['costPrice'] as num?)?.toDouble() ?? 0.0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      category: map['category'] ?? 'General',
      businessType: map['businessType'] ?? 'ambos',
    );
  }

  CatalogItemModel copyWith({
    String? id,
    String? name,
    double? salePrice,
    double? costPrice,
    int? stock,
    String? category,
    String? businessType,
  }) {
    return CatalogItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      salePrice: salePrice ?? this.salePrice,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      businessType: businessType ?? this.businessType,
    );
  }
}
