import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/publicacion_model.dart';
import '../../services/publicaciones_service.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class DetalleScreen extends StatefulWidget {
  final Publicacion publicacionPrevia;

  const DetalleScreen({super.key, required this.publicacionPrevia});

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  final _service = PublicacionesService();
  Publicacion? _detalleCompleto;
  bool _cargando = true;
  int _currentImageIndex = 0; // Controla qué foto del carrusel estamos viendo

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    // Llamamos a tu API: /api/publicaciones/detalle?id=65
    final detalle = await _service.getDetalle(widget.publicacionPrevia.id);
    if (mounted) {
      setState(() {
        _detalleCompleto = detalle;
        _cargando = false;
      });
    }
  }

  void _contactarVendedor() {
    final authProvider = context.read<AuthProvider>();

    // 1. Validar si está logueado
    if (!authProvider.isAuth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Inicia sesión para chatear con el vendedor"),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    // 2. Lógica del Chat Interno (Próximamente lo conectaremos a ChatController)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Abriendo chat interno... (Próxima Integración)"),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos los datos completos si ya llegaron, si no, los básicos del Home
    final producto = _detalleCompleto ?? widget.publicacionPrevia;

    // --- LÓGICA DEL CARRUSEL CORREGIDA ---
    // Usamos un Set para evitar duplicados automáticos

    final Set<String> imagenesSet = {};

    // 1. Imagen principal
    if (producto.imagen.isNotEmpty && !producto.imagen.contains("no-image")) {
      imagenesSet.add(producto.imagen);
    }

    // 2. Galería (Extraemos solo la URL de los objetos)
    if (producto.galeria != null) {
      for (var imgObj in producto.galeria!) {
        // AHORA ES UN OBJETO, HAY QUE ACCEDER A .URL
        if (imgObj.url.isNotEmpty) {
          imagenesSet.add(imgObj.url);
        }
      }
    }

    // Convertir a lista para el PageView
    final List<String> imagenes = imagenesSet.toList();

    // Si no hay ninguna imagen, ponemos una por defecto para que no truene
    if (imagenes.isEmpty) {
      imagenes.add("https://via.placeholder.com/400x300?text=Sin+Imagen");
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. ZONA DE IMÁGENES (CARRUSEL)
          SliverAppBar(
            expandedHeight: 350, // Altura de la imagen
            pinned: true,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // EL SLIDER DE FOTOS
                  PageView.builder(
                    itemCount: imagenes.length,
                    onPageChanged: (index) =>
                        setState(() => _currentImageIndex = index),
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: imagenes[index],
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: Colors.grey[200]),
                        errorWidget: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),

                  // LOS PUNTITOS (INDICADORES)
                  if (imagenes.length > 1)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: imagenes.asMap().entries.map((entry) {
                          return Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(
                                _currentImageIndex == entry.key ? 0.9 : 0.4,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 2. INFORMACIÓN DEL PRODUCTO
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Precio y Badge de Categoría
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'S/ ${producto.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            producto.categoria,
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Título del Producto
                    Text(
                      producto.titulo,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Tarjeta del Vendedor
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[200],
                            backgroundImage:
                                (producto.fotoVendedor != null &&
                                    producto.fotoVendedor!.isNotEmpty)
                                ? NetworkImage(producto.fotoVendedor!)
                                : null,
                            child:
                                (producto.fotoVendedor == null ||
                                    producto.fotoVendedor!.isEmpty)
                                ? const Icon(Icons.person, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  producto.vendedor,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Text(
                                  "Vendedor",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),
                    const Text(
                      "Descripción",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Descripción del producto (Carga con la API)
                    _cargando
                        ? const Center(child: CircularProgressIndicator())
                        : Text(
                            (producto.descripcion != null &&
                                    producto.descripcion!.isNotEmpty)
                                ? producto.descripcion!
                                : "El vendedor no añadió una descripción detallada.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                              height: 1.6,
                            ),
                          ),

                    const SizedBox(
                      height: 100,
                    ), // Espacio para el botón flotante
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),

      // BOTÓN DE ACCIÓN
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _contactarVendedor,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: const Text(
          "CONTACTAR",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
