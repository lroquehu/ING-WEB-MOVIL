import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/publicacion_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/publicaciones_service.dart';
import '../publicacion/crear_publicacion_screen.dart'; // Para el botón flotante

class MisPublicacionesScreen extends StatefulWidget {
  const MisPublicacionesScreen({super.key});

  @override
  State<MisPublicacionesScreen> createState() => _MisPublicacionesScreenState();
}

class _MisPublicacionesScreenState extends State<MisPublicacionesScreen> {
  final _service = PublicacionesService();
  List<Publicacion> _misProductos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarMisProductos();
  }

  Future<void> _cargarMisProductos() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      final productos = await _service.getMisPublicaciones(user.id);
      if (mounted) {
        setState(() {
          _misProductos = productos;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _eliminarProducto(String idPublicacion) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar publicación?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        setState(() => _isLoading = true); // Mostrar carga
        final exito = await _service.eliminarPublicacion(
          idPublicacion,
          user.id,
        );

        if (exito) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Publicación eliminada'),
                backgroundColor: Colors.green,
              ),
            );
            _cargarMisProductos(); // Recargar lista
          }
        } else {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al eliminar'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Ventas', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _misProductos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aún no has publicado nada',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CrearPublicacionScreen(),
                      ),
                    ).then((_) => _cargarMisProductos()),
                    icon: const Icon(Icons.add),
                    label: const Text('PUBLICAR AHORA'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargarMisProductos,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _misProductos.length,
                itemBuilder: (context, index) {
                  final prod = _misProductos[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(prod.imagen),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        prod.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'S/ ${prod.precio.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            prod.categoria,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Botón Editar (Gris - Próximamente)
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.grey),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Edición disponible próximamente",
                                  ),
                                ),
                              );
                            },
                          ),
                          // Botón Eliminar (Rojo)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _eliminarProducto(prod.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
