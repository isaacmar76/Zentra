import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project_model.dart';

/// Provider de gestión de proyectos y finanzas para el Modo Servicios de Zentra.
/// Diseñado con arquitectura híbrida: opera 100% offline con datos locales persistentes (SharedPreferences)
/// y sincroniza con Firestore en la nube si hay conexión activa.
class ProjectsProvider with ChangeNotifier {
  static const String _storageKey = 'zentra_projects_storage_v1';

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
    _loadStoredProjects();
    _listenToAuthChanges();
  }

  /// Carga datos persistidos desde SharedPreferences, o precarga los de Tatiana si es la primera vez
  Future<void> _loadStoredProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString(_storageKey);
      if (storedData != null && storedData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(storedData);
        _projects = decoded
            .map((item) => ProjectModel.fromMap(Map<String, dynamic>.from(item), item['id'] ?? ''))
            .toList();
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('Error al leer proyectos de almacenamiento local: $e');
    }

    _loadInitialData();
  }

  /// Guarda la lista actual de proyectos en el almacenamiento del dispositivo
  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _projects.map((p) => p.toMap()).toList();
      await prefs.setString(_storageKey, jsonEncode(data));
    } catch (e) {
      debugPrint('Error al guardar proyectos en almacenamiento local: $e');
    }
  }

  /// Carga los datos por defecto de Tatiana (08-ajustes-tatiana.md)
  void _loadInitialData() {
    final now = DateTime.now();
    _projects = [
      ProjectModel(
        id: 'tatiana-demo-1',
        name: '15 años Maria',
        clientName: 'Maria Rodriguez',
        clientPhone: '3124567890',
        notes: 'Colores Blush y Nude con toques dorados. Cuidado con las esquinas.',
        deliveryDate: now.add(const Duration(days: 2)), // Pronto a vencer
        status: 'En Producción',
        services: ['50 Invitaciones (\$150.000)', '10 Centros de mesa (\$250.000)'],
        totalPrice: 400000.0,
        tasks: [
          ProjectTaskModel(id: 't-1', title: 'Comprar cartulina blush y cinta oro', isCompleted: true),
          ProjectTaskModel(id: 't-2', title: 'Imprimir 50 invitaciones', isCompleted: true),
          ProjectTaskModel(id: 't-3', title: 'Armar centros de mesa con flor seca', isCompleted: false),
          ProjectTaskModel(id: 't-4', title: 'Empacar con etiqueta de entrega', isCompleted: false),
        ],
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
        clientPhone: '3009876543',
        notes: 'Temática angelical en tonos pastel.',
        deliveryDate: now.add(const Duration(days: 8)),
        status: 'En Diseño',
        services: ['Banderines (\$80.000)', 'Invitaciones (\$150.000)'],
        totalPrice: 230000.0,
        tasks: [
          ProjectTaskModel(id: 't-5', title: 'Diseñar boceto de banderines en Canva', isCompleted: true),
          ProjectTaskModel(id: 't-6', title: 'Comprar cintas celestes', isCompleted: false),
        ],
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
    _saveToLocalStorage();
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
    await _saveToLocalStorage();
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
      await _saveToLocalStorage();
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

  Future<void> deleteProject(String projectId) async {
    _projects.removeWhere((p) => p.id == projectId);
    await _saveToLocalStorage();
    notifyListeners();

    final firestore = _firestore;
    if (firestore != null) {
      try {
        await firestore.collection('projects').doc(projectId).delete();
      } catch (e) {
        debugPrint('Borrado localmente: $e');
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

  // Gestión de tareas del proyecto (Checklist)
  Future<void> addTask(String projectId, String title) async {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      final project = _projects[index];
      final newTask = ProjectTaskModel(
        id: 'task_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        isCompleted: false,
      );
      final updatedTasks = List<ProjectTaskModel>.from(project.tasks)..add(newTask);
      await updateProject(project.copyWith(tasks: updatedTasks));
    }
  }

  Future<void> toggleTask(String projectId, String taskId) async {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      final project = _projects[index];
      final updatedTasks = project.tasks.map((t) {
        if (t.id == taskId) {
          return t.copyWith(isCompleted: !t.isCompleted);
        }
        return t;
      }).toList();
      await updateProject(project.copyWith(tasks: updatedTasks));
    }
  }

  Future<void> deleteTask(String projectId, String taskId) async {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      final project = _projects[index];
      final updatedTasks = project.tasks.where((t) => t.id != taskId).toList();
      await updateProject(project.copyWith(tasks: updatedTasks));
    }
  }
}
