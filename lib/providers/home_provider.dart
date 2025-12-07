import 'package:flutter/material.dart';
import '../models/categoria_model.dart';
import '../models/publicacion_model.dart';
import '../services/publicaciones_service.dart';

class HomeProvider extends ChangeNotifier {
  final _service = PublicacionesService();

  List<Categoria> categorias = [];
  List<Publicacion> publicaciones = [];
  bool isLoading = true;

  String _filtroCategoria = '0'; // 0 = Todas
  String _busqueda = '';

  HomeProvider() {
    cargarDatosIniciales();
  }

  Future<void> cargarDatosIniciales() async {
    isLoading = true;
    notifyListeners();

    // Cargar todo en paralelo para que sea rápido
    final results = await Future.wait([
      _service.getCategorias(),
      _service.getPublicaciones(),
    ]);

    categorias = results[0] as List<Categoria>;
    // Agregamos opción "Todas" al inicio
    categorias.insert(0, Categoria(id: '0', nombre: 'Todas'));

    publicaciones = results[1] as List<Publicacion>;

    isLoading = false;
    notifyListeners();
  }

  // Método para filtrar (cuando el usuario toca una categoría o busca)
  Future<void> filtrar({String? categoriaId, String? query}) async {
    if (categoriaId != null) _filtroCategoria = categoriaId;
    if (query != null) _busqueda = query;

    isLoading = true;
    notifyListeners();

    publicaciones = await _service.getPublicaciones(
      catId: _filtroCategoria == '0' ? '' : _filtroCategoria,
      search: _busqueda,
    );

    isLoading = false;
    notifyListeners();
  }
}
