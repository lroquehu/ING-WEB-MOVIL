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
  bool get isAuth => _currentUser != null;

  AuthProvider() {
    checkSession();
  }

  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('id_usuario')) {
      _currentUser = User(
        id: prefs.getString('id_usuario') ?? '',
        nombres: prefs.getString('nombre_usuario') ?? 'Usuario',
        apellidos: '',
        email: '',
        fotoPerfil: null,
      );
      notifyListeners();
    }
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(email, password);

    _isLoading = false;

    if (result['status'] == 'success') {
      _currentUser = User.fromJson(result['data']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id_usuario', _currentUser!.id);
      await prefs.setString('nombre_usuario', _currentUser!.nombres);
      notifyListeners();
      return null;
    } else {
      String message = result['message']?.toLowerCase() ?? '';
      notifyListeners();
      if (result['status'] == 'error' || message.contains('invalid') || message.contains('unauthorized')) {
        return 'Credenciales incorrectas. Por favor, verifica tu correo y contraseña.';
      } else {
        return result['message'] ?? 'Ocurrió un error desconocido.';
      }
    }
  }

  Future<String?> registro(Map<String, String> datos) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.registro(datos);

    _isLoading = false;
    notifyListeners();

    if (result['status'] == 'success') {
      return null;
    } else {
      return result['message'];
    }
  }

  Future<String?> recuperarPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.recuperarPassword(email);

    _isLoading = false;
    notifyListeners();

    if (result['status'] == 'success') {
      return null;
    } else {
      return result['message'] ?? "Error al procesar la solicitud.";
    }
  }

  // --- AÑADIDO: MÉTODO PARA RESETEAR CONTRASEÑA ---
  Future<String?> resetearPassword(
    String email,
    String token,
    String password,
    String confirmPassword,
  ) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.resetearPassword(
        email, token, password, confirmPassword);

    _isLoading = false;
    notifyListeners();

    if (result['status'] == 'success') {
      return null; // Éxito
    } else {
      return result['message'] ?? "Error al cambiar la contraseña.";
    }
  }

  void logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
