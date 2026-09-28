import 'package:flutter/material.dart';
import '../../../core/layout/main_layout_screen.dart';
import '../../retail/screens/retail_main_screen.dart';

import '../../../core/theme/theme_selector_modal.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  void _selectMode(BuildContext context, String mode) {
    if (mode == 'SERVICIOS') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainLayoutScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RetailMainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración Inicial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Cambiar apariencia',
            onPressed: () => showZentraThemeSelector(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '¿Cómo trabaja tu negocio?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Selecciona el modo que mejor se adapte a tus necesidades. (Por defecto es SERVICIOS para Tatiana).',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              Expanded(
                child: ListView(
                  children: [
                    _buildModeCard(
                      context,
                      title: 'RETAIL',
                      subtitle: 'Tienda, Minimercado, Papelería de venta directa',
                      icon: Icons.storefront,
                      onTap: () => _selectMode(context, 'RETAIL'),
                    ),
                    const SizedBox(height: 24),
                    _buildModeCard(
                      context,
                      title: 'SERVICIOS',
                      subtitle: 'Papelería Creativa, Salón de Belleza, Catering',
                      icon: Icons.design_services_outlined,
                      onTap: () => _selectMode(context, 'SERVICIOS'),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Por defecto selecciona Servicios y continua
                  _selectMode(context, 'SERVICIOS');
                },
                child: const Text('CONTINUAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EFE6), // backgroundNude
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: const Color(0xFFD4A5A5), // secondaryBlush
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF5C4A3E), // textDark
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFFD4A5A5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
