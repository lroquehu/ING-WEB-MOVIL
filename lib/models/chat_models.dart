class Conversacion {
  final String idConversacion;
  final String idOtroUsuario;
  final String nombreOtroUsuario;
  final String? fotoOtroUsuario;
  final String ultimoMensaje;
  final String fechaUltimoMensaje;
  final int noLeidos;

  Conversacion({
    required this.idConversacion,
    required this.idOtroUsuario,
    required this.nombreOtroUsuario,
    this.fotoOtroUsuario,
    required this.ultimoMensaje,
    required this.fechaUltimoMensaje,
    required this.noLeidos,
  });

  factory Conversacion.fromJson(Map<String, dynamic> json) {
    return Conversacion(
      idConversacion: json['id_conversacion'].toString(),
      idOtroUsuario: json['id_otro_usuario'].toString(),
      nombreOtroUsuario: '${json['nombres']} ${json['apellidos']}',
      fotoOtroUsuario: json['foto_otro_usuario'],
      ultimoMensaje: json['ultimo_mensaje'] ?? 'Imagen',
      fechaUltimoMensaje: json['fecha_ultimo_mensaje'] ?? '',
      noLeidos: int.tryParse(json['no_leidos'].toString()) ?? 0,
    );
  }
}

class Mensaje {
  final String id;
  final String contenido;
  final String idRemitente;
  final String fecha;
  final bool esMio; // Helper para saber si lo pinto a la derecha o izquierda

  Mensaje({
    required this.id,
    required this.contenido,
    required this.idRemitente,
    required this.fecha,
    required this.esMio,
  });

  factory Mensaje.fromJson(Map<String, dynamic> json, String miId) {
    return Mensaje(
      id: json['id_mensaje'].toString(),
      contenido: json['contenido'],
      idRemitente: json['id_remitente'].toString(),
      fecha: json['fecha_envio'],
      esMio: json['id_remitente'].toString() == miId,
    );
  }
}
