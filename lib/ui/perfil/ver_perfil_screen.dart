import 'package:flutter/material.dart';
import 'package:uniemprende_movil/config/theme.dart';
import 'package:uniemprende_movil/models/publicacion_model.dart';
import 'package:uniemprende_movil/ui/publicacion/vendedor_publicaciones_screen.dart';

class VerPerfilScreen extends StatelessWidget {
  final Publicacion publicacion;

  const VerPerfilScreen({super.key, required this.publicacion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Vendedor', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea( // <--- AÑADIDO PARA EVITAR SUPERPOSICIÓN
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: double.infinity),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: publicacion.fotoVendedor != null && publicacion.fotoVendedor!.isNotEmpty
                      ? NetworkImage(publicacion.fotoVendedor!) as ImageProvider
                      : const AssetImage('assets/img/user_placeholder.png'),
                ),
                const SizedBox(height: 16),
                Text(
                  publicacion.vendedor,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                if (publicacion.fechaRegistro != null && publicacion.fechaRegistro!.isNotEmpty)
                  Text(
                    'Miembro desde ${publicacion.fechaRegistro}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),

                const SizedBox(height: 24),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.storefront, color: AppTheme.primary),
                  title: const Text('Ver todas las publicaciones'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VendedorPublicacionesScreen(
                          idVendedor: publicacion.idUsuario,
                          nombreVendedor: publicacion.vendedor,
                        ),
                      ),
                    );
                  },
                ),
                const Divider(),

                if (publicacion.facultad != null || publicacion.escuela != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Información Académica',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        if (publicacion.facultad != null && publicacion.facultad!.isNotEmpty)
                          ListTile(
                            leading: const Icon(Icons.school, color: AppTheme.primary),
                            title: const Text('Facultad'),
                            subtitle: Text(publicacion.facultad!),
                          ),
                        if (publicacion.escuela != null && publicacion.escuela!.isNotEmpty)
                          ListTile(
                            leading: const Icon(Icons.history_edu, color: AppTheme.primary),
                            title: const Text('Escuela Profesional'),
                            subtitle: Text(publicacion.escuela!),
                          ),
                        const Divider(),
                      ],
                    ),
                  ),

                const Text(
                  'Información de Contacto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (publicacion.correo != null && publicacion.correo!.isNotEmpty)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.email, color: AppTheme.primary),
                      title: const Text('Correo Electrónico'),
                      subtitle: Text(publicacion.correo!),
                    ),
                  ),
                if (publicacion.telefono != null && publicacion.telefono!.isNotEmpty)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.phone, color: AppTheme.primary),
                      title: const Text('Teléfono'),
                      subtitle: Text(publicacion.telefono!),
                    ),
                  ),
                if ((publicacion.correo == null || publicacion.correo!.isEmpty) && (publicacion.telefono == null || publicacion.telefono!.isEmpty))
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      'El vendedor no ha proporcionado datos de contacto públicos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
