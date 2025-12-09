class ImagenGaleria {
  final String id;
  final String url;
  ImagenGaleria({required this.id, required this.url});
}

class Publicacion {
  final String id;
  final String titulo;
  final double precio;
  final String imagen;
  final String categoria;
  final String vendedor;
  final String idUsuario;
  final String? fotoVendedor;

  final String? descripcion;
  final String? telefono;
  final String? correo;
  final String? fecha;

  // CAMBIO: Ahora es una lista de objetos, no de strings
  final List<ImagenGaleria>? galeria;

  bool isFavorite;

  Publicacion({
    required this.id,
    required this.titulo,
    required this.precio,
    required this.imagen,
    required this.categoria,
    required this.vendedor,
    required this.idUsuario,
    this.fotoVendedor,
    this.descripcion,
    this.telefono,
    this.correo,
    this.fecha,
    this.galeria,
    this.isFavorite = false,
  });

  factory Publicacion.fromJson(Map<String, dynamic> json) {
    // Procesar galería guardando ID y URL
    List<ImagenGaleria> galeriaFotos = [];

    if (json['galeria'] != null) {
      for (var item in (json['galeria'] as List)) {
        // La API puede devolver objetos {id_imagen: ..., url_imagen: ...}
        if (item is Map) {
          galeriaFotos.add(
            ImagenGaleria(
              id: item['id_imagen'].toString(),
              url:
                  item['url'] ??
                  item['url_imagen'] ??
                  '', // Aseguramos compatibilidad de nombres
            ),
          );
        }
        // Si por alguna razón devolviera strings directos (antiguo)
        else if (item is String) {
          galeriaFotos.add(ImagenGaleria(id: '0', url: item));
        }
      }
    }

    return Publicacion(
      id: json['id_publicacion'].toString(),
      titulo: json['titulo'],
      precio: double.tryParse(json['precio'].toString()) ?? 0.0,
      imagen: json['imagen_principal'] ?? json['imagen'] ?? '',
      categoria: json['nombre_categoria'] ?? '',
      vendedor: '${json['nombres']} ${json['apellidos']}',
      idUsuario: json['id_usuario'].toString(),
      fotoVendedor: json['foto_perfil'],

      descripcion: json['descripcion'],
      telefono: json['telefono_contacto'],
      correo: json['correo_contacto'],
      fecha: json['fecha_publicacion'],

      // Asignamos la lista de objetos ImagenGaleria
      galeria: galeriaFotos,
      isFavorite: json['es_favorito'] == true || json['es_favorito'] == 1,
    );
  }
}
