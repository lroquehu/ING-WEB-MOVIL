import 'package:flutter/material.dart';
import 'package:uniemprende_movil/config/theme.dart';
import 'package:uniemprende_movil/models/publicacion_model.dart';
import 'package:uniemprende_movil/services/publicaciones_service.dart';
import 'package:uniemprende_movil/ui/shared/product_card.dart';

class VendedorPublicacionesScreen extends StatefulWidget {
  final String idVendedor;
  final String nombreVendedor;

  const VendedorPublicacionesScreen({
    super.key,
    required this.idVendedor,
    required this.nombreVendedor,
  });

  @override
  State<VendedorPublicacionesScreen> createState() =>
      _VendedorPublicacionesScreenState();
}

class _VendedorPublicacionesScreenState extends State<VendedorPublicacionesScreen> {
  final PublicacionesService _service = PublicacionesService();
  late Future<List<Publicacion>> _publicacionesFuture;

  @override
  void initState() {
    super.initState();
    // Iniciamos la carga de las publicaciones del vendedor
    _publicacionesFuture = _service.getMisPublicaciones(widget.idVendedor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Publicaciones de ${widget.nombreVendedor}', style: const TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea( // <--- AÑADIDO PARA EVITAR SUPERPOSICIÓN
        child: FutureBuilder<List<Publicacion>>(
          future: _publicacionesFuture,
          builder: (context, snapshot) {
            // Estado de carga
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Estado de error
            if (snapshot.hasError) {
              return const Center(
                child: Text('Ocurrió un error al cargar las publicaciones.'),
              );
            }

            final publicaciones = snapshot.data;

            // Si no hay publicaciones
            if (publicaciones == null || publicaciones.isEmpty) {
              return const Center(
                child: Text('Este vendedor aún no tiene publicaciones.'),
              );
            }

            // Estado con datos: mostramos la grilla
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: publicaciones.length,
              itemBuilder: (context, index) {
                // Reutilizamos el ProductCard que ya existe
                return ProductCard(producto: publicaciones[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
