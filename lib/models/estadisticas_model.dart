class Estadisticas {
  final int totalProductos;
  final int totalVistas;
  final int totalContactos;
  final int totalFavoritos;

  Estadisticas({
    required this.totalProductos,
    required this.totalVistas,
    required this.totalContactos,
    required this.totalFavoritos,
  });

  factory Estadisticas.fromJson(Map<String, dynamic> json) {
    return Estadisticas(
      // Convertimos a int asegurando que no falle si viene como String
      totalProductos: int.tryParse(json['total_productos'].toString()) ?? 0,
      totalVistas: int.tryParse(json['total_vistas'].toString()) ?? 0,
      totalContactos: int.tryParse(json['total_contactos'].toString()) ?? 0,
      totalFavoritos: int.tryParse(json['total_favoritos'].toString()) ?? 0,
    );
  }
}
