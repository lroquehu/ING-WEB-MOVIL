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
  final List<String>? galeria; // <--- ESTE ES EL QUE FALTA

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
    // Procesar galería si viene en el JSON
    List<String> galeriaFotos = [];
    if (json['galeria'] != null) {
      // Convertimos la lista dinámica a lista de Strings
      galeriaFotos = List<String>.from(json['galeria']);
    }

    return Publicacion(
      id: json['id_publicacion'].toString(),
      titulo: json['titulo'],
      precio: double.tryParse(json['precio'].toString()) ?? 0.0,
      imagen: json['imagen_principal'] ?? '',
      categoria: json['nombre_categoria'] ?? '',
      vendedor: '${json['nombres']} ${json['apellidos']}',
      fotoVendedor: json['foto_perfil'],

      // Mapeo de los nuevos campos
      descripcion: json['descripcion'],
      telefono: json['telefono_contacto'],
      correo: json['correo_contacto'],
      fecha: json['fecha_publicacion'],
      galeria: galeriaFotos, // <--- Aquí llenamos la galería
    );
  }
}
