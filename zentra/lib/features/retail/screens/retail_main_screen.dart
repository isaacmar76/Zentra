import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/retail_provider.dart';
import '../models/retail_models.dart';
import '../../mode_selection/screens/mode_selection_screen.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_selector_modal.dart';

/// Pantalla Principal del Modo Retail (Tiendas y Minimercados) en Zentra.
/// Incluye Punto de Venta (POS) rápido, Arqueo de Caja e Inventario con alertas.
class RetailMainScreen extends StatefulWidget {
  const RetailMainScreen({super.key});

  @override
  State<RetailMainScreen> createState() => _RetailMainScreenState();
}

class _RetailMainScreenState extends State<RetailMainScreen> {
  int _currentTab = 0;
  String _searchQuery = '';

  final currencyFormatter = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );

  void _showCheckoutDialog(BuildContext context, RetailProvider provider) {
    String paymentMethod = 'Efectivo';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Cobrar Venta',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Total a pagar: ${currencyFormatter.format(provider.cartTotal)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA3B18A), // successGreen
                ),
              ),
              const Divider(height: 24),
              Text(
                'Método de Pago:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: ['Efectivo', 'Nequi', 'Daviplata', 'Transferencia'].map((m) {
                  final isSelected = paymentMethod == m;
                  return ChoiceChip(
                    label: Text(m),
                    selected: isSelected,
                    selectedColor: const Color(0xFFD4A5A5),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF5C4A3E),
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (val) {
                      if (val) setModalState(() => paymentMethod = m);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  final ok = provider.checkout(paymentMethod);
                  Navigator.pop(ctx);
                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Venta de ${currencyFormatter.format(provider.totalVentasHoy)} cobrada y sumada a Caja.'),
                        backgroundColor: const Color(0xFFA3B18A),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('CONFIRMAR Y COBRAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddGastoCajaDialog(BuildContext context, RetailProvider provider) {
    final descController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Salida de Dinero / Gasto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Motivo (ej. Bolsas, Domicilio)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Monto (\$ COP)', prefixIcon: Icon(Icons.attach_money)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              if (descController.text.isNotEmpty && amount > 0) {
                provider.registrarSalidaCaja(descController.text.trim(), amount);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Salida registrada en caja')),
                );
              }
            },
            child: const Text('REGISTRAR SALIDA'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RetailProvider>();
    final theme = context.watch<ThemeProvider>().currentPalette;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTab == 0 ? 'Zentra - Punto de Venta' : _currentTab == 1 ? 'Zentra - Caja del Día' : 'Zentra - Inventario'),
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
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildPosTab(context, provider),
          _buildCajaTab(context, provider),
          _buildInventoryTab(context, provider),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (idx) => setState(() => _currentTab = idx),
        selectedItemColor: theme.secondary,
        unselectedItemColor: theme.textDark.withOpacity(0.5),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale_outlined),
            activeIcon: Icon(Icons.point_of_sale),
            label: 'Vender',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Caja',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Inventario',
          ),
        ],
      ),
    );
  }

  // 1. Pestaña de Punto de Venta (POS)
  Widget _buildPosTab(BuildContext context, RetailProvider provider) {
    final filtered = provider.products.where((p) {
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: const InputDecoration(
              hintText: 'Buscar producto (ej. Arroz, Aceite)...',
              prefixIcon: Icon(Icons.search),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final prod = filtered[index];
              return _buildProductCard(context, provider, prod);
            },
          ),
        ),
        if (provider.cart.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${provider.cartCount} items',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      currencyFormatter.format(provider.cartTotal),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5C4A3E),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                TextButton(
                  onPressed: provider.clearCart,
                  child: const Text('Limpiar', style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _showCheckoutDialog(context, provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA3B18A), // successGreen
                  ),
                  child: const Text('COBRAR'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, RetailProvider provider, ProductItem prod) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          final added = provider.addToCart(prod);
          if (!added) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('¡Stock insuficiente de ${prod.name}! Quedan ${prod.stock} unidades.'),
                backgroundColor: const Color(0xFFE07A5F),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5EFE6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      prod.category,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF5C4A3E)),
                    ),
                  ),
                  if (prod.isLowStock)
                    const Icon(Icons.error_outline, color: Color(0xFFE07A5F), size: 16),
                ],
              ),
              Text(
                prod.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currencyFormatter.format(prod.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4A5A5),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Disp: ${prod.stock}',
                    style: TextStyle(
                      fontSize: 11,
                      color: prod.isLowStock ? const Color(0xFFE07A5F) : Colors.grey,
                      fontWeight: prod.isLowStock ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. Pestaña de Caja del Día
  Widget _buildCajaTab(BuildContext context, RetailProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          color: const Color(0xFFF5EFE6),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cuadre de Caja del Día', style: Theme.of(context).textTheme.titleLarge),
                const Divider(height: 20),
                _buildCajaRow('Base inicial de apertura:', currencyFormatter.format(provider.cajaBase)),
                const SizedBox(height: 8),
                _buildCajaRow('+ Ventas del día:', currencyFormatter.format(provider.totalVentasHoy), color: const Color(0xFFA3B18A)),
                const SizedBox(height: 8),
                _buildCajaRow('- Salidas / Gastos:', currencyFormatter.format(provider.totalGastosHoy), color: const Color(0xFFE07A5F)),
                const Divider(height: 24),
                _buildCajaRow(
                  'Saldo Esperado en Caja:',
                  currencyFormatter.format(provider.saldoEsperadoEnCaja),
                  isBold: true,
                  color: const Color(0xFF5C4A3E),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showAddGastoCajaDialog(context, provider),
                icon: const Icon(Icons.remove_circle_outline),
                label: const Text('REGISTRAR SALIDA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE07A5F),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Movimientos Registrados', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
        const SizedBox(height: 8),
        if (provider.movimientosCaja.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No hay movimientos registrados hoy en caja.')),
          )
        else
          ...provider.movimientosCaja.map(
            (m) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  m.type == 'Venta' ? Icons.arrow_downward : Icons.arrow_upward,
                  color: m.type == 'Venta' ? const Color(0xFFA3B18A) : const Color(0xFFE07A5F),
                ),
                title: Text(m.description, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(DateFormat('hh:mm a').format(m.date)),
                trailing: Text(
                  '${m.type == 'Venta' ? '+' : '-'}${currencyFormatter.format(m.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: m.type == 'Venta' ? const Color(0xFFA3B18A) : const Color(0xFFE07A5F),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCajaRow(String label, String value, {Color? color, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 17 : 14,
            color: color ?? const Color(0xFF5C4A3E),
          ),
        ),
      ],
    );
  }

  // 3. Pestaña de Inventario
  Widget _buildInventoryTab(BuildContext context, RetailProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.products.length,
      itemBuilder: (context, index) {
        final prod = provider.products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(prod.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Precio: ${currencyFormatter.format(prod.price)} • Costo: ${currencyFormatter.format(prod.cost)}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: prod.isLowStock
                    ? const Color(0xFFE07A5F).withOpacity(0.15)
                    : const Color(0xFFA3B18A).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Stock: ${prod.stock}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: prod.isLowStock ? const Color(0xFFE07A5F) : const Color(0xFFA3B18A),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
