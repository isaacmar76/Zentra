import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'theme_provider.dart';

/// Modal interactivo para seleccionar entre los 4 temas visuales de Zentra.
void showZentraThemeSelector(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final activeTheme = themeProvider.currentPalette;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.palette_outlined, color: activeTheme.secondary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personalizar Apariencia',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Elige la paleta de colores para tu negocio',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),
                ...AppTheme.allThemes.map((theme) {
                  final isSelected = theme.id == themeProvider.currentThemeId;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected ? theme.secondary : Colors.grey.withOpacity(0.2),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    elevation: isSelected ? 3 : 1,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        themeProvider.setTheme(theme.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tema cambiado a "${theme.name}"'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: theme.secondary,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Vista previa visual de las 4 muestras de color
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: theme.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildColorDot(theme.primary),
                                  const SizedBox(width: 4),
                                  _buildColorDot(theme.secondary),
                                  const SizedBox(width: 4),
                                  _buildColorDot(theme.textDark),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Información del tema
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        theme.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: isSelected ? theme.secondary : const Color(0xFF222222),
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: theme.secondary.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'ACTIVO',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: theme.secondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    theme.subtitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: isSelected ? theme.secondary : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeTheme.secondary,
                  ),
                  child: const Text('LISTO'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildColorDot(Color color) {
  return Container(
    width: 14,
    height: 14,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 1.5),
    ),
  );
}
