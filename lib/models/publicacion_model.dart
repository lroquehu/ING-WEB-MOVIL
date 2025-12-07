class Publicacion {
  final String id;
  final String titulo;
  final double precio;
  final String imagen;
  final String categoria;
  final String vendedor;
  final String? fotoVendedor;

  // --- Nuevos campos para el detalle ---
  final String? descripcion;
  final String? telefono;
  final String? correo;
  final String? fecha;
  final List<String>? galeria;

  Publicacion({
    required this.id,
    required this.titulo,
    required this.precio,
    required this.imagen,
    required this.categoria,
    required this.vendedor,
    this.fotoVendedor,
    this.descripcion,
    this.telefono,
    this.correo,
    this.fecha,
    this.galeria,
  });

  factory Publicacion.fromJson(Map<String, dynamic> json) {
    // CORRECCIÓN AQUÍ: Procesar la galería extrayendo solo la URL
    List<String> galeriaFotos = [];
    if (json['galeria'] != null) {
      // La API devuelve: [{ "id_imagen": "...", "url": "..." }, ...]
      // Nosotros extraemos solo la parte de "url"
      galeriaFotos = (json['galeria'] as List)
          .map((item) {
            // A veces la API puede mandar strings directos o mapas, nos aseguramos:
            if (item is String) {
              return item;
            } else if (item is Map) {
              return item['url'].toString();
            }
            return '';
          })
          .where((url) => url.isNotEmpty)
          .toList();
    }

    return Publicacion(
      id: json['id_publicacion'].toString(),
      titulo: json['titulo'],
      precio: double.tryParse(json['precio'].toString()) ?? 0.0,
      imagen: json['imagen_principal'] ?? json['imagen'] ?? '',
      categoria: json['nombre_categoria'] ?? '',
      vendedor: '${json['nombres']} ${json['apellidos']}',
      fotoVendedor: json['foto_perfil'],

      descripcion: json['descripcion'],
      telefono: json['telefono_contacto'],
      correo: json['correo_contacto'],
      fecha: json['fecha_publicacion'],
      galeria: galeriaFotos,
    );
  }
}
