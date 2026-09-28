import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/business_profile_model.dart';
import '../providers/business_profile_provider.dart';
import '../../../core/theme/theme_provider.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _businessNameController;
  late TextEditingController _ownerNameController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _nequiController;
  late TextEditingController _daviplataController;
  late TextEditingController _bancolombiaController;
  late TextEditingController _noteController;

  String _selectedIcon = 'auto_awesome';

  final List<Map<String, dynamic>> _iconOptions = const [
    {'name': 'auto_awesome', 'icon': Icons.auto_awesome, 'label': 'Creativo'},
    {'name': 'brush', 'icon': Icons.brush, 'label': 'Arte'},
    {'name': 'palette', 'icon': Icons.palette, 'label': 'Diseño'},
    {'name': 'celebration', 'icon': Icons.celebration, 'label': 'Fiestas'},
    {'name': 'local_florist', 'icon': Icons.local_florist, 'label': 'Detalles'},
    {'name': 'store', 'icon': Icons.store, 'label': 'Tienda'},
    {'name': 'content_cut', 'icon': Icons.content_cut, 'label': 'Manualidades'},
    {'name': 'favorite', 'icon': Icons.favorite, 'label': 'Amor'},
  ];

  @override
  void initState() {
    super.initState();
    final profile = context.read<BusinessProfileProvider>().profile;
    _businessNameController = TextEditingController(text: profile.businessName);
    _ownerNameController = TextEditingController(text: profile.ownerName);
    _phoneController = TextEditingController(text: profile.phone);
    _cityController = TextEditingController(text: profile.city);
    _nequiController = TextEditingController(text: profile.nequi);
    _daviplataController = TextEditingController(text: profile.daviplata);
    _bancolombiaController = TextEditingController(text: profile.bancolombia);
    _noteController = TextEditingController(text: profile.customNote);
    _selectedIcon = profile.logoIconName;
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _nequiController.dispose();
    _daviplataController.dispose();
    _bancolombiaController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final updated = BusinessProfileModel(
      businessName: _businessNameController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      logoIconName: _selectedIcon,
      nequi: _nequiController.text.trim(),
      daviplata: _daviplataController.text.trim(),
      bancolombia: _bancolombiaController.text.trim(),
      customNote: _noteController.text.trim(),
    );

    context.read<BusinessProfileProvider>().updateProfile(updated);
    Navigator.pop(context);

    final theme = context.read<ThemeProvider>().currentPalette;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¡Datos del negocio actualizados exitosamente!'),
        backgroundColor: theme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentPalette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos del Negocio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado con Ícono/Logo del Negocio
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.primary.withOpacity(0.35),
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.secondary, width: 2),
                      ),
                      child: Icon(
                        _iconOptions.firstWhere(
                          (i) => i['name'] == _selectedIcon,
                          orElse: () => _iconOptions.first,
                        )['icon'] as IconData,
                        size: 40,
                        color: theme.secondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Logotipo / Emblema del Negocio',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.textDark),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: _iconOptions.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (ctx, idx) {
                          final item = _iconOptions[idx];
                          final isSelected = _selectedIcon == item['name'];
                          return InkWell(
                            onTap: () => setState(() => _selectedIcon = item['name']),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected ? theme.secondary : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? theme.secondary : Colors.grey.shade300,
                                ),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: isSelected ? Colors.white : theme.textDark,
                                size: 22,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 1. Identidad Comercial
              Text(
                'Identidad Comercial',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _businessNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Negocio / Marca *',
                  hintText: 'Ej: TM Diseños Creativos, Papelería Doña Juana',
                  prefixIcon: Icon(Icons.storefront_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa el nombre del negocio' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ownerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Propietario(a)',
                        hintText: 'Ej: Tatiana Marín',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono / WhatsApp',
                        hintText: '312 456 7890',
                        prefixIcon: Icon(Icons.phone_android),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Ciudad / Ubicación',
                  hintText: 'Ej: Medellín, Colombia',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Medios de Cobro (Aparecen en el recibo de WhatsApp)
              Text(
                'Cuentas para recibir Pagos de Clientes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 6),
              const Text(
                'Estos datos se incluirán automáticamente en las cotizaciones y recibos compartidos por WhatsApp.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _nequiController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Número Nequi',
                  hintText: '312 456 7890',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _daviplataController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Número Daviplata',
                  hintText: '312 456 7890',
                  prefixIcon: Icon(Icons.phone_iphone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bancolombiaController,
                decoration: const InputDecoration(
                  labelText: 'Cuenta Bancolombia / Otro Banco',
                  hintText: 'Ahorros 123-456789-01',
                  prefixIcon: Icon(Icons.account_balance_outlined),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Mensaje de Despedida
              Text(
                'Mensaje de Agradecimiento',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Mensaje al final de las cotizaciones',
                  hintText: 'Ej: ¡Gracias por confiar en nuestro trabajo! 🌸',
                  prefixIcon: Icon(Icons.chat_bubble_outline),
                ),
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save_rounded, color: Colors.white),
                label: const Text('GUARDAR DATOS DEL NEGOCIO', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
