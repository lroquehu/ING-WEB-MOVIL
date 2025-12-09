import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/chat_models.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import 'chat_screen.dart'; // Crearemos esto en el siguiente paso

class ListaChatsScreen extends StatefulWidget {
  const ListaChatsScreen({super.key});

  @override
  State<ListaChatsScreen> createState() => _ListaChatsScreenState();
}

class _ListaChatsScreenState extends State<ListaChatsScreen> {
  final _service = ChatService();
  List<Conversacion> _conversaciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarChats();
  }

  Future<void> _cargarChats() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      final chats = await _service.getConversaciones(user.id);
      if (mounted) {
        setState(() {
          _conversaciones = chats;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajes', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversaciones.isEmpty
          ? const Center(child: Text("No tienes mensajes aún"))
          : RefreshIndicator(
              onRefresh: _cargarChats,
              child: ListView.separated(
                itemCount: _conversaciones.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final chat = _conversaciones[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: chat.fotoOtroUsuario != null
                          ? NetworkImage(chat.fotoOtroUsuario!)
                          : null,
                      child: chat.fotoOtroUsuario == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(
                      chat.nombreOtroUsuario,
                      style: TextStyle(
                        fontWeight: chat.noLeidos > 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      chat.ultimoMensaje,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: chat.noLeidos > 0 ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    trailing: chat.noLeidos > 0
                        ? CircleAvatar(
                            radius: 10,
                            backgroundColor: AppTheme.primary,
                            child: Text(
                              chat.noLeidos.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          )
                        : null,
                    onTap: () {
                      // Navegar a la sala de chat
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            idConversacion: chat.idConversacion,
                            nombreOtroUsuario: chat.nombreOtroUsuario,
                            idOtroUsuario: chat.idOtroUsuario, // Para la API
                          ),
                        ),
                      ).then(
                        (_) => _cargarChats(),
                      ); // Recargar al volver por si leyó mensajes
                    },
                  );
                },
              ),
            ),
    );
  }
}
