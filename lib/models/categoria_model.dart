class Categoria {
  final String id;
  final String nombre;

  Categoria({required this.id, required this.nombre});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id_categoria'].toString(),
      nombre: json['nombre_categoria'],
    );
  }
}
