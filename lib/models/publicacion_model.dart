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

  // --- NUEVOS CAMPOS DEL VENDEDOR ---
  final String? facultad;
  final String? escuela;
  final String? fechaRegistro;
  // ----------------------------------

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
    this.facultad,
    this.escuela,
    this.fechaRegistro,
    this.galeria,
    this.isFavorite = false,
  });

  factory Publicacion.fromJson(Map<String, dynamic> json) {
    List<ImagenGaleria> galeriaFotos = [];

    if (json['galeria'] != null) {
      for (var item in (json['galeria'] as List)) {
        if (item is Map) {
          galeriaFotos.add(
            ImagenGaleria(
              id: item['id_imagen'].toString(),
              url: item['url'] ?? item['url_imagen'] ?? '',
            ),
          );
        } else if (item is String) {
          galeriaFotos.add(ImagenGaleria(id: '0', url: item));
        }
      }
    }

    // --- LÓGICA MEJORADA PARA EL NOMBRE DEL VENDEDOR ---
    final String nombres = json['nombres'] ?? '';
    final String apellidos = json['apellidos'] ?? '';
    String nombreCompleto = '$nombres $apellidos'.trim();
    if (nombreCompleto.isEmpty) {
      nombreCompleto = 'Vendedor'; // Nombre por defecto si está vacío
    }
    // -----------------------------------------------------

    return Publicacion(
      id: json['id_publicacion'].toString(),
      titulo: json['titulo'],
      precio: double.tryParse(json['precio'].toString()) ?? 0.0,
      imagen: json['imagen_principal'] ?? json['imagen'] ?? '',
      categoria: json['nombre_categoria'] ?? '',
      vendedor: nombreCompleto, // Usamos el nombre completo robusto
      idUsuario: json['id_usuario'].toString(),
      fotoVendedor: json['foto_perfil'],

      descripcion: json['descripcion'],
      telefono: json['telefono_contacto'],
      correo: json['correo_contacto'],
      fecha: json['fecha_publicacion'],
      
      facultad: json['facultad'],
      escuela: json['escuela'],
      fechaRegistro: json['fecha_registro'],

      galeria: galeriaFotos,
      isFavorite: json['es_favorito'] == true || json['es_favorito'] == 1,
    );
  }
}
