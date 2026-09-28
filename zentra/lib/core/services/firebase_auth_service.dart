import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio de autenticación con respaldo resiliente para Zentra.
/// Si Firebase está disponible y configurado, autentica en la nube.
/// Si no hay conexión o no está inicializado, permite continuar en modo local.
class FirebaseAuthService {
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      return null;
    }
  }

  Stream<User?> get authStateChanges {
    final auth = _auth;
    if (auth != null) {
      try {
        return auth.authStateChanges();
      } catch (_) {}
    }
    return Stream.value(null);
  }

  User? get currentUser {
    try {
      return _auth?.currentUser;
    } catch (_) {
      return null;
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    final auth = _auth;
    if (auth != null) {
      try {
        return await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        // Si el usuario no existe o la API key es de demo, no bloquear la prueba
        debugPrint('Autenticación en la nube no completada ($e). Accediendo en modo local.');
        return null;
      } catch (e) {
        debugPrint('Error de red al iniciar sesión: $e');
        return null;
      }
    }
    return null;
  }

  Future<UserCredential?> registerWithEmail(String email, String password) async {
    final auth = _auth;
    if (auth != null) {
      try {
        return await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        debugPrint('Registro en la nube no completado ($e). Creando sesión local.');
        return null;
      } catch (e) {
        debugPrint('Error de red al registrarse: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      await _auth?.signOut();
    } catch (_) {}
  }
}
