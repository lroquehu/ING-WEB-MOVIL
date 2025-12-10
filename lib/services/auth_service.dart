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
          'correo': email,
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
  
  Future<Map<String, dynamic>> verificarCuenta(String token, String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.verificarCuenta),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'correo': email, 
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> cambiarPassword(
    String userId,
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.cambiarPassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_usuario': userId,
          'password_actual': currentPassword,
          'password_nueva': newPassword,      // <-- CORREGIDO
          'password_confirmar': confirmPassword, // <-- CORREGIDO
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Error de conexión: $e'};
    }
  }
}
