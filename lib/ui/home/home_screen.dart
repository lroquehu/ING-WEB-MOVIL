import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/home_provider.dart';
import '../shared/product_card.dart';
import '../shared/side_menu.dart';
import '../auth/login_screen.dart';
import '../../providers/auth_provider.dart';
import '../publicacion/crear_publicacion_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    // Usamos Consumer para escuchar cambios en el Provider
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          drawer: const SideMenu(),
          appBar: AppBar(
            backgroundColor: AppTheme.primary,
            iconTheme: const IconThemeData(color: Colors.white), // <-- AÑADIDO PARA EL ICONO DEL MENÚ
            title: _isSearching
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Fondo blanco sólido para el campo de texto
                      borderRadius: BorderRadius.circular(30.0), // Bordes redondeados
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        filled: true, // Asegura que fillColor sea aplicado
                        fillColor: Colors.white, // Fondo blanco para el TextField
                        hintText: 'Buscar productos...',
                        hintStyle: const TextStyle(color: Colors.black), // Texto de sugerencia negro
                        border: InputBorder.none, // Quitamos el borde por defecto del TextField
                        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Padding interno
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, color: Colors.black), // Icono de limpiar negro
                          onPressed: () {
                            _searchController.clear();
                            provider.filtrar(query: ''); // Limpiar el filtro
                          },
                        ),
                      ),
                      style: const TextStyle(color: Colors.black), // Texto que se escribe negro
                      onChanged: (value) {
                        provider.filtrar(query: value);
                      },
                    ),
                  )
                : const Text(
                    'UniEmprende',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            actions: [
              IconButton(
                icon: Icon(
                  _isSearching ? Icons.close : Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      provider.filtrar(query: ''); // Limpiar filtro al cerrar
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          body: SafeArea( // <--- AÑADIDO PARA EVITAR SUPERPOSICIÓN
            child: Column(
              children: [
                // La sección de categorías se ha movido al SideMenu

                // Grilla de Productos
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: () async {
                            // Limpiar filtros antes de recargar
                            _searchController.clear();
                            await provider.restablecerFiltros();
                          },
                          color: AppTheme.primary,
                          child: provider.publicaciones.isEmpty
                              ? ListView(
                                  children: const [
                                    SizedBox(height: 200),
                                    Center(
                                      child: Text("No hay productos disponibles"),
                                    ),
                                  ],
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.all(12),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.7,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                      ),
                                  itemCount: provider.publicaciones.length,
                                  itemBuilder: (context, index) {
                                    return ProductCard(
                                      producto: provider.publicaciones[index],
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
          ),
          // Botón Flotante para Vender
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              if (authProvider.isAuth) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CrearPublicacionScreen(),
                  ),
                ).then((value) {
                  if (value == true) {
                    context.read<HomeProvider>().cargarDatosIniciales();
                  }
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Debes iniciar sesión para vender'),
                  ),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            backgroundColor: AppTheme.accent,
            icon: const Icon(Icons.add_a_photo, color: AppTheme.primary),
            label: const Text(
              "VENDER",
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
