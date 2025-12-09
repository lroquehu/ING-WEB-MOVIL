import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> registro(Map<String, String> datos) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.registro),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datos),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> recuperarPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.recuperarPassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': email}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Error de conexión: $e'};
    }
  }

  // --- AÑADIDO: MÉTODO PARA LLAMAR A LA API DE RESETEO ---
  Future<Map<String, dynamic>> resetearPassword(
    String email,
    String token,
    String password,
    String confirmPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.resetearPassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': email, // La API también espera el correo
          'token': token,
          'password': password,
          'confirm_password': confirmPassword,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Error de conexión: $e'};
    }
  }
}
