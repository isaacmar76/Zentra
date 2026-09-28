import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business_profile_model.dart';

/// Provider para gestionar los datos comerciales del negocio y su persistencia local.
class BusinessProfileProvider with ChangeNotifier {
  static const String _storageKey = 'zentra_business_profile_v1';
  BusinessProfileModel _profile = const BusinessProfileModel();

  BusinessProfileModel get profile => _profile;

  BusinessProfileProvider() {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_storageKey);
      if (str != null && str.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(str);
        _profile = BusinessProfileModel.fromMap(map);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error cargando perfil del negocio: $e');
    }
  }

  Future<void> updateProfile(BusinessProfileModel newProfile) async {
    _profile = newProfile;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(_profile.toMap()));
    } catch (e) {
      debugPrint('Error guardando perfil del negocio: $e');
    }
  }
}
