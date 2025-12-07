import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/publicacion_model.dart';
import '../../config/theme.dart';

class ProductCard extends StatelessWidget {
  final Publicacion producto;

  const ProductCard({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // Sombra suave como en tu CSS
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior:
          Clip.antiAlias, // Para que la imagen respete los bordes redondeados
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen (Altura fija como en tu CSS .product-image height: 220px)
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: producto.imagen,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.image_not_supported),
                ),
                // Badge de Categoría (Replica tu .product-category)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      producto.categoria,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info del producto
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    producto.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      // Avatar pequeño del vendedor
                      CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: producto.fotoVendedor != null
                            ? NetworkImage(producto.fotoVendedor!)
                            : null,
                        child: producto.fotoVendedor == null
                            ? const Icon(Icons.person, size: 10)
                            : null,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          producto.vendedor,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'S/ ${producto.precio.toStringAsFixed(2)}',
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
    );
  }
}
