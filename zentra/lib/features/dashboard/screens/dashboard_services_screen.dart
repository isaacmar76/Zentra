import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../projects/models/general_transaction_model.dart';
import '../../projects/providers/projects_provider.dart';
import '../../projects/screens/new_project_screen.dart';
import '../../projects/screens/project_detail_screen.dart';
import '../../mode_selection/screens/mode_selection_screen.dart';
import '../../profile/providers/business_profile_provider.dart';
import '../../profile/screens/business_profile_screen.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_selector_modal.dart';

class DashboardServicesScreen extends StatelessWidget {
  const DashboardServicesScreen({super.key});

  void _showAddGeneralTransactionDialog(
    BuildContext context,
    ProjectsProvider provider, {
    required bool isExpense,
  }) {
    final amountController = TextEditingController();
    final descController = TextEditingController();
    String category = isExpense ? 'Arriendo' : 'Venta Extra';
    String method = 'Nequi';

    final expenseCategories = [
      'Arriendo',
      'Servicios Públicos',
      'Publicidad / Redes',
      'Transporte / Envíos',
      'Mantenimiento / Equipos',
      'Aseo y Cafetería',
      'Otro Gasto General',
    ];

    final incomeCategories = [
      'Venta Extra',
      'Asesoría de Diseño',
      'Venta de Sobrantes',
      'Otro Ingreso General',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(isExpense ? 'Registrar Gasto General' : 'Registrar Otro Ingreso'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isExpense
                      ? 'Gasto independiente del negocio (no pertenece a ningún encargo o proyecto específico).'
                      : 'Ingreso extraordinario del negocio no atado a un proyecto específico.',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Valor (\$ COP) *',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: isExpense ? 'Concepto del gasto *' : 'Concepto del ingreso *',
                    hintText: isExpense ? 'Ej: Arriendo mensual taller, Luz, Internet' : 'Ej: Venta de retazos de papel',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: (isExpense ? expenseCategories : incomeCategories)
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (val) => setState(() => category = val!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: method,
                  decoration: const InputDecoration(labelText: 'Medio de pago'),
                  items: const [
                    DropdownMenuItem(value: 'Nequi', child: Text('Nequi')),
                    DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                    DropdownMenuItem(value: 'Daviplata', child: Text('Daviplata')),
                    DropdownMenuItem(value: 'Transferencia', child: Text('Bancolombia / Transf.')),
                  ],
                  onChanged: (val) => setState(() => method = val!),
                ),
              ],
            ),
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
                  final tx = GeneralTransactionModel(
                    id: 'gen_${DateTime.now().millisecondsSinceEpoch}',
                    type: isExpense ? GeneralTransactionType.gasto : GeneralTransactionType.ingreso,
                    category: category,
                    description: descController.text.trim(),
                    amount: amount,
                    date: DateTime.now(),
                    paymentMethod: method,
                  );
                  provider.addGeneralTransaction(tx);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isExpense ? 'Gasto general registrado' : 'Ingreso general registrado'),
                    ),
                  );
                }
              },
              child: Text(isExpense ? 'GUARDAR GASTO' : 'GUARDAR INGRESO'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFinancialBreakdownModal(
    BuildContext context,
    ProjectsProvider provider,
    NumberFormat formatter,
    ZentraThemePalette theme,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Desglose Financiero Global',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildBreakdownRow('Abonos de Proyectos:', formatter.format(provider.ingresosProyectos), theme.success),
            _buildBreakdownRow('Otros Ingresos Generales:', formatter.format(provider.ingresosGenerales), theme.success),
            const Divider(),
            _buildBreakdownRow('Compras de Insumos (Proyectos):', '-${formatter.format(provider.comprasProyectos)}', theme.alert),
            _buildBreakdownRow('Gastos Generales (Negocio):', '-${formatter.format(provider.gastosGenerales)}', theme.alert),
            const Divider(thickness: 1.5),
            _buildBreakdownRow(
              'GANANCIA NETA REAL:',
              formatter.format(provider.gananciaNetaGlobal),
              theme.textDark,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w500, fontSize: 13.5)),
          Text(
            value,
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: color, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showUrgentOrdersModal(BuildContext context, ProjectsProvider provider) {
    final urgentProjects = provider.pedidosProntoAVencer;
    final theme = context.read<ThemeProvider>().currentPalette;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: theme.alert, size: 28),
                const SizedBox(width: 10),
                Text(
                  'Pedidos Pronto a Vencer',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: theme.alert),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${urgentProjects.length} pedidos vencen en los próximos 3 días:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Divider(height: 24),
            if (urgentProjects.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text('¡Excelente! No tienes pedidos atrasados ni por vencer.'),
                ),
              )
            else
              ...urgentProjects.map((p) {
                final diff = p.deliveryDate.difference(DateTime.now()).inDays;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: theme.alert.withOpacity(0.15),
                    child: Text(
                      diff == 0 ? 'Hoy' : '${diff}d',
                      style: TextStyle(
                        color: theme.alert,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Cliente: ${p.clientName} • Entrega: ${DateFormat('dd/MM/yyyy').format(p.deliveryDate)}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProjectDetailScreen(project: p),
                      ),
                    );
                  },
                );
              }),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: theme.secondary),
              child: const Text('ENTENDIDO'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = themeProvider.currentPalette;
    final businessProfile = context.watch<BusinessProfileProvider>().profile;

    final currencyFormatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              businessProfile.businessName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Modo Servicios • Zentra',
              style: TextStyle(fontSize: 11, color: theme.secondary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront_outlined),
            tooltip: 'Datos del Negocio (Nombre, Logo, Cuentas)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BusinessProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Cambiar tema (${theme.name})',
            onPressed: () => showZentraThemeSelector(context),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: 'Cambiar de modo',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ModeSelectionScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProjectsProvider>(
        builder: (context, provider, child) {
          final urgentCount = provider.pedidosProntoAVencer.length;
          final activeProjects = provider.projects.where((p) => p.status != 'Entregado').toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Tarjetas de métricas consolidadas
                InkWell(
                  onTap: () => _showFinancialBreakdownModal(context, provider, currencyFormatter, theme),
                  borderRadius: BorderRadius.circular(20),
                  child: _buildSummaryCards(context, provider, currencyFormatter, theme),
                ),
                const SizedBox(height: 18),

                // 2. Botón principal: Nuevo Proyecto
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NewProjectScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  label: const Text('NUEVO PROYECTO', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 10),

                // 3. Fila de Gastos e Ingresos Generales (Independientes de proyectos)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddGeneralTransactionDialog(context, provider, isExpense: true),
                        icon: Icon(Icons.receipt_long_outlined, size: 18, color: theme.alert),
                        label: const Text('+ Gasto General', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.alert,
                          side: BorderSide(color: theme.alert.withOpacity(0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddGeneralTransactionDialog(context, provider, isExpense: false),
                        icon: Icon(Icons.add_card, size: 18, color: theme.success),
                        label: const Text('+ Otro Ingreso', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.success,
                          side: BorderSide(color: theme.success.withOpacity(0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 4. Pedidos por vencer
                OutlinedButton.icon(
                  onPressed: () => _showUrgentOrdersModal(context, provider),
                  icon: Icon(Icons.warning_amber_rounded, color: theme.alert),
                  label: Text(
                    urgentCount > 0
                        ? 'VER PEDIDOS PRONTO A VENCER ($urgentCount)'
                        : 'SIN PEDIDOS URGENTES ($urgentCount)',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.alert,
                    side: BorderSide(color: theme.alert, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),

                // 5. Proyectos en curso
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Encargos en Curso (${activeProjects.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                    ),
                    Text(
                      'Prioridad',
                      style: TextStyle(fontSize: 12, color: theme.secondary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (activeProjects.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          'No hay encargos activos en este momento.',
                          style: TextStyle(color: theme.textDark),
                        ),
                      ),
                    ),
                  )
                else
                  ...activeProjects.take(3).map((p) {
                    final diff = p.deliveryDate.difference(DateTime.now()).inDays;
                    final isUrgent = diff >= 0 && diff <= 3;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: p)),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundColor: isUrgent ? theme.alert.withOpacity(0.15) : theme.primary.withOpacity(0.3),
                          child: Icon(
                            isUrgent ? Icons.access_time_filled : Icons.brush_outlined,
                            color: isUrgent ? theme.alert : theme.secondary,
                            size: 20,
                          ),
                        ),
                        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('${p.clientName} • ${DateFormat('dd/MM').format(p.deliveryDate)}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              p.status,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.secondary),
                            ),
                            Text(
                              p.pendingBalance > 0 ? 'Debe: ${currencyFormatter.format(p.pendingBalance)}' : 'Al día',
                              style: TextStyle(
                                fontSize: 11,
                                color: p.pendingBalance > 0 ? theme.alert : theme.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 20),

                // 6. Gastos Generales Recientes
                if (provider.generalTransactions.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gastos & Movimientos del Negocio',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15),
                      ),
                      Text(
                        'Independientes',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: provider.generalTransactions.take(3).map((tx) {
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: tx.isExpense ? theme.alert.withOpacity(0.15) : theme.success.withOpacity(0.15),
                              child: Icon(
                                tx.isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                                size: 16,
                                color: tx.isExpense ? theme.alert : theme.success,
                              ),
                            ),
                            title: Text(tx.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            subtitle: Text('${tx.category} • ${DateFormat('dd/MM').format(tx.date)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tx.isExpense ? '-${currencyFormatter.format(tx.amount)}' : '+${currencyFormatter.format(tx.amount)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                    color: tx.isExpense ? theme.alert : theme.success,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.grey),
                                  onPressed: () => provider.deleteGeneralTransaction(tx.id),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    ProjectsProvider provider,
    NumberFormat formatter,
    ZentraThemePalette theme,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCard(
                context,
                title: 'Ingresos Totales',
                value: formatter.format(provider.totalIngresosGlobal),
                color: theme.success,
                subtitle: 'Proyectos + Otros',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCard(
                context,
                title: 'Gastos Totales',
                value: formatter.format(provider.totalGastosGlobal),
                color: theme.alert,
                subtitle: 'Compras + Generales',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCard(
                context,
                title: 'Ganancia Neta Real',
                value: formatter.format(provider.gananciaNetaGlobal),
                color: theme.textDark,
                subtitle: 'Ingresos - Gastos',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCard(
                context,
                title: 'Proyectos Activos',
                value: provider.proyectosActivos.toString(),
                color: theme.secondary,
                subtitle: 'Tocar para desglose',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10.5, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
