/// Modelo de Usuarios y Roles para Zentra.
/// Define 2 perfiles claros de acceso:
/// 1. Dueño / Administrador (OWNER): Acceso total, visibilidad completa de costos,
///    ganancia neta, configuración y CRUD de usuarios.
/// 2. Colaborador / Vendedor (COLLABORATOR): Acceso operativo diario (ventas, pedidos,
///    checklist de tareas, catálogo), con métricas sensibles de ganancias netas protegidas.
enum UserRole {
  owner,
  collaborator,
}

class UserModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String pin;
  final UserRole role;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    this.email = '',
    this.phone = '',
    required this.pin,
    required this.role,
    this.isActive = true,
  });

  bool get isOwner => role == UserRole.owner;
  bool get isCollaborator => role == UserRole.collaborator;

  String get roleDisplayName => isOwner ? 'Dueño / Admin' : 'Colaborador';
  String get roleBadgeIcon => isOwner ? '👑' : '💼';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'pin': pin,
      'role': role == UserRole.owner ? 'OWNER' : 'COLLABORATOR',
      'isActive': isActive,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      pin: map['pin'] ?? '1234',
      role: (map['role'] == 'OWNER' || map['role'] == 'owner')
          ? UserRole.owner
          : UserRole.collaborator,
      isActive: map['isActive'] ?? true,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? phone,
    String? pin,
    UserRole? role,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      pin: pin ?? this.pin,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }
}
