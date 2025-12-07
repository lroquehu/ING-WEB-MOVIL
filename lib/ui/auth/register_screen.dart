import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para todos los campos de tu API
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _dniCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _facultadCtrl = TextEditingController();
  final _escuelaCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      // Preparar JSON para la API
      final datos = {
        "nombres": _nombresCtrl.text,
        "apellidos": _apellidosCtrl.text,
        "dni": _dniCtrl.text,
        "telefono": _telefonoCtrl.text,
        "correo": _correoCtrl.text,
        "codigo_univ": _codigoCtrl.text,
        "facultad": _facultadCtrl.text,
        "escuela": _escuelaCtrl.text,
        "password": _passCtrl.text,
      };

      final error = await authProvider.registro(datos);

      if (!mounted) return;

      if (error == null) {
        // Éxito: Mostrar mensaje y volver al login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '¡Registro exitoso! Revisa tu correo para verificar.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Volver atrás
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crear Cuenta',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Únete a la comunidad",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Campos del formulario
              _buildInput("Nombres", _nombresCtrl, Icons.person),
              _buildInput("Apellidos", _apellidosCtrl, Icons.person_outline),
              _buildInput("DNI", _dniCtrl, Icons.badge, isNumber: true),
              _buildInput(
                "Teléfono",
                _telefonoCtrl,
                Icons.phone,
                isNumber: true,
              ),
              _buildInput("Correo Institucional", _correoCtrl, Icons.email),
              _buildInput("Código Universitario", _codigoCtrl, Icons.school),
              _buildInput("Facultad", _facultadCtrl, Icons.account_balance),
              _buildInput("Escuela", _escuelaCtrl, Icons.book),
              _buildInput(
                "Contraseña",
                _passCtrl,
                Icons.lock,
                isPassword: true,
              ),

              const SizedBox(height: 30),

              Consumer<AuthProvider>(
                builder: (context, provider, _) {
                  return ElevatedButton(
                    onPressed: provider.isLoading ? null : _handleRegister,
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("REGISTRARSE"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    bool isPassword = false,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primary),
        ),
        validator: (value) =>
            value!.isEmpty ? 'Este campo es obligatorio' : null,
      ),
    );
  }
}
