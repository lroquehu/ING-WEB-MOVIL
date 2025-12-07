import 'package:flutter/material.dart';
import '../models/categoria_model.dart';
import '../models/publicacion_model.dart';
import '../services/publicaciones_service.dart';

class HomeProvider extends ChangeNotifier {
  final _service = PublicacionesService();

  List<Categoria> categorias = [];
  List<Publicacion> publicaciones = [];
  List<Publicacion> _allPublicaciones = []; // Nueva lista para todas las publicaciones
  bool isLoading = true;

  String _currentCategoryId = '0'; // 0 = Todas (para mantener la selección visual)
  String _currentSearchQuery = '';

  String get currentCategoryId => _currentCategoryId;

  HomeProvider() {
    cargarDatosIniciales();
  }

  Future<void> cargarDatosIniciales() async {
    isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _service.getCategorias(),
      _service.getPublicaciones(), // Obtener todas sin filtros iniciales
    ]);

    categorias = results[0] as List<Categoria>;
    categorias.insert(0, Categoria(id: '0', nombre: 'Todas'));

    _allPublicaciones = results[1] as List<Publicacion>; // Guardar todas aquí
    _applyFilters(); // Aplicar filtros iniciales (si los hay)

    isLoading = false;
    notifyListeners();
  }

  // Método para filtrar (cuando el usuario toca una categoría o busca)
  void filtrar({String? categoriaId, String? query}) {
    if (categoriaId != null) {
      _currentCategoryId = categoriaId;
      _currentSearchQuery = ''; // Limpiar búsqueda al cambiar categoría
    }
    if (query != null) {
      _currentSearchQuery = query;
    }

    _applyFilters(); // Aplicar todos los filtros
    notifyListeners();
  }

  // Método privado para aplicar los filtros (categoría y búsqueda)
  void _applyFilters() {
    List<Publicacion> tempPublicaciones = List.from(_allPublicaciones);

    // 1. Aplicar filtro de búsqueda por texto (título y descripción)
    if (_currentSearchQuery.isNotEmpty) {
      final searchLower = _currentSearchQuery.toLowerCase();
      tempPublicaciones = tempPublicaciones.where((pub) {
        final titleLower = pub.titulo.toLowerCase();
        final descLower = pub.descripcion?.toLowerCase() ?? '';
        return titleLower.contains(searchLower) || descLower.contains(searchLower);
      }).toList();
    }

    // 2. Aplicar filtro de categoría
    if (_currentCategoryId != '0') {
      tempPublicaciones = tempPublicaciones.where((pub) {
        return pub.categoria == categorias.firstWhere((cat) => cat.id == _currentCategoryId).nombre;
      }).toList();
    }

    publicaciones = tempPublicaciones;
  }

  // Restablecer filtros y recargar (útil para el RefreshIndicator)
  Future<void> restablecerFiltros() async {
    _currentCategoryId = '0';
    _currentSearchQuery = '';
    await cargarDatosIniciales(); // Recargar todo del servicio
  }
}
