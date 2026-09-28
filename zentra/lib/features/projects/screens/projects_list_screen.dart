import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/projects_provider.dart';
import 'new_project_screen.dart';
import 'project_detail_screen.dart';

import '../../../core/theme/theme_provider.dart';

class ProjectsListScreen extends StatelessWidget {
  const ProjectsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentPalette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyectos'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<ProjectsProvider>(
        builder: (context, provider, child) {
          if (provider.projects.isEmpty) {
            return const Center(
              child: Text('No hay proyectos creados aún.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.projects.length,
            itemBuilder: (context, index) {
              final project = provider.projects[index];
              final isDelivered = project.status == 'Entregado';
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    project.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Cliente: ${project.clientName}'),
                      const SizedBox(height: 4),
                      Text('Entrega: ${DateFormat('dd/MM/yyyy').format(project.deliveryDate)}'),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDelivered 
                          ? theme.success.withOpacity(0.2)
                          : theme.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      project.status,
                      style: TextStyle(
                        color: theme.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProjectDetailScreen(project: project),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NewProjectScreen(),
            ),
          );
        },
        backgroundColor: theme.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
