import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/project_model.dart';
import '../providers/projects_provider.dart';
import '../../../core/theme/theme_provider.dart';

class NewProjectScreen extends StatefulWidget {
  const NewProjectScreen({super.key});

  @override
  State<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _clientController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _totalController = TextEditingController();
  final _advanceController = TextEditingController();

  DateTime? _deliveryDate;

  // Cantidades de los servicios del catálogo predeterminado de Tatiana (08-ajustes-tatiana.md)
  int _qtyInvitaciones = 1;
  int _qtyCentros = 0;
  int _qtyBanderines = 0;

  // Servicio personalizado extra
  bool _hasCustomService = false;
  final _customServiceNameController = TextEditingController();
  final _customServicePriceController = TextEditingController();

  // Registro de anticipo inmediato
  bool _recordInitialAdvance = true;
  String _advancePaymentMethod = 'Nequi';

  @override
  void initState() {
    super.initState();
    _deliveryDate = DateTime.now().add(const Duration(days: 5));
    _recalculateTotal();
  }

  void _recalculateTotal() {
    double total = 0;
    total += _qtyInvitaciones * 150000;
    total += _qtyCentros * 25000;
    total += _qtyBanderines * 80000;

    if (_hasCustomService) {
      final customPrice = double.tryParse(
            _customServicePriceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          0.0;
      total += customPrice;
    }

    _totalController.text = total.toStringAsFixed(0);

    // Sugerir anticipo del 40% o 50%
    if (_recordInitialAdvance) {
      final suggested = (total * 0.50).round();
      _advanceController.text = suggested.toString();
    }
  }

  void _loadTatianaExample() {
    setState(() {
      _nameController.text = '15 años Maria';
      _clientController.text = 'Maria Rodriguez';
      _phoneController.text = '3124567890';
      _notesController.text = 'Colores Blush y Nude con toques en foil dorado.';
      _qtyInvitaciones = 1; // Paquete de 50
      _qtyCentros = 10; // 10 centros de mesa
      _qtyBanderines = 0;
      _deliveryDate = DateTime.now().add(const Duration(days: 2));
      _recalculateTotal();
    });
  }

  void _saveProject() {
    if (!_formKey.currentState!.validate()) return;
    if (_deliveryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona la fecha de entrega')),
      );
      return;
    }

    final servicesList = <String>[];
    if (_qtyInvitaciones > 0) {
      servicesList.add('$_qtyInvitaciones Paquete de Invitaciones (\$${NumberFormat('#,###').format(_qtyInvitaciones * 150000)})');
    }
    if (_qtyCentros > 0) {
      servicesList.add('$_qtyCentros Centros de mesa (\$${NumberFormat('#,###').format(_qtyCentros * 25000)})');
    }
    if (_qtyBanderines > 0) {
      servicesList.add('$_qtyBanderines Banderines (\$${NumberFormat('#,###').format(_qtyBanderines * 80000)})');
    }
    if (_hasCustomService && _customServiceNameController.text.isNotEmpty) {
      servicesList.add('${_customServiceNameController.text.trim()} (\$${_customServicePriceController.text})');
    }

    if (servicesList.isEmpty) {
      servicesList.add('Servicio artesanal personalizado');
    }

    final parsedTotal = double.tryParse(_totalController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;

    final paymentsList = <ProjectPaymentModel>[];
    if (_recordInitialAdvance) {
      final advanceAmount = double.tryParse(_advanceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
      if (advanceAmount > 0) {
        paymentsList.add(
          ProjectPaymentModel(
            id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
            amount: advanceAmount,
            paymentMethod: _advancePaymentMethod,
            date: DateTime.now(),
            notes: 'Anticipo inicial al crear el proyecto',
          ),
        );
      }
    }

    // Tareas sugeridas iniciales
    final defaultTasks = [
      ProjectTaskModel(id: 't_${DateTime.now().millisecondsSinceEpoch}_1', title: 'Comprar materiales e insumos', isCompleted: false),
      ProjectTaskModel(id: 't_${DateTime.now().millisecondsSinceEpoch}_2', title: 'Diseño e impresión de muestras', isCompleted: false),
      ProjectTaskModel(id: 't_${DateTime.now().millisecondsSinceEpoch}_3', title: 'Producción y armado', isCompleted: false),
      ProjectTaskModel(id: 't_${DateTime.now().millisecondsSinceEpoch}_4', title: 'Empaque y entrega final', isCompleted: false),
    ];

    final newProject = ProjectModel(
      id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      clientName: _clientController.text.trim(),
      clientPhone: _phoneController.text.trim(),
      notes: _notesController.text.trim(),
      deliveryDate: _deliveryDate!,
      status: 'En Diseño',
      services: servicesList,
      totalPrice: parsedTotal,
      payments: paymentsList,
      tasks: defaultTasks,
    );

    context.read<ProjectsProvider>().addProject(newProject);
    Navigator.pop(context);

    final theme = context.read<ThemeProvider>().currentPalette;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Proyecto "${newProject.name}" creado con éxito!'),
        backgroundColor: theme.success,
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate ?? DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _deliveryDate = picked);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _clientController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _totalController.dispose();
    _advanceController.dispose();
    _customServiceNameController.dispose();
    _customServicePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentPalette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NUEVO PEDIDO (PROYECTO)'),
        actions: [
          TextButton.icon(
            onPressed: _loadTatianaExample,
            icon: const Icon(Icons.auto_fix_high, size: 18),
            label: const Text('Ejemplo'),
            style: TextButton.styleFrom(foregroundColor: theme.secondary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Datos básicos
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Pedido / Proyecto *',
                  hintText: 'Ej: 15 años Maria, Bautizo Mateo, Boda Andrea',
                  prefixIcon: Icon(Icons.celebration_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa el nombre del encargo' : null,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _clientController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Cliente *',
                        hintText: 'Ej: Maria Rodriguez',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa el cliente' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'WhatsApp',
                        hintText: '312...',
                        prefixIcon: Icon(Icons.phone_android),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Selector de Fecha
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.primary, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_outlined, color: theme.secondary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fecha de Entrega Límite', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(
                            _deliveryDate == null ? 'Seleccionar fecha' : DateFormat('dd/MM/yyyy').format(_deliveryDate!),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Catálogo de Servicios con Contador
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Servicios & Cantidades',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                  ),
                  Text(
                    'Catálogo Tatiana',
                    style: TextStyle(fontSize: 12, color: theme.secondary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      _buildCatalogItem(
                        title: 'Invitaciones (Paquete)',
                        priceStr: '\$150.000 COP',
                        icon: Icons.mail_outline,
                        quantity: _qtyInvitaciones,
                        theme: theme,
                        onChanged: (q) => setState(() {
                          _qtyInvitaciones = q;
                          _recalculateTotal();
                        }),
                      ),
                      const Divider(),
                      _buildCatalogItem(
                        title: 'Centros de mesa',
                        priceStr: '\$25.000 c/u',
                        icon: Icons.local_florist_outlined,
                        quantity: _qtyCentros,
                        theme: theme,
                        onChanged: (q) => setState(() {
                          _qtyCentros = q;
                          _recalculateTotal();
                        }),
                      ),
                      const Divider(),
                      _buildCatalogItem(
                        title: 'Banderines',
                        priceStr: '\$80.000 COP',
                        icon: Icons.flag_outlined,
                        quantity: _qtyBanderines,
                        theme: theme,
                        onChanged: (q) => setState(() {
                          _qtyBanderines = q;
                          _recalculateTotal();
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. Resumen Financiero Total
              TextFormField(
                controller: _totalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Presupuesto Total Pactado (\$ COP) *',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                  helperText: 'Calculado automáticamente según los servicios elegidos',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Ingresa el total cotizado' : null,
              ),
              const SizedBox(height: 20),

              // 4. Registro de Anticipo Inmediato
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.payment, color: theme.secondary, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Registrar Anticipo Inicial',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          Switch(
                            value: _recordInitialAdvance,
                            activeColor: theme.secondary,
                            onChanged: (v) => setState(() {
                              _recordInitialAdvance = v;
                              if (v) _recalculateTotal();
                            }),
                          ),
                        ],
                      ),
                      if (_recordInitialAdvance) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _advanceController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Monto del Anticipo (\$)',
                                  prefixIcon: Icon(Icons.attach_money),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: _advancePaymentMethod,
                                decoration: const InputDecoration(labelText: 'Medio'),
                                items: const [
                                  DropdownMenuItem(value: 'Nequi', child: Text('Nequi')),
                                  DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                                  DropdownMenuItem(value: 'Daviplata', child: Text('Daviplata')),
                                  DropdownMenuItem(value: 'Transferencia', child: Text('Transf.')),
                                ],
                                onChanged: (v) => setState(() => _advancePaymentMethod = v!),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 5. Notas del encargo
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notas o detalles especiales (opcional)',
                  hintText: 'Ej: Tonos pastel, tipografía cursiva, incluir cinta dorada',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _saveProject,
                icon: const Icon(Icons.save_rounded),
                label: const Text('GUARDAR PROYECTO'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCatalogItem({
    required String title,
    required String priceStr,
    required IconData icon,
    required int quantity,
    required ZentraThemePalette theme,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: theme.secondary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                Text(priceStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.primary),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: quantity > 0 ? () => onChanged(quantity - 1) : null,
                ),
                Text(
                  '$quantity',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () => onChanged(quantity + 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
