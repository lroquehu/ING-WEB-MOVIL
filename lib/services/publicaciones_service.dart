import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/publicacion_model.dart';
import '../models/categoria_model.dart';
import 'package:image_picker/image_picker.dart';

class PublicacionesService {
  // Traer Categorías
  Future<List<Categoria>> getCategorias() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/categorias'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return (data['data'] as List)
              .map((e) => Categoria.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      print('Error categorias: $e');
    }
    return [];
  }

  // Traer Publicaciones (con filtros opcionales)
  Future<List<Publicacion>> getPublicaciones({
    int page = 1,
    String search = '',
    String catId = '',
  }) async {
    try {
      // Construir URL con parámetros (paginación, búsqueda, categoría)
      String url = '${ApiConstants.publicaciones}?page=$page';
      if (search.isNotEmpty) url += '&busqueda=$search';
      if (catId.isNotEmpty && catId != '0') url += '&categoria=$catId';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return (data['data'] as List)
              .map((e) => Publicacion.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      print('Error publicaciones: $e');
    }
    return [];
  }

  // Obtener detalle completo de una publicación
  Future<Publicacion?> getDetalle(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/publicaciones/detalle?id=$id'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return Publicacion.fromJson(data['data']);
        }
      }
    } catch (e) {
      print('Error detalle: $e');
    }
    return null;
  }

  // Crear Publicación con Imágenes
  Future<Map<String, dynamic>> crearPublicacion(
    Map<String, String> data,
    List<XFile> imagenes,
  ) async {
    try {
      // Usamos MultipartRequest para enviar archivos
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/publicaciones/crear'),
      );

      // 1. Agregar campos de texto (título, precio, etc.)
      request.fields.addAll(data);

      // 2. Agregar imágenes (bucle)
      for (var img in imagenes) {
        request.files.add(
          await http.MultipartFile.fromPath('imagenes[]', img.path),
        );
      }

      // 3. Enviar
      var streamResponse = await request.send();
      // ... dentro de editarPublicacion ...
      var response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // --- AGREGA ESTAS LÍNEAS PARA VER EL ERROR ---
        print("🔴 ERROR 500 DETECTADO:");
        print("Cuerpo: ${response.body}");
        // ---------------------------------------------

        return {'status': 'error', 'message': 'Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // ... imports y métodos anteriores ...

  // Obtener SOLO mis publicaciones
  Future<List<Publicacion>> getMisPublicaciones(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/perfil/publicaciones?id_usuario=$userId',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return (data['data'] as List)
              .map((e) => Publicacion.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      print('Error mis publicaciones: $e');
    }
    return [];
  }

  // Eliminar una publicación
  Future<bool> eliminarPublicacion(
    String idPublicacion,
    String idUsuario,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/publicaciones/eliminar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_usuario': idUsuario,
          'id_publicacion': idPublicacion,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
    } catch (e) {
      print('Error eliminar: $e');
    }
    return false;
  }

  // Editar Publicación
  Future<Map<String, dynamic>> editarPublicacion({
    required Map<String, String> data,
    List<XFile>? nuevasImagenes,
    List<String>? idsEliminar,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/publicaciones/editar'),
      );

      // 1. Campos de texto
      request.fields.addAll(data);

      // 2. Imágenes nuevas (si hay)
      if (nuevasImagenes != null) {
        for (var img in nuevasImagenes) {
          request.files.add(
            await http.MultipartFile.fromPath('imagenes[]', img.path),
          );
        }
      }

      // 3. Imágenes a eliminar (si hay)
      if (idsEliminar != null && idsEliminar.isNotEmpty) {
        // La API espera un string separado por comas: "12,45,8"
        request.fields['imagenes_eliminar'] = idsEliminar.join(',');
      }

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

  // Obtener mis favoritos
  Future<List<Publicacion>> getFavoritos(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/favoritos?id_usuario=$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return (data['data'] as List)
              .map((e) => Publicacion.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      print('Error favoritos: $e');
    }
    return [];
  }

  // Dar o Quitar Like (Toggle)
  Future<bool> toggleFavorito(String idPublicacion, String idUsuario) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/favoritos/toggle'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_usuario': idUsuario,
          'id_publicacion': idPublicacion,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
    } catch (e) {
      print('Error toggle favorito: $e');
    }
    return false;
  }
}
