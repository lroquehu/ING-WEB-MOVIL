import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/publicacion_model.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/publicaciones_service.dart';
import '../publicacion/detalle_screen.dart';
import '../auth/login_screen.dart';

class ProductCard extends StatefulWidget {
  final Publicacion producto;

  const ProductCard({super.key, required this.producto});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  // Nota: Como la API 'index' no devuelve si es favorito,
  // esto se gestionará localmente al tocarlo o en la pantalla de favoritos.
  bool _isLiked = false;
  @override
  void initState() {
    super.initState();
    // Aquí le decimos: "Inicia con el valor que viene de la base de datos"
    _isLiked = widget.producto.isFavorite;
  }

  // Si la tarjeta se recicla en una lista, actualizamos el estado
  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.producto.isFavorite != widget.producto.isFavorite) {
      _isLiked = widget.producto.isFavorite;
    }
  }

  // ------------------------------
  void _toggleLike() async {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isAuth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inicia sesión para guardar favoritos")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    // Feedback visual inmediato (Optimista)
    setState(() => _isLiked = !_isLiked);

    final service = PublicacionesService();
    final exito = await service.toggleFavorito(
      widget.producto.id,
      authProvider.currentUser!.id,
    );

    if (!exito) {
      // Revertir si falló
      if (mounted) setState(() => _isLiked = !_isLiked);
    } else {
      // Actualizamos el modelo original para que persista
      widget.producto.isFavorite = _isLiked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalleScreen(publicacionPrevia: widget.producto),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.producto.imagen,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.image_not_supported),
                  ),

                  // Badge Categoría
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.producto.categoria,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // BOTÓN DE CORAZÓN (NUEVO)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: InkWell(
                      onTap: _toggleLike,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // --- TITULO ---
                    Text(
                      widget.producto.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    // --- AVATAR Y VENDEDOR (REINSERTADO) ---
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: widget.producto.fotoVendedor != null
                              ? NetworkImage(widget.producto.fotoVendedor!)
                              : null,
                          child: widget.producto.fotoVendedor == null
                              ? const Icon(Icons.person, size: 10)
                              : null,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.producto.vendedor,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // --- FIN DE AVATAR Y VENDEDOR ---

                    // --- PRECIO ---
                    Text(
                      'S/ ${widget.producto.precio.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
