import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../models/user_model.dart';
import '../../services/perfil_service.dart';

class EditarPerfilScreen extends StatefulWidget {
  final User usuarioActual;

  const EditarPerfilScreen({super.key, required this.usuarioActual});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = PerfilService();
  final ImagePicker _picker = ImagePicker(); // Instancia del picker
  bool _isLoading = false;

  // Controladores
  late TextEditingController _nombresCtrl;
  late TextEditingController _apellidosCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _facultadCtrl;
  late TextEditingController _escuelaCtrl;

  XFile? _nuevaFoto; // Para guardar la foto si la cambia

  @override
  void initState() {
    super.initState();
    // Pre-llenar el formulario
    _nombresCtrl = TextEditingController(text: widget.usuarioActual.nombres);
    _apellidosCtrl = TextEditingController(
      text: widget.usuarioActual.apellidos,
    );
    _telefonoCtrl = TextEditingController(text: widget.usuarioActual.telefono);
    _facultadCtrl = TextEditingController(text: widget.usuarioActual.facultad);
    _escuelaCtrl = TextEditingController(text: widget.usuarioActual.escuela);
  }

  // --- NUEVA LÓGICA DE FOTO (CÁMARA VS GALERÍA) ---

  void _mostrarOpcionesFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Cambiar Foto de Perfil",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),
                title: const Text('Elegir de la Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarGaleria();
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.pink,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
                title: const Text('Tomar Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _tomarFoto();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _seleccionarGaleria() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _nuevaFoto = image);
      }
    } catch (e) {
      print("Error galería: $e");
    }
  }

  Future<void> _tomarFoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice:
            CameraDevice.front, // Preferir cámara frontal para selfies
        imageQuality: 80,
      );
      if (photo != null) {
        setState(() => _nuevaFoto = photo);
      }
    } catch (e) {
      print("Error cámara: $e");
    }
  }

  // ------------------------------------------------

  void _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Preparar datos
    final data = {
      'id_usuario': widget.usuarioActual.id,
      'nombres': _nombresCtrl.text,
      'apellidos': _apellidosCtrl.text,
      'telefono': _telefonoCtrl.text,
      'facultad': _facultadCtrl.text,
      'escuela': _escuelaCtrl.text,
    };

    final resultado = await _service.actualizarPerfil(data, _nuevaFoto);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (resultado['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      // Volver atrás y avisar que hubo cambios (true)
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['message'] ?? 'Error al actualizar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Perfil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- FOTO DE PERFIL ---
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primary,
                          width: 2,
                        ), // Borde rojo bonito
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _nuevaFoto != null
                            ? FileImage(
                                File(_nuevaFoto!.path),
                              ) // Muestra la nueva si la eligió
                            : (widget.usuarioActual.fotoPerfil != null
                                      ? NetworkImage(
                                          widget.usuarioActual.fotoPerfil!,
                                        )
                                      : null)
                                  as ImageProvider?,
                        child:
                            (_nuevaFoto == null &&
                                widget.usuarioActual.fotoPerfil == null)
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap:
                            _mostrarOpcionesFoto, // <--- AQUÍ LLAMAMOS AL NUEVO MENÚ
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary, // Botón rojo
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- CAMPOS DE TEXTO ---
              TextFormField(
                controller: _nombresCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombres',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _apellidosCtrl,
                decoration: const InputDecoration(
                  labelText: 'Apellidos',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _telefonoCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _facultadCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Facultad',
                        prefixIcon: Icon(Icons.account_balance),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _escuelaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Escuela',
                        prefixIcon: Icon(Icons.school),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // --- BOTÓN GUARDAR ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardarCambios,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "GUARDAR CAMBIOS",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
