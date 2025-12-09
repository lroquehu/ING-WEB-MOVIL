import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/chat_models.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String idConversacion;
  final String nombreOtroUsuario;
  final String idOtroUsuario;

  const ChatScreen({
    super.key,
    required this.idConversacion,
    required this.nombreOtroUsuario,
    required this.idOtroUsuario,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _service = ChatService();
  final _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Mensaje> _mensajes = [];
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _cargarMensajes();
    // Iniciar polling (recargar cada 3 segundos)
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) => _cargarMensajes(quiet: true),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Detener el timer al salir
    _textController.dispose();
    super.dispose();
  }

  Future<void> _cargarMensajes({bool quiet = false}) async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      final msgs = await _service.getMensajes(widget.idConversacion, user.id);
      if (mounted) {
        setState(() {
          _mensajes = msgs; // La API ya los devuelve en orden cronológico
          if (!quiet) _isLoading = false;
        });
        // Bajar al final si es la primera carga
        if (!quiet) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollToBottom(),
          );
        }
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _enviarMensaje() async {
    final texto = _textController.text.trim();
    if (texto.isEmpty) return;

    _textController.clear();
    final user = context.read<AuthProvider>().currentUser;

    if (user != null) {
      // Optimismo visual: Agregar mensaje localmente antes de que el servidor responda
      setState(() {
        _mensajes.add(
          Mensaje(
            id: 'temp',
            contenido: texto,
            idRemitente: user.id,
            fecha: 'Ahora',
            esMio: true,
          ),
        );
      });
      _scrollToBottom();

      await _service.enviarMensaje(widget.idConversacion, user.id, texto);
      _cargarMensajes(
        quiet: true,
      ); // Recargar para confirmar y quitar el 'temp'
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.nombreOtroUsuario,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea( // <--- AÑADIDO PARA EVITAR SUPERPOSICIÓN
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _mensajes.length,
                      itemBuilder: (context, index) {
                        final msg = _mensajes[index];
                        return Align(
                          alignment: msg.esMio
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: msg.esMio
                                  ? AppTheme.primary
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20).copyWith(
                                bottomRight: msg.esMio
                                    ? const Radius.circular(0)
                                    : null,
                                bottomLeft: !msg.esMio
                                    ? const Radius.circular(0)
                                    : null,
                              ),
                            ),
                            child: Text(
                              msg.contenido,
                              style: TextStyle(
                                color: msg.esMio ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Caja de texto
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: "Escribe un mensaje...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _enviarMensaje,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
