import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zentra/core/services/firebase_auth_service.dart';
import 'package:zentra/features/mode_selection/screens/mode_selection_screen.dart';
import 'package:zentra/core/layout/main_layout_screen.dart';
import 'package:zentra/features/retail/screens/retail_main_screen.dart';
import 'package:zentra/core/theme/theme_provider.dart';
import 'package:zentra/core/theme/theme_selector_modal.dart';

import '../../profile/providers/business_profile_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = FirebaseAuthService();
  bool _isLoading = false;

  void _navigateAfterAuth() {
    final profileProvider = context.read<BusinessProfileProvider>();
    if (profileProvider.isConfigured) {
      if (profileProvider.businessType == 'RETAIL') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RetailMainScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainLayoutScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ModeSelectionScreen()),
      );
    }
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _navigateAfterAuth();
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) _navigateAfterAuth();
    } catch (_) {
      if (mounted) _navigateAfterAuth();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _navigateAfterAuth();
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) _navigateAfterAuth();
    } catch (_) {
      if (mounted) _navigateAfterAuth();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _irAConfiguracionNegocio() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ModeSelectionScreen()),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentPalette;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Cambiar apariencia (${theme.name})',
            onPressed: () => showZentraThemeSelector(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/images/zentra_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.shield_outlined,
                          size: 54,
                          color: theme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'ZENTRA',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: theme.textDark,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Gestión simple para micronegocios',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(backgroundColor: theme.secondary),
                      child: const Text('INICIAR SESIÓN'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _register,
                      style: TextButton.styleFrom(
                        foregroundColor: theme.textDark,
                      ),
                      child: const Text('REGISTRARSE'),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'O CONFIGURA DIRECTAMENTE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _irAConfiguracionNegocio,
                    icon: Icon(Icons.storefront_outlined, color: theme.secondary),
                    label: const Text('Crear / Configurar Mi Negocio'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.textDark,
                      side: BorderSide(color: theme.secondary, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
