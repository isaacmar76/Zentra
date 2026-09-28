import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../projects/providers/projects_provider.dart';
import '../../projects/screens/new_project_screen.dart';
import '../../projects/screens/project_detail_screen.dart';
import '../../mode_selection/screens/mode_selection_screen.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_selector_modal.dart';

class DashboardServicesScreen extends StatelessWidget {
  const DashboardServicesScreen({super.key});

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

    final currencyFormatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zentra - Papelería Creativa'),
        automaticallyImplyLeading: false,
        actions: [
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Tarjetas de métricas
                _buildSummaryCards(context, provider, currencyFormatter, theme),
                const SizedBox(height: 20),

                // 2. Botones de acción principales
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
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
                const SizedBox(height: 12),
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 26),

                // 3. Proyectos en curso (Acceso rápido para Tatiana)
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
                      padding: const EdgeInsets.all(24.0),
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
                title: 'Ingresos Mes',
                value: formatter.format(provider.ingresosMes),
                color: theme.success,
                subtitle: 'Abonos cobrados',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCard(
                context,
                title: 'Gastos Insumos',
                value: formatter.format(provider.gastosMes),
                color: theme.alert,
                subtitle: 'Costos deducidos',
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
                title: 'Ganancia Real',
                value: formatter.format(provider.gananciaMes),
                color: theme.textDark,
                subtitle: 'Cobrado - Gastos',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCard(
                context,
                title: 'Proyectos Activos',
                value: provider.proyectosActivos.toString(),
                color: theme.secondary,
                subtitle: 'En taller',
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
