import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/publicacion_model.dart';
import '../../services/publicaciones_service.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../chat/chat_screen.dart';
import '../../services/chat_service.dart';
import '../perfil/ver_perfil_screen.dart';

class DetalleScreen extends StatefulWidget {
  final Publicacion publicacionPrevia;

  const DetalleScreen({super.key, required this.publicacionPrevia});

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  final _service = PublicacionesService();
  final _chatService = ChatService();
  Publicacion? _detalleCompleto;
  bool _cargando = true;
  bool _cargandoChat = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    final detalle = await _service.getDetalle(widget.publicacionPrevia.id);
    if (mounted) {
      setState(() {
        _detalleCompleto = detalle;
        _cargando = false;
      });
    }
  }

  void _contactarVendedor() async {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isAuth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inicia sesión para chatear")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    final miId = authProvider.currentUser!.id;
    final producto = _detalleCompleto ?? widget.publicacionPrevia;
    final otroId = producto.idUsuario;

    if (miId == otroId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No puedes chatear contigo mismo")),
      );
      return;
    }

    setState(() => _cargandoChat = true);

    final idConversacion = await _chatService.iniciarConversacion(miId, otroId);

    if (!mounted) return;
    setState(() => _cargandoChat = false);

    if (idConversacion != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            idConversacion: idConversacion,
            nombreOtroUsuario: producto.vendedor,
            idOtroUsuario: otroId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al iniciar el chat"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final producto = _detalleCompleto ?? widget.publicacionPrevia;

    final Set<String> imagenesSet = {};

    if (producto.imagen.isNotEmpty && !producto.imagen.contains("no-image")) {
      imagenesSet.add(producto.imagen);
    }

    if (producto.galeria != null) {
      for (var imgObj in producto.galeria!) {
        if (imgObj.url.isNotEmpty) {
          imagenesSet.add(imgObj.url);
        }
      }
    }

    final List<String> imagenes = imagenesSet.toList();

    if (imagenes.isEmpty) {
      imagenes.add("https://via.placeholder.com/400x300?text=Sin+Imagen");
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    itemCount: imagenes.length,
                    onPageChanged: (index) =>
                        setState(() => _currentImageIndex = index),
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: imagenes[index],
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: Colors.grey[200]),
                        errorWidget: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                  if (imagenes.length > 1)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: imagenes.asMap().entries.map((entry) {
                          return Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(
                                _currentImageIndex == entry.key ? 0.9 : 0.4,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'S/ ${producto.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            producto.categoria,
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      producto.titulo,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 25),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VerPerfilScreen(publicacion: producto),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey[200],
                              backgroundImage:
                                  (producto.fotoVendedor != null &&
                                      producto.fotoVendedor!.isNotEmpty)
                                  ? NetworkImage(producto.fotoVendedor!)
                                  : null,
                              child:
                                  (producto.fotoVendedor == null ||
                                      producto.fotoVendedor!.isEmpty)
                                  ? const Icon(Icons.person, color: Colors.grey)
                                  : null,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    producto.vendedor,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Text(
                                    "Vendedor",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "Descripción",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _cargando
                        ? const Center(child: CircularProgressIndicator())
                        : Text(
                            (producto.descripcion != null &&
                                    producto.descripcion!.isNotEmpty)
                                ? producto.descripcion!
                                : "El vendedor no añadió una descripción detallada.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                              height: 1.6,
                            ),
                          ),
                    const SizedBox(
                      height: 100,
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      floatingActionButton: SafeArea( // <--- AÑADIDO PARA EVITAR SUPERPOSICIÓN
        child: FloatingActionButton.extended(
          onPressed: _cargandoChat ? null : _contactarVendedor,
          backgroundColor: AppTheme.primary,
          icon: _cargandoChat
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.chat, color: Colors.white),
          label: Text(
            _cargandoChat ? "CONECTANDO..." : "CONTACTAR",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
