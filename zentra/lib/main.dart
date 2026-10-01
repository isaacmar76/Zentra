import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/theme_provider.dart';
import 'features/login/screens/login_screen.dart';
import 'features/projects/providers/projects_provider.dart';
import 'features/retail/providers/retail_provider.dart';
import 'features/profile/providers/business_profile_provider.dart';
import 'features/inventory/providers/inventory_provider.dart';
import 'features/clients/providers/clients_provider.dart';

import 'features/retail/screens/retail_main_screen.dart';
import 'core/layout/main_layout_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Nota: Firebase en modo local/desconectado ($e). Zentra continuará funcionando normalmente.');
  }
  
  runApp(const ZentraApp());
}

class ZentraApp extends StatelessWidget {
  const ZentraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BusinessProfileProvider()),
        ChangeNotifierProvider(create: (_) => ProjectsProvider()),
        ChangeNotifierProvider(create: (_) => RetailProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => ClientsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Zentra',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentThemeData,
            builder: (context, child) {
              if (!kIsWeb) return child!;
              
              return Container(
                color: Colors.grey[200], // Fondo del navegador
                child: Center(
                  child: Container(
                    width: 390, // Ancho típico de celular (ej. iPhone)
                    height: 844, // Alto típico de celular
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF333333),
                        width: 12,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: child!,
                    ),
                  ),
                ),
              );
            },
            home: Consumer<BusinessProfileProvider>(
              builder: (context, profileProv, _) {
                if (profileProv.isConfigured) {
                  if (profileProv.businessType == 'RETAIL') {
                    return const RetailMainScreen();
                  } else {
                    return const MainLayoutScreen();
                  }
                }
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
