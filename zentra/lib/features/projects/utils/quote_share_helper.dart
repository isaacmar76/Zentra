import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/project_model.dart';
import '../../profile/models/business_profile_model.dart';
import '../../profile/providers/business_profile_provider.dart';
import '../../../core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

/// Utilidad para generar y compartir resúmenes, cotizaciones y recibos
/// de proyectos directamente hacia WhatsApp para el cliente, utilizando los datos del perfil del negocio.
class QuoteShareHelper {
  static String buildWhatsAppMessage(ProjectModel project, BusinessProfileModel profile) {
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final dateStr = DateFormat('dd/MM/yyyy').format(project.deliveryDate);

    final buffer = StringBuffer();
    buffer.writeln('✨ *${profile.businessName.toUpperCase()}* ✨');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📋 *Proyecto:* ${project.name}');
    buffer.writeln('👤 *Cliente:* ${project.clientName}');
    buffer.writeln('📅 *Fecha de Entrega:* $dateStr');
    buffer.writeln('🔄 *Estado actual:* ${project.status}');
    buffer.writeln('');

    if (project.items.isNotEmpty) {
      buffer.writeln('📦 *PRODUCTOS Y ENTREGABLES:*');
      for (final item in project.items) {
        buffer.writeln('• ${item.quantity}x ${item.name} - ${currency.format(item.subtotal)}');
      }
    } else {
      buffer.writeln('📦 *SERVICIOS / DETALLE:*');
      if (project.services.isEmpty) {
        buffer.writeln('• Servicio artesanal personalizado');
      } else {
        for (final service in project.services) {
          buffer.writeln('• $service');
        }
      }
    }
    buffer.writeln('');

    buffer.writeln('💰 *RESUMEN DE CUENTA:*');
    buffer.writeln('• *Total Cotizado:* ${currency.format(project.totalPrice)}');
    buffer.writeln('• *Abonado a la fecha:* ${currency.format(project.totalPaid)}');
    buffer.writeln('• *SALDO PENDIENTE:* ${currency.format(project.pendingBalance)}');
    buffer.writeln('');

    if (project.payments.isNotEmpty) {
      buffer.writeln('📝 *HISTORIAL DE ABONOS:*');
      for (final p in project.payments) {
        final pDate = DateFormat('dd/MM').format(p.date);
        buffer.writeln('  ✓ $pDate - ${currency.format(p.amount)} (${p.paymentMethod})${p.notes.isNotEmpty ? " - " + p.notes : ""}');
      }
      buffer.writeln('');
    }

    if (project.notes.isNotEmpty) {
      buffer.writeln('📌 *Notas del encargo:* ${project.notes}');
      buffer.writeln('');
    }

    buffer.writeln('🏦 *MEDIOS DE PAGO ACEPTADOS:*');
    if (profile.nequi.isNotEmpty) buffer.writeln('• Nequi: ${profile.nequi}');
    if (profile.daviplata.isNotEmpty) buffer.writeln('• Daviplata: ${profile.daviplata}');
    if (profile.bancolombia.isNotEmpty) buffer.writeln('• Bancolombia: ${profile.bancolombia}');
    if (profile.phone.isNotEmpty) buffer.writeln('📞 Contacto: ${profile.phone}');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln(profile.customNote);

    return buffer.toString();
  }

  static void showShareModal(BuildContext context, ProjectModel project) {
    final theme = context.read<ThemeProvider>().currentPalette;
    final profile = context.read<BusinessProfileProvider>().profile;
    final messageText = buildWhatsAppMessage(project, profile);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.share, color: Color(0xFF25D366), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enviar a ${project.clientName}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                            ),
                            Text(
                              'Remitente: ${profile.businessName}',
                              style: const TextStyle(fontSize: 12.5, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                            if (project.clientPhone.isNotEmpty)
                              Text(
                                'WhatsApp: ${project.clientPhone}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Vista previa del mensaje a enviar:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEAE2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: SelectableText(
                      messageText,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12.5,
                        color: Color(0xFF111B21),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: messageText));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text('¡Resumen copiado! Pégalo en el chat de WhatsApp con ${project.clientName}.'),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF25D366),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, color: Colors.white),
                    label: const Text('COPIAR MENSAJE PARA WHATSAPP'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('CERRAR'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
