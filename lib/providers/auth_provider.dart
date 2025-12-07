import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(email, password);
    
    _isLoading = false;
    notifyListeners();

    if (result['status'] == 'success') {
      _currentUser = User.fromJson(result['data']);
      
      // Guardar sesión localmente
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id_usuario', _currentUser!.id);
      await prefs.setString('nombre_usuario', _currentUser!.nombres);
      
      return null; // Null significa éxito
    } else {
      return result['message']; // Devuelve el mensaje de error
    }
  }
  
  void logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}