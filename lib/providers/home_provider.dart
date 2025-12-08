import 'package:flutter/material.dart';
import '../models/categoria_model.dart';
import '../models/publicacion_model.dart';
import '../services/publicaciones_service.dart';
import 'auth_provider.dart';

class HomeProvider extends ChangeNotifier {
  final _service = PublicacionesService();
  AuthProvider? _authProvider;

  List<Categoria> categorias = [];
  List<Publicacion> publicaciones = [];
  List<Publicacion> _allPublicaciones = [];
  bool isLoading = true;

  String _currentCategoryId = '0';
  String _currentSearchQuery = '';

  String get currentCategoryId => _currentCategoryId;

  HomeProvider();

  // Método especial que llamará el main.dart para darnos el AuthProvider
  void update(AuthProvider auth) {
    // Detectar si el usuario cambió (ej: pasó de null a tener ID al iniciar app)
    final oldUserId = _authProvider?.currentUser?.id;
    final newUserId = auth.currentUser?.id;

    _authProvider = auth;

    // Recargar SI la lista está vacía O SI el usuario cambió (para actualizar corazones)
    if (publicaciones.isEmpty || oldUserId != newUserId) {
      Future.microtask(() => cargarDatosIniciales());
    }
  }

  Future<void> cargarDatosIniciales() async {
    // Si ya estamos cargando, evitamos doble llamada
    // if (isLoading) return;
    // (Comentado porque a veces necesitamos forzar la recarga visual)

    isLoading = true;
    notifyListeners();

    // Obtenemos el ID actualizado
    final userId = _authProvider?.currentUser?.id;

    try {
      final results = await Future.wait([
        _service.getCategorias(),
        // Enviamos el userId para que el servidor nos diga qué es favorito
        _service.getPublicaciones(userId: userId),
      ]);

      categorias = results[0] as List<Categoria>;
      if (categorias.isEmpty || categorias[0].id != '0') {
        categorias.insert(0, Categoria(id: '0', nombre: 'Todas'));
      }

      _allPublicaciones = results[1] as List<Publicacion>;
      _applyFilters();
    } catch (e) {
      print("Error cargando home: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  void filtrar({String? categoriaId, String? query}) {
    if (categoriaId != null) {
      _currentCategoryId = categoriaId;
      _currentSearchQuery = '';
    }
    if (query != null) {
      _currentSearchQuery = query;
    }

    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    List<Publicacion> tempPublicaciones = List.from(_allPublicaciones);

    if (_currentSearchQuery.isNotEmpty) {
      final searchLower = _currentSearchQuery.toLowerCase();
      tempPublicaciones = tempPublicaciones.where((pub) {
        final titleLower = pub.titulo.toLowerCase();
        final descLower = pub.descripcion?.toLowerCase() ?? '';
        return titleLower.contains(searchLower) ||
            descLower.contains(searchLower);
      }).toList();
    }

    if (_currentCategoryId != '0') {
      tempPublicaciones = tempPublicaciones.where((pub) {
        return pub.categoria ==
            categorias.firstWhere((cat) => cat.id == _currentCategoryId).nombre;
      }).toList();
    }

    publicaciones = tempPublicaciones;
  }

  Future<void> restablecerFiltros() async {
    _currentCategoryId = '0';
    _currentSearchQuery = '';
    await cargarDatosIniciales();
  }
}
