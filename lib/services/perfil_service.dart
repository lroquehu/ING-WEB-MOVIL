import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/user_model.dart';
import '../models/estadisticas_model.dart';

class PerfilService {
  // Retorna un Mapa con el Usuario actualizado y sus Estadísticas
  Future<Map<String, dynamic>?> getPerfilCompleto(String idUsuario) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/perfil?id_usuario=$idUsuario'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return {
            'usuario': User.fromJson(data['data']['usuario']),
            'estadisticas': Estadisticas.fromJson(data['data']['estadisticas']),
          };
        }
      }
    } catch (e) {
      print('Error obteniendo perfil: $e');
    }
    return null;
  }
}
