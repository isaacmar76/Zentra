import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/project_model.dart';
import '../providers/projects_provider.dart';
import '../utils/quote_share_helper.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_selector_modal.dart';

/// Pantalla de Detalle de Proyecto en Zentra.
/// Integra el cálculo de Ganancia Real = Cobrado - Gastos, registro de abonos,
/// control de insumos, tareas/checklist, y envío de cotizaciones por WhatsApp.
class ProjectDetailScreen extends StatelessWidget {
  final ProjectModel project;

  const ProjectDetailScreen({
    super.key,
    required this.project,
  });

  final List<String> _estados = const [
    'En Diseño',
    'En Producción',
    'Listo para Entregar',
    'Entregado',
  ];

  void _showAddExpenseDialog(BuildContext context, ProjectsProvider provider, String projectId) {
    final descController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar Gasto / Insumo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Descripción del gasto *',
                hintText: 'Ej: Cartulinas, cintas, papel fotográfico',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Valor del gasto (\$ COP) *',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Regla de Oro: El gasto se restará directamente de la ganancia real del encargo.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(
                amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
              ) ?? 0.0;
              if (descController.text.trim().isNotEmpty && amount > 0) {
                final newExpense = ProjectExpenseModel(
                  id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
                  description: descController.text.trim(),
                  amount: amount,
                  date: DateTime.now(),
                );
                provider.addExpense(projectId, newExpense);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gasto registrado exitosamente')),
                );
              }
            },
            child: const Text('GUARDAR GASTO'),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentDialog(BuildContext context, ProjectsProvider provider, String projectId) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String method = 'Nequi';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Registrar Abono o Pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto abonado (\$ COP) *',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: method,
                decoration: const InputDecoration(labelText: 'Método de pago'),
                items: const [
                  DropdownMenuItem(value: 'Nequi', child: Text('Nequi')),
                  DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                  DropdownMenuItem(value: 'Daviplata', child: Text('Daviplata')),
                  DropdownMenuItem(value: 'Bancolombia', child: Text('Bancolombia')),
                  DropdownMenuItem(value: 'Transferencia', child: Text('Otra Transferencia')),
                ],
                onChanged: (val) => setState(() => method = val!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Nota (opcional)',
                  hintText: 'Ej: Anticipo 50%, Saldo final',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(
                  amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
                ) ?? 0.0;
                if (amount > 0) {
                  final newPayment = ProjectPaymentModel(
                    id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
                    amount: amount,
                    paymentMethod: method,
                    date: DateTime.now(),
                    notes: noteController.text.trim(),
                  );
                  provider.addPayment(projectId, newPayment);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pago registrado exitosamente')),
                  );
                }
              },
              child: const Text('REGISTRAR PAGO'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, ProjectsProvider provider, String projectId) {
    final taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva Tarea'),
        content: TextField(
          controller: taskController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Descripción de la tarea',
            hintText: 'Ej: Comprar cinta dorada, Enviar boceto',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              if (taskController.text.trim().isNotEmpty) {
                provider.addTask(projectId, taskController.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('AGREGAR TAREA'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProject(BuildContext context, ProjectsProvider provider, String projectId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar Proyecto?'),
        content: const Text('Esta acción eliminará el encargo, sus gastos y sus pagos registrados de forma permanente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE07A5F)),
            onPressed: () {
              provider.deleteProject(projectId);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Proyecto eliminado')),
              );
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectsProvider>(
      builder: (context, provider, child) {
        final currentProject = provider.projects.firstWhere(
          (p) => p.id == project.id,
          orElse: () => project,
        );

        final currencyFormatter = NumberFormat.currency(
          locale: 'es_CO',
          symbol: '\$',
          decimalDigits: 0,
        );

        final theme = context.watch<ThemeProvider>().currentPalette;

        return Scaffold(
          appBar: AppBar(
            title: Text(currentProject.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.palette_outlined),
                tooltip: 'Cambiar apariencia (${theme.name})',
                onPressed: () => showZentraThemeSelector(context),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Compartir cotización por WhatsApp',
                onPressed: () => QuoteShareHelper.showShareModal(context, currentProject),
              ),
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'delete') {
                    _confirmDeleteProject(context, provider, currentProject.id);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Color(0xFFE07A5F), size: 20),
                        SizedBox(width: 8),
                        Text('Eliminar Proyecto', style: TextStyle(color: Color(0xFFE07A5F))),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Tarjeta de Estado y Cliente
                _buildStatusCard(context, provider, currentProject, theme),
                const SizedBox(height: 14),

                // 2. Tarjeta de Rentabilidad y Ganancia Real
                _buildFinancialCard(context, currentProject, currencyFormatter, theme),
                const SizedBox(height: 14),

                // 3. Tareas / Checklist del Proyecto
                _buildTasksCard(context, provider, currentProject, theme),
                const SizedBox(height: 14),

                // 4. Servicios Incluidos
                _buildServicesCard(context, currentProject, theme),
                const SizedBox(height: 14),

                // 5. Módulo de Gastos del Proyecto (Regla de oro: solo borrar)
                _buildExpensesCard(context, provider, currentProject, currencyFormatter, theme),
                const SizedBox(height: 14),

                // 6. Módulo de Pagos / Abonos
                _buildPaymentsCard(context, provider, currentProject, currencyFormatter, theme),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    ProjectsProvider provider,
    ProjectModel project,
    ZentraThemePalette theme,
  ) {
    final now = DateTime.now();
    final diffDays = project.deliveryDate.difference(now).inDays;
    final isUrgent = diffDays >= 0 && diffDays <= 3 && project.status != 'Entregado';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.clientName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                      ),
                      if (project.clientPhone.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Row(
                            children: [
                              Icon(Icons.phone_android, size: 14, color: theme.secondary),
                              const SizedBox(width: 4),
                              Text(
                                project.clientPhone,
                                style: TextStyle(color: theme.secondary, fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.event_outlined, size: 15, color: theme.textDark),
                          const SizedBox(width: 4),
                          Text(
                            'Entrega: ${DateFormat('dd/MM/yyyy').format(project.deliveryDate)}',
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => QuoteShareHelper.showShareModal(context, project),
                  icon: const Icon(Icons.share, size: 16, color: Colors.white),
                  label: const Text('WhatsApp', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            if (isUrgent) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.alert.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: theme.alert),
                    const SizedBox(width: 6),
                    Text(
                      diffDays == 0 ? '¡ENTREGA HOY!' : 'Vence en $diffDays días',
                      style: TextStyle(
                        color: theme.alert,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Divider(height: 22),
            Row(
              children: [
                const Text('Estado: ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: project.status,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _estados
                        .map((st) => DropdownMenuItem(value: st, child: Text(st, style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        provider.updateStatus(project.id, val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard(
    BuildContext context,
    ProjectModel project,
    NumberFormat formatter,
    ZentraThemePalette theme,
  ) {
    final progressPct = (project.paymentProgress * 100).toInt();

    return Card(
      color: theme.background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.primary, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cálculo de Ganancia Real',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: project.netProfit >= 0 ? theme.success.withOpacity(0.2) : theme.alert.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    project.netProfit >= 0 ? 'Rentable' : 'En Déficit',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: project.netProfit >= 0 ? theme.success : theme.alert,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Total Cobrado', formatter.format(project.totalPaid), theme.success),
                _buildStatItem('Total Gastos', formatter.format(project.totalExpenses), theme.alert),
                _buildStatItem('Ganancia Neta', formatter.format(project.netProfit), theme.textDark, isBold: true),
              ],
            ),
            const SizedBox(height: 14),

            // Barra de progreso de pago
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Avance del Cobro ($progressPct%)', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                    Text('Total: ${formatter.format(project.totalPrice)}', style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: project.paymentProgress,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.secondary),
                    minHeight: 8,
                  ),
                ),
              ],
            ),

            if (project.pendingBalance > 0) ...[
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Saldo pendiente por cobrar:', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text(
                    formatter.format(project.pendingBalance),
                    style: TextStyle(fontWeight: FontWeight.bold, color: theme.alert),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF5C4A3E))),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTasksCard(
    BuildContext context,
    ProjectsProvider provider,
    ProjectModel project,
    ZentraThemePalette theme,
  ) {
    final completedCount = project.tasks.where((t) => t.isCompleted).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Tareas & Checklist', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                    const SizedBox(width: 8),
                    if (project.tasks.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$completedCount/${project.tasks.length}',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.textDark),
                        ),
                      ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _showAddTaskDialog(context, provider, project.id),
                  icon: const Icon(Icons.add_task, size: 18),
                  label: const Text('+ Tarea'),
                ),
              ],
            ),
            const Divider(height: 12),
            if (project.tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Sin tareas asignadas. Toca "+ Tarea" para crear tu checklist.'),
              )
            else
              ...project.tasks.map(
                (task) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  value: task.isCompleted,
                  activeColor: theme.secondary,
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? Colors.grey : theme.textDark,
                      fontWeight: task.isCompleted ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                  secondary: IconButton(
                    icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                    tooltip: 'Eliminar tarea',
                    onPressed: () => provider.deleteTask(project.id, task.id),
                  ),
                  onChanged: (_) => provider.toggleTask(project.id, task.id),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesCard(BuildContext context, ProjectModel project, ZentraThemePalette theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Servicios del Proyecto', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
            const Divider(height: 16),
            if (project.services.isEmpty)
              const Text('No se seleccionaron servicios.')
            else
              ...project.services.map(
                (service) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: theme.secondary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(service, style: const TextStyle(fontSize: 13.5))),
                    ],
                  ),
                ),
              ),
            if (project.notes.isNotEmpty) ...[
              const Divider(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.sticky_note_2_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Notas: ${project.notes}',
                      style: const TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesCard(
    BuildContext context,
    ProjectsProvider provider,
    ProjectModel project,
    NumberFormat formatter,
    ZentraThemePalette theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Gastos / Insumos', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                TextButton.icon(
                  onPressed: () => _showAddExpenseDialog(context, provider, project.id),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('+ Gasto'),
                ),
              ],
            ),
            const Divider(height: 12),
            if (project.expenses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Sin gastos registrados. Toca "+ Gasto" para restar costos de insumos.'),
              )
            else
              ...project.expenses.map(
                (expense) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(expense.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(expense.date), style: const TextStyle(fontSize: 11)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '-${formatter.format(expense.amount)}',
                        style: TextStyle(color: theme.alert, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                        tooltip: 'Eliminar gasto (Regla de oro: solo borrar)',
                        onPressed: () => provider.deleteExpense(project.id, expense.id),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsCard(
    BuildContext context,
    ProjectsProvider provider,
    ProjectModel project,
    NumberFormat formatter,
    ZentraThemePalette theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pagos y Abonos', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                TextButton.icon(
                  onPressed: () => _showAddPaymentDialog(context, provider, project.id),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('+ Abono'),
                ),
              ],
            ),
            const Divider(height: 12),
            if (project.payments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Sin pagos registrados. Registra anticipos con "+ Abono".'),
              )
            else
              ...project.payments.map(
                (pay) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Icon(Icons.check_circle, color: theme.success, size: 20),
                  title: Text(
                    '${pay.paymentMethod}${pay.notes.isNotEmpty ? ' (${pay.notes})' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(pay.date), style: const TextStyle(fontSize: 11)),
                  trailing: Text(
                    '+${formatter.format(pay.amount)}',
                    style: TextStyle(color: theme.success, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
