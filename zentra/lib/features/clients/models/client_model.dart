class ClientModel {
  final String id;
  final String name;
  final String phone;
  final String document;
  final String email;
  final String address;
  final String notes;
  final DateTime createdAt;

  ClientModel({
    required this.id,
    required this.name,
    required this.phone,
    this.document = '',
    this.email = '',
    this.address = '',
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'document': document,
      'email': email,
      'address': address,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      document: map['document'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      notes: map['notes'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  ClientModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? document,
    String? email,
    String? address,
    String? notes,
    DateTime? createdAt,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      document: document ?? this.document,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
