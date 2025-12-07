import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/user_model.dart';
import '../models/estadisticas_model.dart';
import 'package:image_picker/image_picker.dart'; // Asegúrate de importar esto

class PerfilService {
  // Retorna un Mapa con el Usuario actualizado y sus Estadísticas
  Future<Map<String, dynamic>?> getPerfilCompleto(String idUsuario) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/perfil?id_usuario=$idUsuario'),
      );
      print("📩 Respuesta API: ${response.body}");
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

  // ... (imports y método getPerfilCompleto) ...

  // Actualizar datos del perfil
  Future<Map<String, dynamic>> actualizarPerfil(
    Map<String, String> data,
    XFile? nuevaFoto,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/perfil/editar'),
      );

      // 1. Agregar campos de texto
      request.fields.addAll(data);

      // 2. Agregar foto si el usuario seleccionó una nueva
      if (nuevaFoto != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto_perfil', nuevaFoto.path),
        );
      }

      // 3. Enviar
      var streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'error', 'message': 'Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}
