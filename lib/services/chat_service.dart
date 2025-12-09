import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/chat_models.dart';

class ChatService {
  // 1. Iniciar o retomar chat (desde el botón "Contactar")
  Future<String?> iniciarConversacion(String miId, String otroId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/chat/iniciar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_usuario': miId, 'id_otro_usuario': otroId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['id_conversacion'].toString();
        }
      }
    } catch (e) {
      print('Error iniciar chat: $e');
    }
    return null;
  }

  // 2. Obtener lista de conversaciones (Bandeja de entrada)
  Future<List<Conversacion>> getConversaciones(String miId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/chat?id_usuario=$miId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return (data['data'] as List)
              .map((e) => Conversacion.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      print('Error lista chats: $e');
    }
    return [];
  }

  // 3. Obtener mensajes de una sala
  Future<List<Mensaje>> getMensajes(String idConversacion, String miId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/chat/mensajes?id_conversacion=$idConversacion&id_usuario=$miId',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return (data['data'] as List)
              .map((e) => Mensaje.fromJson(e, miId))
              .toList();
        }
      }
    } catch (e) {
      print('Error mensajes: $e');
    }
    return [];
  }

  // 4. Enviar mensaje
  Future<bool> enviarMensaje(
    String idConversacion,
    String miId,
    String texto,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/chat/enviar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_conversacion': idConversacion,
          'id_usuario': miId,
          'contenido': texto,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
    } catch (e) {
      print('Error enviar: $e');
    }
    return false;
  }
}
