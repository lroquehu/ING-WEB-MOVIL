class User {
  final String id;
  final String nombres;
  final String apellidos;
  final String email;
  final String? fotoPerfil;

  User({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.email,
    this.fotoPerfil,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id_usuario'].toString(), // Aseguramos que sea String
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      email: json['correo'],
      fotoPerfil: json['foto_perfil'],
    );
  }
}