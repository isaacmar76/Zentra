import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project_model.dart';

/// Provider de gestión de proyectos y finanzas para el Modo Servicios de Zentra.
/// Diseñado con arquitectura híbrida: opera 100% offline con datos locales
/// y sincroniza con Firestore en la nube si hay conexión activa.
class ProjectsProvider with ChangeNotifier {
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  List<ProjectModel> _projects = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<ProjectModel> get projects => _projects;

  // Cálculo en tiempo real de ingresos: suma de todos los pagos registrados
  double get ingresosMes {
    return _projects.fold(0.0, (sum, p) => sum + p.totalPaid);
  }

  // Cálculo en tiempo real de gastos: suma de todos los insumos y costos
  double get gastosMes {
    return _projects.fold(0.0, (sum, p) => sum + p.totalExpenses);
  }

  // Ganancia neta global del negocio = Ingresos - Gastos
  double get gananciaMes => ingresosMes - gastosMes;

  // Proyectos activos (no finalizados)
  int get proyectosActivos =>
      _projects.where((p) => p.status != 'Entregado').length;

  // Alerta clave de Zentra: Proyectos que vencen en los próximos 3 días
  List<ProjectModel> get pedidosProntoAVencer {
    final now = DateTime.now();
    return _projects.where((p) {
      final diff = p.deliveryDate.difference(now).inDays;
      return diff >= 0 && diff <= 3 && p.status != 'Entregado';
    }).toList();
  }

  ProjectsProvider() {
    _loadInitialData();
    _listenToAuthChanges();
  }

  /// Carga los datos por defecto de Tatiana (08-ajustes-tatiana.md)
  void _loadInitialData() {
    final now = DateTime.now();
    _projects = [
      ProjectModel(
        id: 'tatiana-demo-1',
        name: '15 años Maria',
        clientName: 'Maria Rodriguez',
        deliveryDate: now.add(const Duration(days: 2)), // Pronto a vencer
        status: 'En Producción',
        services: ['Invitaciones', 'Centros de mesa'],
        totalPrice: 400000.0, // 50 invitaciones ($150.000) + 10 centros ($250.000)
        payments: [
          ProjectPaymentModel(
            id: 'pay-1',
            amount: 160000.0,
            paymentMethod: 'Nequi',
            date: now.subtract(const Duration(days: 3)),
            notes: 'Anticipo del 40%',
          ),
        ],
        expenses: [
          ProjectExpenseModel(
            id: 'exp-1',
            description: 'Papel fotográfico y cintas blush',
            amount: 45000.0,
            date: now.subtract(const Duration(days: 2)),
          ),
          ProjectExpenseModel(
            id: 'exp-2',
            description: 'Bases en madera para centros de mesa',
            amount: 35000.0,
            date: now.subtract(const Duration(days: 1)),
          ),
        ],
      ),
      ProjectModel(
        id: 'tatiana-demo-2',
        name: 'Bautizo Santiago',
        clientName: 'Camila Duque',
        deliveryDate: now.add(const Duration(days: 8)),
        status: 'En Diseño',
        services: ['Banderines', 'Invitaciones'],
        totalPrice: 230000.0,
        payments: [
          ProjectPaymentModel(
            id: 'pay-2',
            amount: 115000.0,
            paymentMethod: 'Efectivo',
            date: now.subtract(const Duration(days: 1)),
            notes: 'Anticipo 50%',
          ),
        ],
        expenses: [
          ProjectExpenseModel(
            id: 'exp-3',
            description: 'Cartulina perlada y cinta dorada',
            amount: 28000.0,
            date: now,
          ),
        ],
      ),
    ];
    notifyListeners();
  }

  void _listenToAuthChanges() {
    final auth = _auth;
    if (auth != null) {
      try {
        auth.authStateChanges().listen((user) {
          if (user != null) {
            _listenToFirestoreProjects(user.uid);
          }
        });
      } catch (e) {
        debugPrint('Modo local activado para ProjectsProvider: $e');
      }
    }
  }

  void _listenToFirestoreProjects(String userId) {
    final firestore = _firestore;
    if (firestore == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      firestore
          .collection('projects')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _projects = snapshot.docs
              .map((doc) => ProjectModel.fromMap(doc.data(), doc.id))
              .toList();
        }
        _isLoading = false;
        notifyListeners();
      }, onError: (e) {
        debugPrint('Aviso Firestore sync: $e. Manteniendo datos locales.');
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProject(ProjectModel project) async {
    _projects.insert(0, project);
    notifyListeners();

    // Intentar sincronizar en la nube si está conectado
    final user = _auth?.currentUser;
    final firestore = _firestore;
    if (user != null && firestore != null) {
      try {
        final data = project.toMap();
        data['userId'] = user.uid;
        await firestore.collection('projects').doc(project.id).set(data);
      } catch (e) {
        debugPrint('Guardado localmente. Se sincronizará con la nube luego: $e');
      }
    }
  }

  Future<void> updateProject(ProjectModel updatedProject) async {
    final index = _projects.indexWhere((p) => p.id == updatedProject.id);
    if (index != -1) {
      _projects[index] = updatedProject;
      notifyListeners();
    }

    final firestore = _firestore;
    if (firestore != null) {
      try {
        await firestore
            .collection('projects')
            .doc(updatedProject.id)
            .update(updatedProject.toMap());
      } catch (e) {
        debugPrint('Actualizado localmente: $e');
      }
    }
  }

  // Regla de Oro Zentra: Agregar gasto a un proyecto
  Future<void> addExpense(String projectId, ProjectExpenseModel expense) async {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      final project = _projects[index];
      final updatedExpenses = List<ProjectExpenseModel>.from(project.expenses)..add(expense);
      final updated = project.copyWith(expenses: updatedExpenses);
      await updateProject(updated);
    }
  }

  // Regla de Oro Zentra: Un gasto solo se puede borrar, no editar
  Future<void> deleteExpense(String projectId, String expenseId) async {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      final project = _projects[index];
      final updatedExpenses = project.expenses.where((e) => e.id != expenseId).toList();
      final updated = project.copyWith(expenses: updatedExpenses);
      await updateProject(updated);
    }
  }

  // Registrar abono o pago
  Future<void> addPayment(String projectId, ProjectPaymentModel payment) async {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      final project = _projects[index];
      final updatedPayments = List<ProjectPaymentModel>.from(project.payments)..add(payment);
      final updated = project.copyWith(payments: updatedPayments);
      await updateProject(updated);
    }
  }

  // Cambiar estado de avance
  Future<void> updateStatus(String projectId, String newStatus) async {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      final project = _projects[index];
      final updated = project.copyWith(status: newStatus);
      await updateProject(updated);
    }
  }
}
