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

class ProjectTaskModel {
  final String id;
  final String title;
  final bool isCompleted;
  final bool isPurchase;
  final double cost;

  ProjectTaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.isPurchase = false,
    this.cost = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'isPurchase': isPurchase,
      'cost': cost,
    };
  }

  factory ProjectTaskModel.fromMap(Map<String, dynamic> map) {
    return ProjectTaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      isPurchase: map['isPurchase'] ?? false,
      cost: (map['cost'] as num?)?.toDouble() ?? 0.0,
    );
  }

  ProjectTaskModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    bool? isPurchase,
    double? cost,
  }) {
    return ProjectTaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      isPurchase: isPurchase ?? this.isPurchase,
      cost: cost ?? this.cost,
    );
  }
}

class ProjectItemModel {
  final String id;
  final String? catalogId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String? imageUrl;

  ProjectItemModel({
    required this.id,
    this.catalogId,
    required this.name,
    this.quantity = 1,
    required this.unitPrice,
    double? subtotal,
    this.imageUrl,
  }) : subtotal = subtotal ?? (quantity * unitPrice);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'catalogId': catalogId,
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
      'imageUrl': imageUrl,
    };
  }

  factory ProjectItemModel.fromMap(Map<String, dynamic> map) {
    final qty = (map['quantity'] as num?)?.toInt() ?? 1;
    final price = (map['unitPrice'] as num?)?.toDouble() ?? 0.0;
    return ProjectItemModel(
      id: map['id'] ?? '',
      catalogId: map['catalogId'],
      name: map['name'] ?? '',
      quantity: qty,
      unitPrice: price,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? (qty * price),
      imageUrl: map['imageUrl'],
    );
  }
}

class ProjectModel {
  final String id;
  final String name;
  final String clientName;
  final String clientPhone;
  final String notes;
  final DateTime deliveryDate;
  final String status;
  final List<String> services;
  final List<ProjectItemModel> items;
  final double totalPrice;
  final List<ProjectExpenseModel> expenses;
  final List<ProjectPaymentModel> payments;
  final List<ProjectTaskModel> tasks;

  ProjectModel({
    required this.id,
    required this.name,
    required this.clientName,
    this.clientPhone = '',
    this.notes = '',
    required this.deliveryDate,
    required this.status,
    required this.services,
    this.items = const [],
    this.totalPrice = 0.0,
    this.expenses = const [],
    this.payments = const [],
    this.tasks = const [],
  });

  // Métricas financieras calculadas según las Reglas de Oro de Zentra:
  // Ganancia Real = Total Cobrado - Total Compras (Directas + Compras Checklist marcadas como realizadas)
  double get totalPaid => payments.fold(0.0, (sum, p) => sum + p.amount);
  
  double get directPurchasesTotal => expenses.fold(0.0, (sum, e) => sum + e.amount);
  
  double get checklistPurchasesTotal => tasks
      .where((t) => t.isPurchase && t.isCompleted && t.cost > 0)
      .fold(0.0, (sum, t) => sum + t.cost);

  double get totalExpenses => directPurchasesTotal + checklistPurchasesTotal;
  
  double get netProfit => totalPaid - totalExpenses;
  
  double get pendingBalance {
    final target = totalPrice > 0 ? totalPrice : totalPaid;
    final diff = target - totalPaid;
    return diff > 0 ? diff : 0.0;
  }
  double get paymentProgress {
    if (totalPrice <= 0) return totalPaid > 0 ? 1.0 : 0.0;
    final progress = totalPaid / totalPrice;
    return progress > 1.0 ? 1.0 : progress;
  }

  ProjectModel copyWith({
    String? id,
    String? name,
    String? clientName,
    String? clientPhone,
    String? notes,
    DateTime? deliveryDate,
    String? status,
    List<String>? services,
    List<ProjectItemModel>? items,
    double? totalPrice,
    List<ProjectExpenseModel>? expenses,
    List<ProjectPaymentModel>? payments,
    List<ProjectTaskModel>? tasks,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      notes: notes ?? this.notes,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      status: status ?? this.status,
      services: services ?? this.services,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      expenses: expenses ?? this.expenses,
      payments: payments ?? this.payments,
      tasks: tasks ?? this.tasks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'notes': notes,
      'deliveryDate': deliveryDate.toIso8601String(),
      'status': status,
      'services': services,
      'items': items.map((i) => i.toMap()).toList(),
      'totalPrice': totalPrice,
      'expenses': expenses.map((e) => e.toMap()).toList(),
      'payments': payments.map((p) => p.toMap()).toList(),
      'tasks': tasks.map((t) => t.toMap()).toList(),
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map, String documentId) {
    var rawExpenses = map['expenses'] as List<dynamic>? ?? [];
    var rawPayments = map['payments'] as List<dynamic>? ?? [];
    var rawTasks = map['tasks'] as List<dynamic>? ?? [];
    var rawItems = map['items'] as List<dynamic>? ?? [];

    return ProjectModel(
      id: documentId.isNotEmpty ? documentId : (map['id'] ?? ''),
      name: map['name'] ?? '',
      clientName: map['clientName'] ?? '',
      clientPhone: map['clientPhone'] ?? '',
      notes: map['notes'] ?? '',
      deliveryDate: map['deliveryDate'] != null
          ? DateTime.parse(map['deliveryDate'])
          : DateTime.now(),
      status: map['status'] ?? 'En Diseño',
      services: List<String>.from(map['services'] ?? []),
      items: rawItems
          .map((i) => ProjectItemModel.fromMap(Map<String, dynamic>.from(i)))
          .toList(),
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      expenses: rawExpenses
          .map((e) => ProjectExpenseModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      payments: rawPayments
          .map((p) => ProjectPaymentModel.fromMap(Map<String, dynamic>.from(p)))
          .toList(),
      tasks: rawTasks
          .map((t) => ProjectTaskModel.fromMap(Map<String, dynamic>.from(t)))
          .toList(),
    );
  }
}
