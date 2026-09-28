import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/project_model.dart';
import '../providers/projects_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_selector_modal.dart';

/// Pantalla de Detalle de Proyecto en Zentra.
/// Integra el cálculo de Ganancia Real = Cobrado - Gastos, registro de abonos,
/// control de insumos y cambio interactivo de estados.
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
                labelText: 'Descripción del gasto',
                hintText: 'Ej: Cartulinas, cintas, papel',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Valor del gasto (\$ COP)',
                prefixIcon: Icon(Icons.attach_money),
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
              if (descController.text.isNotEmpty && amount > 0) {
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
                  labelText: 'Monto abonado (\$ COP)',
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
                  DropdownMenuItem(value: 'Bancolombia / Transferencia', child: Text('Transferencia')),
                ],
                onChanged: (val) => setState(() => method = val!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Nota (opcional)',
                  hintText: 'Ej: Anticipo 40%',
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
                tooltip: 'Compartir cotización',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Compartir por WhatsApp con ${currentProject.clientName}...'),
                      backgroundColor: theme.success,
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Tarjeta de Estado y Entrega
                _buildStatusCard(context, provider, currentProject),
                const SizedBox(height: 16),

                // 2. Tarjeta de Rentabilidad y Finanzas
                _buildFinancialCard(context, currentProject, currencyFormatter, theme),
                const SizedBox(height: 16),

                // 3. Tarjeta de Servicios
                _buildServicesCard(context, currentProject),
                const SizedBox(height: 16),

                // 4. Módulo de Gastos del Proyecto
                _buildExpensesCard(context, provider, currentProject, currencyFormatter),
                const SizedBox(height: 16),

                // 5. Módulo de Pagos / Abonos
                _buildPaymentsCard(context, provider, currentProject, currencyFormatter),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(BuildContext context, ProjectsProvider provider, ProjectModel project) {
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
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.event_outlined, size: 16, color: Color(0xFF5C4A3E)),
                          const SizedBox(width: 4),
                          Text(
                            'Entrega: ${DateFormat('dd/MM/yyyy').format(project.deliveryDate)}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE07A5F).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber, size: 16, color: Color(0xFFE07A5F)),
                        const SizedBox(width: 4),
                        Text(
                          diffDays == 0 ? '¡VENCE HOY!' : 'Vence en $diffDays días',
                          style: const TextStyle(
                            color: Color(0xFFE07A5F),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
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
                        .map((st) => DropdownMenuItem(value: st, child: Text(st)))
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
    dynamic theme,
  ) {
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
            Text(
              'Cálculo de Ganancia Real',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
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
            if (project.pendingBalance > 0) ...[
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Saldo pendiente por cobrar:'),
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
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesCard(BuildContext context, ProjectModel project) {
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
                      const Icon(Icons.check_circle_outline, color: Color(0xFFD4A5A5), size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(service)),
                    ],
                  ),
                ),
              ),
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
                  title: Text(expense.description, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(expense.date)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '-${formatter.format(expense.amount)}',
                        style: const TextStyle(color: Color(0xFFE07A5F), fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                        tooltip: 'Eliminar gasto',
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
                  leading: const Icon(Icons.payments_outlined, color: Color(0xFFA3B18A)),
                  title: Text(
                    '${pay.paymentMethod}${pay.notes.isNotEmpty ? ' (${pay.notes})' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(pay.date)),
                  trailing: Text(
                    '+${formatter.format(pay.amount)}',
                    style: const TextStyle(color: Color(0xFFA3B18A), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
