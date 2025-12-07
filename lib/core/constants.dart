class ApiConstants {
  // CAMBIA ESTO:

  // COMENTA O BORRA ESTA LÍNEA (Es solo para emulador):
  // static const String baseUrl = 'http://10.0.2.2:8000/ING-WEB-PROYECTO/api';

  // DESCOMENTA Y USA ESTA (Tu VPS real):
  static const String baseUrl =
      'https://sv-fhj9pa34z7eatkdstwlm.cloud.elastika.pe/ING-WEB-PROYECTO/api';

  // Endpoints específicos (Se quedan igual)
  static const String login = '$baseUrl/auth/login';
  static const String registro = '$baseUrl/auth/registro';
  static const String publicaciones = '$baseUrl/publicaciones';
}
