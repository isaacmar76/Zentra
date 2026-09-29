import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/layout/main_layout_screen.dart';
import '../../retail/screens/retail_main_screen.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_selector_modal.dart';
import '../../profile/providers/business_profile_provider.dart';
import '../../projects/providers/projects_provider.dart';
import '../../inventory/providers/inventory_provider.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  final _nameController = TextEditingController();
  final _ownerController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedMode = 'SERVICIOS'; // 'SERVICIOS' o 'RETAIL'

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _crearNegocio() async {
    final name = _nameController.text.trim();
    final owner = _ownerController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || owner.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor escribe el nombre del negocio y tu nombre.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final profileProvider = context.read<BusinessProfileProvider>();
    final projectsProvider = context.read<ProjectsProvider>();
    final inventoryProvider = context.read<InventoryProvider>();

    // Inicializar perfil comercial y modalidad fija
    final updated = profileProvider.profile.copyWith(
      businessName: name,
      ownerName: owner,
      phone: phone,
      businessType: _selectedMode,
      isConfigured: true,
    );
    await profileProvider.updateProfile(updated);

    // Asegurar que las listas comiencen completamente limpias
    await projectsProvider.clearAllProjects();
    await inventoryProvider.clearAllInventory();

    if (!mounted) return;

    if (_selectedMode == 'SERVICIOS') {
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
    final theme = context.watch<ThemeProvider>().currentPalette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear mi Negocio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Cambiar apariencia',
            onPressed: () => showZentraThemeSelector(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Icon(Icons.storefront_outlined, size: 56, color: theme.secondary),
              const SizedBox(height: 12),
              Text(
                'Bienvenido a ZENTRA',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Configura los datos iniciales de tu comercio. La aplicación se adaptará exclusivamente a la modalidad que elijas.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de tu Negocio / Marca *',
                  hintText: 'Ej: Mi Taller Creativo, Tienda El Carmen',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ownerController,
                decoration: const InputDecoration(
                  labelText: 'Tu Nombre (Propietario/a) *',
                  hintText: 'Ej: María Gómez',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono WhatsApp (Opcional)',
                  hintText: 'Ej: 312 345 6789',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Selecciona tu Modelo de Negocio *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'De aquí en adelante la app funcionará bajo este modelo:',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 14),
              _buildSelectableModeCard(
                modeKey: 'SERVICIOS',
                title: 'SERVICIOS / POR ENCARGO',
                subtitle: 'Papelería creativa, confección, talleres, eventos, catering, encargos personalizados.\n• Control de proyectos por cliente\n• Compras de insumos y abonos\n• Cotizaciones directas a WhatsApp',
                icon: Icons.design_services_outlined,
                theme: theme,
              ),
              const SizedBox(height: 12),
              _buildSelectableModeCard(
                modeKey: 'RETAIL',
                title: 'RETAIL / MOSTRADOR',
                subtitle: 'Tienda de abarrotes, minimercado, papelería de venta directa.\n• Punto de Venta (POS) rápido\n• Carrito y control de inventario\n• Registro diario de caja',
                icon: Icons.storefront,
                theme: theme,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _crearNegocio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'CREAR MI NEGOCIO Y COMENZAR',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectableModeCard({
    required String modeKey,
    required String title,
    required String subtitle,
    required IconData icon,
    required dynamic theme,
  }) {
    final isSelected = _selectedMode == modeKey;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMode = modeKey;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? theme.secondary.withOpacity(0.12) : theme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.secondary : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2.2 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? theme.secondary : theme.bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? Colors.white : theme.secondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? theme.textDark : theme.textDark.withOpacity(0.8),
                          ),
                        ),
                      ),
                      Radio<String>(
                        value: modeKey,
                        groupValue: _selectedMode,
                        activeColor: theme.secondary,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedMode = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey[700],
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
