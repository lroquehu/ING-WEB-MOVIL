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
  bool get isAuth => _currentUser != null; // Helper para saber si está logueado

  AuthProvider() {
    checkSession(); // Verificar sesión al iniciar el provider
  }

  // Verificar si hay sesión guardada en el celular
  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('id_usuario')) {
      // Reconstruimos el usuario con los datos locales
      // Nota: Idealmente deberíamos llamar a /api/perfil para actualizar datos,
      // pero para el MVP esto carga instantáneo.
      _currentUser = User(
        id: prefs.getString('id_usuario') ?? '',
        nombres: prefs.getString('nombre_usuario') ?? 'Usuario',
        apellidos:
            '', // No guardamos apellido en login simple, podrías agregarlo
        email: '',
        fotoPerfil: null, // Podrías guardar la URL también
      );
      notifyListeners();
    }
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(email, password);

    _isLoading = false;
    notifyListeners();

    if (result['status'] == 'success') {
      _currentUser = User.fromJson(result['data']);

      // Guardar datos críticos
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id_usuario', _currentUser!.id);
      await prefs.setString('nombre_usuario', _currentUser!.nombres);

      return null;
    } else {
      return result['message'];
    }
  }

  // ... dentro de AuthProvider ...

  Future<String?> registro(Map<String, String> datos) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.registro(datos);

    _isLoading = false;
    notifyListeners();

    if (result['status'] == 'success') {
      return null; // Éxito
    } else {
      return result['message']; // Error
    }
  }

  void logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
