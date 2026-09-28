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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSummaryCards(context, provider, currencyFormatter, theme),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NewProjectScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('NUEVO PROYECTO'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.secondary,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _showUrgentOrdersModal(context, provider),
                  icon: const Icon(Icons.warning_amber_rounded),
                  label: Text(
                    urgentCount > 0
                        ? 'VER PEDIDOS PRONTO A VENCER ($urgentCount)'
                        : 'SIN PEDIDOS URGENTES ($urgentCount)',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.alert,
                    side: BorderSide(color: theme.alert),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
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
    dynamic theme,
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
            const SizedBox(width: 14),
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
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildCard(
                context,
                title: 'Ganancia Real',
                value: formatter.format(provider.gananciaMes),
                color: theme.textDark,
                subtitle: 'Margen neto real',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildCard(
                context,
                title: 'Proyectos Activos',
                value: provider.proyectosActivos.toString(),
                color: theme.secondary,
                subtitle: 'En proceso',
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
