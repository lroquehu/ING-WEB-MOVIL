import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniemprende_movil/ui/auth/verification_screen.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _dniCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _facultadCtrl = TextEditingController();
  final _escuelaCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscureText = true;

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

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
        // NAVEGAR A LA PANTALLA DE VERIFICACIÓN
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationScreen(email: _correoCtrl.text),
          ),
          (route) => route.isFirst, // Eliminar el historial de navegación
        );
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
      body: SafeArea(
        child: SingleChildScrollView(
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
        obscureText: isPassword ? _obscureText : false,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primary),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
        ),
        validator: (value) =>
            value!.isEmpty ? 'Este campo es obligatorio' : null,
      ),
    );
  }
}
