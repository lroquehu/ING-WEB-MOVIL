import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniemprende_movil/providers/home_provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../../ui/perfil/perfil_screen.dart';
import '../../ui/perfil/mis_publicaciones_screen.dart';
import '../publicacion/favoritos_screen.dart';
import '../chat/lista_chats_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final usuario = authProvider.currentUser;
    final isAuth = authProvider.isAuth;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 1. ENCABEZADO
          isAuth
              ? UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: AppTheme.primary),
                  accountName: Text(
                    "${usuario?.nombres} ${usuario?.apellidos}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  accountEmail: Text(usuario?.email ?? ""),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: AppTheme.primary,
                    ),
                  ),
                )
              : DrawerHeader(
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/pattern.png',
                      ),
                      fit: BoxFit.cover,
                      opacity: 0.1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.school, size: 48, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        "Bienvenido a UniEmprende",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Inicia sesión para vender",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),

          // 2. OPCIONES COMUNES
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Inicio'),
            onTap: () {
                context.read<HomeProvider>().restablecerFiltros();
                Navigator.pop(context);
            },
          ),

          const Divider(),

          // --- SECCIÓN DE CATEGORÍAS DESPLEGABLE ---
          Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              return ExpansionTile(
                title: const Text(
                  'Categorías',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.normal, // Cambiado a normal
                  ),
                ),
                leading: const Icon(Icons.category, color: Colors.black54),
                iconColor: AppTheme.primary,
                collapsedIconColor: Colors.black54,
                children: homeProvider.categorias.map((cat) {
                  final isSelected = homeProvider.currentCategoryId == cat.id;
                  return ListTile(
                    title: Text(
                      cat.nombre,
                      style: TextStyle(
                        color: isSelected ? AppTheme.primary : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      homeProvider.filtrar(categoriaId: cat.id);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              );
            },
          ),
          const Divider(),

          // 3. OPCIONES CONDICIONALES
          if (isAuth) ...[
            // ... (resto de las opciones de menú)
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Mi Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PerfilScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: const Text('Mis Ventas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MisPublicacionesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Favoritos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritosScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Mensajes'),
              onTap: () {
                Navigator.pop(context); // Cierra el menú
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ListaChatsScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                context.read<AuthProvider>().logout();
                Navigator.pop(context);
              },
            ),

          ] else ...[
            // ... (opciones de menú para invitados)
            ListTile(
              leading: const Icon(Icons.login, color: AppTheme.primary),
              title: const Text(
                'Iniciar Sesión',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add_outlined),
              title: const Text('Registrarse'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
