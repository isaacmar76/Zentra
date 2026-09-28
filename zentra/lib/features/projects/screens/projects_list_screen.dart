import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/project_model.dart';
import '../providers/projects_provider.dart';
import 'new_project_screen.dart';
import 'project_detail_screen.dart';
import '../utils/quote_share_helper.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_selector_modal.dart';

class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  String _selectedFilter = 'Todos';
  String _searchQuery = '';

  final List<String> _filters = const [
    'Todos',
    'En Diseño',
    'En Producción',
    'Listo para Entregar',
    'Entregados',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentPalette;
    final currencyFormatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyectos & Encargos'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Cambiar apariencia (${theme.name})',
            onPressed: () => showZentraThemeSelector(context),
          ),
        ],
      ),
      body: Consumer<ProjectsProvider>(
        builder: (context, provider, child) {
          // Filtrado por estado
          var filtered = provider.projects.where((p) {
            if (_selectedFilter == 'Todos') return true;
            if (_selectedFilter == 'Entregados') return p.status == 'Entregado';
            return p.status == _selectedFilter;
          }).toList();

          // Filtrado por buscador
          if (_searchQuery.trim().isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            filtered = filtered.where((p) {
              return p.name.toLowerCase().contains(query) ||
                  p.clientName.toLowerCase().contains(query) ||
                  p.clientPhone.contains(query);
            }).toList();
          }

          return Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por proyecto o cliente...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: theme.primary),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),

              // Chips de filtros
              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;

                    return ChoiceChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : theme.textDark,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: theme.secondary,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isSelected ? theme.secondary : theme.primary),
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedFilter = filter);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Lista de Proyectos
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open_outlined, size: 56, color: theme.secondary.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            Text(
                              provider.projects.isEmpty
                                  ? 'Aún no tienes proyectos.'
                                  : 'No hay proyectos con ese filtro.',
                              style: TextStyle(fontSize: 15, color: theme.textDark),
                            ),
                            const SizedBox(height: 8),
                            if (provider.projects.isEmpty)
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const NewProjectScreen()),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('CREAR PRIMER PROYECTO'),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final project = filtered[index];
                          final isDelivered = project.status == 'Entregado';
                          final diffDays = project.deliveryDate.difference(DateTime.now()).inDays;
                          final isUrgent = diffDays >= 0 && diffDays <= 3 && !isDelivered;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProjectDetailScreen(project: project),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            project.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isDelivered
                                                ? theme.success.withOpacity(0.18)
                                                : theme.secondary.withOpacity(0.18),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            project.status,
                                            style: TextStyle(
                                              color: theme.textDark,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Cliente: ${project.clientName}${project.clientPhone.isNotEmpty ? " • ${project.clientPhone}" : ""}',
                                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.event, size: 14, color: isUrgent ? theme.alert : Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Entrega: ${DateFormat('dd/MM/yyyy').format(project.deliveryDate)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
                                            color: isUrgent ? theme.alert : Colors.grey.shade700,
                                          ),
                                        ),
                                        if (isUrgent) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: theme.alert.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              diffDays == 0 ? '¡Hoy!' : 'En ${diffDays}d',
                                              style: TextStyle(
                                                color: theme.alert,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const Divider(height: 18),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Cotizado: ${currencyFormatter.format(project.totalPrice)}',
                                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                                            ),
                                            Text(
                                              project.pendingBalance > 0
                                                  ? 'Saldo: ${currencyFormatter.format(project.pendingBalance)}'
                                                  : '¡Pagado al 100%!',
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.bold,
                                                color: project.pendingBalance > 0 ? theme.alert : theme.success,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.share, size: 20, color: Color(0xFF25D366)),
                                              tooltip: 'Compartir cotización por WhatsApp',
                                              onPressed: () => QuoteShareHelper.showShareModal(context, project),
                                            ),
                                            const Icon(Icons.chevron_right, color: Colors.grey),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NewProjectScreen(),
            ),
          );
        },
        backgroundColor: theme.secondary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('NUEVO PROYECTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
