enum GeneralTransactionType {
  gasto,
  ingreso,
}

/// Modelo para transacciones financieras generales del negocio
/// que no pertenecen a un proyecto específico (Arriendo, Servicios, Publicidad, etc.)
class GeneralTransactionModel {
  final String id;
  final GeneralTransactionType type;
  final String category;
  final String description;
  final double amount;
  final DateTime date;
  final String paymentMethod;

  GeneralTransactionModel({
    required this.id,
    required this.type,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    this.paymentMethod = 'Efectivo',
  });

  bool get isExpense => type == GeneralTransactionType.gasto;
  bool get isIncome => type == GeneralTransactionType.ingreso;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'category': category,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
    };
  }

  factory GeneralTransactionModel.fromMap(Map<String, dynamic> map) {
    return GeneralTransactionModel(
      id: map['id'] ?? '',
      type: map['type'] == 'ingreso'
          ? GeneralTransactionType.ingreso
          : GeneralTransactionType.gasto,
      category: map['category'] ?? 'General',
      description: map['description'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      paymentMethod: map['paymentMethod'] ?? 'Efectivo',
    );
  }
}
