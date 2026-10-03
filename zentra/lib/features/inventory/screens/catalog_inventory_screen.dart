import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/catalog_item_model.dart';
import '../providers/inventory_provider.dart';
import '../../projects/providers/projects_provider.dart';
import '../../projects/models/general_transaction_model.dart';
import '../../../core/theme/theme_provider.dart';

class CatalogInventoryScreen extends StatefulWidget {
  final String initialMode; // 'servicios' o 'retail'

  const CatalogInventoryScreen({
    super.key,
    this.initialMode = 'servicios',
  });

  @override
  State<CatalogInventoryScreen> createState() => _CatalogInventoryScreenState();
}

class _CatalogInventoryScreenState extends State<CatalogInventoryScreen> {
  late String _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialMode;
  }

  void _showAddEditProductModal(BuildContext context, {CatalogItemModel? existingItem}) {
    final nameController = TextEditingController(text: existingItem?.name ?? '');
    final priceController = TextEditingController(
      text: existingItem != null ? existingItem.salePrice.toStringAsFixed(0) : '',
    );
    final costController = TextEditingController(
      text: existingItem != null ? existingItem.costPrice.toStringAsFixed(0) : '',
    );
    final stockController = TextEditingController(
      text: existingItem != null ? existingItem.stock.toString() : '5',
    );
    String category = existingItem?.category ?? (_currentFilter == 'servicios' ? 'Papelería' : 'Abarrotes');
    String bType = existingItem?.businessType ?? _currentFilter;

    final categories = _currentFilter == 'servicios'
        ? ['Papelería', 'Fiestas', 'Empaques', 'Decoración', 'Accesorios', 'General']
        : ['Granos', 'Abarrotes', 'Lácteos', 'Bebidas', 'Aseo', 'Panadería', 'General'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(existingItem == null ? 'Nuevo Producto al Catálogo' : 'Editar Producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del producto *',
                    hintText: 'Ej: Agendas 2026, Cake Topper',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Precio Venta (\$ COP) *',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: costController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Costo Elaboración (\$)',
                          prefixIcon: Icon(Icons.sell_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: stockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Stock Inicial *',
                          prefixIcon: Icon(Icons.inventory_2_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: categories.contains(category) ? category : categories.first,
                        decoration: const InputDecoration(labelText: 'Categoría'),
                        items: categories
                            .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12))))
                            .toList(),
                        onChanged: (val) => setState(() => category = val!),
                      ),
                    ),
                  ],
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
                final name = nameController.text.trim();
                final price = double.tryParse(priceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                final cost = double.tryParse(costController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                final stock = int.tryParse(stockController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

                if (name.isEmpty || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingresa al menos el nombre y precio de venta válido')),
                  );
                  return;
                }

                final provider = context.read<InventoryProvider>();

                if (existingItem == null) {
                  final newItem = CatalogItemModel(
                    id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    salePrice: price,
                    costPrice: cost,
                    stock: stock,
                    category: category,
                    businessType: bType,
                  );
                  provider.addItem(newItem);
                } else {
                  final updated = existingItem.copyWith(
                    name: name,
                    salePrice: price,
                    costPrice: cost,
                    stock: stock,
                    category: category,
                  );
                  provider.updateItem(updated);
                }

                Navigator.pop(ctx);
              },
              child: const Text('GUARDAR PRODUCTO'),
            ),
          ],
        ),
      ),
    );
  }

  void _sellProductDirectly(BuildContext context, CatalogItemModel item) {
    if (item.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Agotado! No hay existencias de ${item.name}')),
      );
      return;
    }

    final currency = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vender Producto de Inventario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Producto: ${item.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Precio: ${currency.format(item.salePrice)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            Text('Stock disponible: ${item.stock} unidades'),
            const SizedBox(height: 12),
            const Text(
              'Esta venta descontará 1 unidad del inventario y registrará el ingreso en las finanzas del negocio.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38A169)),
            onPressed: () async {
              final invProvider = context.read<InventoryProvider>();
              final success = await invProvider.sellItem(item.id, quantity: 1);

              if (success && context.mounted) {
                // Registrar ingreso general en finanzas
                final projProvider = context.read<ProjectsProvider>();
                await projProvider.addGeneralTransaction(
                  GeneralTransactionModel(
                    id: 'tx_sale_${DateTime.now().millisecondsSinceEpoch}',
                    type: GeneralTransactionType.ingreso,
                    amount: item.salePrice,
                    description: 'Venta de catálogo: ${item.name}',
                    category: 'Venta Catálogo',
                    paymentMethod: 'Nequi',
                    date: DateTime.now(),
                  ),
                );

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✓ ¡Venta de ${item.name} registrada (+${currency.format(item.salePrice)})!'),
                    backgroundColor: const Color(0xFF38A169),
                  ),
                );
              }
            },
            child: const Text('CONFIRMAR VENTA (1 UNIDAD)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentPalette;
    final inventory = context.watch<InventoryProvider>();
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    final displayItems = inventory.getItemsForMode(_currentFilter);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo e Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Nuevo Producto',
            onPressed: () => _showAddEditProductModal(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de filtro
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: theme.background,
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'servicios', label: Text('Servicios (Por Encargo)', style: TextStyle(fontSize: 12))),
                      ButtonSegment(value: 'retail', label: Text('Retail (Mostrador POS)', style: TextStyle(fontSize: 12))),
                    ],
                    selected: {_currentFilter},
                    onSelectionChanged: (val) {
                      setState(() => _currentFilter = val.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: displayItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 54, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text('No hay productos en este catálogo aún'),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _showAddEditProductModal(context),
                          icon: const Icon(Icons.add),
                          label: const Text('AGREGAR PRIMER PRODUCTO'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayItems.length,
                    itemBuilder: (ctx, i) {
                      final item = displayItems[i];
                      final isLow = item.isLowStock;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: isLow ? BorderSide(color: theme.alert, width: 1.5) : BorderSide.none,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        Text(
                                          'Categoría: ${item.category}',
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isLow ? theme.alert.withOpacity(0.15) : const Color(0xFF38A169).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isLow ? '⚠️ Stock bajo: ${item.stock}' : 'Stock: ${item.stock}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isLow ? theme.alert : const Color(0xFF38A169),
                                      ),
                                    ),
                                  ),
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
                                        'Precio: ${currency.format(item.salePrice)}',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.secondary),
                                      ),
                                      if (item.costPrice > 0)
                                        Text(
                                          'Costo: ${currency.format(item.costPrice)} • Ganancia: +${currency.format(item.unitProfit)}',
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 18),
                                        tooltip: 'Editar',
                                        onPressed: () => _showAddEditProductModal(context, existingItem: item),
                                      ),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF38A169),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        ),
                                        onPressed: () => _sellProductDirectly(context, item),
                                        icon: const Icon(Icons.point_of_sale, size: 14, color: Colors.white),
                                        label: const Text('Vender 1', style: TextStyle(fontSize: 11, color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.secondary,
        onPressed: () => _showAddEditProductModal(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('NUEVO PRODUCTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
