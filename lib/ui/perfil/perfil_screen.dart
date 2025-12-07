import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/perfil_service.dart';
import '../../models/estadisticas_model.dart';
import '../../models/user_model.dart';
import 'mis_publicaciones_screen.dart';
import 'editar_perfil_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _perfilService = PerfilService();
  bool _isLoading = true;
  Estadisticas? _stats;
  User? _usuarioFresco; // Usuario con datos actualizados de la API

  @override
  void initState() {
    super.initState();
    _cargarDatosPerfil();
  }

  Future<void> _cargarDatosPerfil() async {
    final userSesion = context.read<AuthProvider>().currentUser;
    if (userSesion != null) {
      final datos = await _perfilService.getPerfilCompleto(userSesion.id);
      if (mounted && datos != null) {
        setState(() {
          _usuarioFresco = datos['usuario'];
          _stats = datos['estadisticas'];
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos el usuario de sesión como base, pero preferimos el fresco si ya cargó
    final userSesion = context.watch<AuthProvider>().currentUser;
    final usuario = _usuarioFresco ?? userSesion;

    if (usuario == null)
      return const Scaffold(body: Center(child: Text("Error de sesión")));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _cargarDatosPerfil,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 1. CABECERA DE PERFIL
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          (usuario.fotoPerfil != null &&
                              usuario.fotoPerfil!.isNotEmpty)
                          ? NetworkImage(usuario.fotoPerfil!)
                          : null,
                      child:
                          (usuario.fotoPerfil == null ||
                              usuario.fotoPerfil!.isEmpty)
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: AppTheme.primary,
                            )
                          : null,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "${usuario.nombres} ${usuario.apellidos}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      usuario.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. SECCIÓN DE ESTADÍSTICAS (NUEVO)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _stats == null
                    ? const SizedBox()
                    : Row(
                        children: [
                          _buildStatCard(
                            "Productos",
                            _stats!.totalProductos.toString(),
                            Icons.shopping_bag,
                          ),
                          const SizedBox(width: 10),
                          _buildStatCard(
                            "Vistas",
                            _stats!.totalVistas.toString(),
                            Icons.visibility,
                          ),
                          const SizedBox(width: 10),
                          _buildStatCard(
                            "Likes",
                            _stats!.totalFavoritos.toString(),
                            Icons.favorite,
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 20),

              // 3. OPCIONES DEL MENÚ
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildOption(
                      context,
                      icon: Icons.list_alt,
                      title: "Mis Publicaciones",
                      subtitle: "Administrar mis ventas",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MisPublicacionesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildOption(
                      context,
                      icon: Icons.edit,
                      title: "Editar Datos",
                      subtitle: "Modificar nombre o foto",
                      onTap: () {
                        // Navegar a Editar pasando el usuario actual
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditarPerfilScreen(usuarioActual: usuario),
                          ),
                        ).then((cambio) {
                          // Si regresamos con 'true', recargamos los datos del perfil
                          if (cambio == true) {
                            _cargarDatosPerfil();
                          }
                        });
                      },
                    ),
                    _buildOption(
                      context,
                      icon: Icons.lock_outline,
                      title: "Seguridad",
                      subtitle: "Cambiar contraseña",
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para las tarjetitas de estadísticas
  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 0, // Diseño más plano y moderno
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Icon(icon, color: AppTheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
