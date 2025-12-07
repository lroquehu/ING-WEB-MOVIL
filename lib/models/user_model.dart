class User {
  final String id;
  final String nombres;
  final String apellidos;
  final String email;
  final String? fotoPerfil;

  // --- Nuevos campos para editar ---
  final String? telefono;
  final String? facultad;
  final String? escuela;

  User({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.email,
    this.fotoPerfil,
    this.telefono,
    this.facultad,
    this.escuela,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id_usuario'].toString(),
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      // Soporte híbrido para Login (correo) y Perfil (correo_institucional)
      email: json['correo'] ?? json['correo_institucional'] ?? '',
      fotoPerfil: json['foto_perfil'],

      // Mapeamos los nuevos campos (pueden venir nulos)
      telefono: json['telefono'],
      facultad: json['facultad'],
      escuela: json['escuela'],
    );
  }
}
