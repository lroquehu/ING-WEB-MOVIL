import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/publicacion_model.dart';
import '../models/categoria_model.dart';

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
}
