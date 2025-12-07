class Publicacion {
  final String id;
  final String titulo;
  final double precio;
  final String imagen;
  final String categoria;
  final String vendedor;
  final String? fotoVendedor;

  Publicacion({
    required this.id,
    required this.titulo,
    required this.precio,
    required this.imagen,
    required this.categoria,
    required this.vendedor,
    this.fotoVendedor,
  });

  factory Publicacion.fromJson(Map<String, dynamic> json) {
    return Publicacion(
      id: json['id_publicacion'].toString(),
      titulo: json['titulo'],
      precio: double.parse(json['precio'].toString()),
      imagen: json['imagen_principal'] ?? '',
      categoria: json['nombre_categoria'],
      vendedor: '${json['nombres']} ${json['apellidos']}',
      fotoVendedor: json['foto_perfil'],
    );
  }
}
