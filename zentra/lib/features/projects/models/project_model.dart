/// Modelo de datos para Proyectos en el Modo Servicios de Zentra.
/// Incorpora servicios, gastos con soportes, pagos/abonos y cálculo de ganancia real.
class ProjectExpenseModel {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String? receiptPhotoUrl;

  ProjectExpenseModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    this.receiptPhotoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'receiptPhotoUrl': receiptPhotoUrl,
    };
  }

  factory ProjectExpenseModel.fromMap(Map<String, dynamic> map) {
    return ProjectExpenseModel(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      receiptPhotoUrl: map['receiptPhotoUrl'],
    );
  }
}

class ProjectPaymentModel {
  final String id;
  final double amount;
  final String paymentMethod;
  final DateTime date;
  final String notes;

  ProjectPaymentModel({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory ProjectPaymentModel.fromMap(Map<String, dynamic> map) {
    return ProjectPaymentModel(
      id: map['id'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod'] ?? 'Efectivo',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      notes: map['notes'] ?? '',
    );
  }
}

class ProjectModel {
  final String id;
  final String name;
  final String clientName;
  final DateTime deliveryDate;
  final String status;
  final List<String> services;
  final double totalPrice;
  final List<ProjectExpenseModel> expenses;
  final List<ProjectPaymentModel> payments;

  ProjectModel({
    required this.id,
    required this.name,
    required this.clientName,
    required this.deliveryDate,
    required this.status,
    required this.services,
    this.totalPrice = 0.0,
    this.expenses = const [],
    this.payments = const [],
  });

  // Métricas financieras calculadas según las Reglas de Oro de Zentra:
  // Ganancia Real = Total Cobrado - Total Gastos
  double get totalPaid => payments.fold(0.0, (sum, p) => sum + p.amount);
  double get totalExpenses => expenses.fold(0.0, (sum, e) => sum + e.amount);
  double get netProfit => totalPaid - totalExpenses;
  double get pendingBalance {
    final target = totalPrice > 0 ? totalPrice : totalPaid;
    final diff = target - totalPaid;
    return diff > 0 ? diff : 0.0;
  }

  ProjectModel copyWith({
    String? id,
    String? name,
    String? clientName,
    DateTime? deliveryDate,
    String? status,
    List<String>? services,
    double? totalPrice,
    List<ProjectExpenseModel>? expenses,
    List<ProjectPaymentModel>? payments,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      clientName: clientName ?? this.clientName,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      status: status ?? this.status,
      services: services ?? this.services,
      totalPrice: totalPrice ?? this.totalPrice,
      expenses: expenses ?? this.expenses,
      payments: payments ?? this.payments,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'clientName': clientName,
      'deliveryDate': deliveryDate.toIso8601String(),
      'status': status,
      'services': services,
      'totalPrice': totalPrice,
      'expenses': expenses.map((e) => e.toMap()).toList(),
      'payments': payments.map((p) => p.toMap()).toList(),
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map, String documentId) {
    var rawExpenses = map['expenses'] as List<dynamic>? ?? [];
    var rawPayments = map['payments'] as List<dynamic>? ?? [];

    return ProjectModel(
      id: documentId,
      name: map['name'] ?? '',
      clientName: map['clientName'] ?? '',
      deliveryDate: map['deliveryDate'] != null
          ? DateTime.parse(map['deliveryDate'])
          : DateTime.now(),
      status: map['status'] ?? 'En Diseño',
      services: List<String>.from(map['services'] ?? []),
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      expenses: rawExpenses
          .map((e) => ProjectExpenseModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      payments: rawPayments
          .map((p) => ProjectPaymentModel.fromMap(Map<String, dynamic>.from(p)))
          .toList(),
    );
  }
}
