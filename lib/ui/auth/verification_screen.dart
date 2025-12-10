import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniemprende_movil/config/theme.dart';
import 'package:uniemprende_movil/providers/auth_provider.dart';
import 'package:uniemprende_movil/ui/auth/login_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenCtrl = TextEditingController();

  void _handleVerification() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    // Llamada actualizada para enviar también el correo
    final error = await authProvider.verificarCuenta(
      _tokenCtrl.text,
      widget.email, // <-- AÑADIDO
    );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta verificada con éxito! Ya puedes iniciar sesión.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.mark_email_read_outlined,
                    size: 80,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    '¡Casi listo! Verifica tu cuenta',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hemos enviado un correo a:\n${widget.email}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Opción 1: Ingresa el código que recibiste.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _tokenCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Código / Token de Verificación',
                    ),
                    textAlign: TextAlign.center,
                    validator: (v) => (v == null || v.isEmpty) ? 'Ingresa el código' : null,
                  ),
                  const SizedBox(height: 30),
                  Consumer<AuthProvider>(
                    builder: (context, provider, _) {
                      return ElevatedButton(
                        onPressed: provider.isLoading ? null : _handleVerification,
                        child: provider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('VERIFICAR CUENTA'),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 20),
                  const Text(
                    'Opción 2: Verifica desde tu correo.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Abre el correo y haz clic en el enlace de verificación para activar tu cuenta directamente.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
