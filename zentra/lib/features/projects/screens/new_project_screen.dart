import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/project_model.dart';
import '../providers/projects_provider.dart';

class NewProjectScreen extends StatefulWidget {
  const NewProjectScreen({super.key});

  @override
  State<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _clientController = TextEditingController();
  final _totalController = TextEditingController(text: '150000');
  DateTime? _deliveryDate;

  // Catálogo de servicios predeterminados de Tatiana (08-ajustes-tatiana.md)
  bool _invitaciones = true;
  bool _centros = false;
  bool _banderines = false;

  @override
  void initState() {
    super.initState();
    _deliveryDate = DateTime.now().add(const Duration(days: 5));
    _recalculateTotal();
  }

  void _recalculateTotal() {
    double total = 0;
    if (_invitaciones) total += 150000;
    if (_centros) total += 25000;
    if (_banderines) total += 80000;
    _totalController.text = total.toStringAsFixed(0);
  }

  void _saveProject() {
    if (_formKey.currentState!.validate() && _deliveryDate != null) {
      final services = <String>[];
      if (_invitaciones) services.add('Invitaciones (\$150.000)');
      if (_centros) services.add('Centros de mesa (\$25.000)');
      if (_banderines) services.add('Banderines (\$80.000)');

      final parsedTotal = double.tryParse(_totalController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;

      final newProject = ProjectModel(
        id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        clientName: _clientController.text.trim(),
        deliveryDate: _deliveryDate!,
        status: 'En Diseño',
        services: services.isEmpty ? ['Servicio personalizado'] : services,
        totalPrice: parsedTotal,
      );

      context.read<ProjectsProvider>().addProject(newProject);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proyecto guardado exitosamente'),
          backgroundColor: Color(0xFFA3B18A), // successGreen
        ),
      );
    } else if (_deliveryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una fecha de entrega')),
      );
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate ?? DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _deliveryDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _clientController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NUEVO PROYECTO'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Proyecto',
                  hintText: 'Ej: 15 años Maria',
                  prefixIcon: Icon(Icons.celebration_outlined),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Escribe un nombre para el encargo' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clientController,
                decoration: const InputDecoration(
                  labelText: 'Cliente',
                  hintText: 'Ej: Maria Rodriguez',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingresa el nombre del cliente' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: Text(
                  _deliveryDate == null
                      ? 'Fecha de Entrega'
                      : 'Entrega: ${DateFormat('dd/MM/yyyy').format(_deliveryDate!)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Toca para cambiar la fecha límite'),
                trailing: const Icon(Icons.calendar_today, color: Color(0xFFD4A5A5)),
                onTap: _selectDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE8C4C4)),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Servicios a Incluir',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text('Invitaciones'),
                      subtitle: const Text('\$150.000 COP'),
                      secondary: const Icon(Icons.mail_outline, color: Color(0xFFD4A5A5)),
                      value: _invitaciones,
                      activeColor: const Color(0xFFD4A5A5),
                      onChanged: (val) {
                        setState(() {
                          _invitaciones = val!;
                          _recalculateTotal();
                        });
                      },
                    ),
                    const Divider(height: 1),
                    CheckboxListTile(
                      title: const Text('Centros de mesa'),
                      subtitle: const Text('\$25.000 c/u'),
                      secondary: const Icon(Icons.local_florist_outlined, color: Color(0xFFD4A5A5)),
                      value: _centros,
                      activeColor: const Color(0xFFD4A5A5),
                      onChanged: (val) {
                        setState(() {
                          _centros = val!;
                          _recalculateTotal();
                        });
                      },
                    ),
                    const Divider(height: 1),
                    CheckboxListTile(
                      title: const Text('Banderines'),
                      subtitle: const Text('\$80.000 COP'),
                      secondary: const Icon(Icons.flag_outlined, color: Color(0xFFD4A5A5)),
                      value: _banderines,
                      activeColor: const Color(0xFFD4A5A5),
                      onChanged: (val) {
                        setState(() {
                          _banderines = val!;
                          _recalculateTotal();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _totalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Presupuesto Total / Cobro Pactado (\$ COP)',
                  prefixIcon: Icon(Icons.attach_money),
                  helperText: 'Puedes editar el precio total si aplicas descuentos o cambios',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Ingresa el total a cobrar' : null,
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                onPressed: _saveProject,
                icon: const Icon(Icons.save_outlined),
                label: const Text('GUARDAR PROYECTO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
