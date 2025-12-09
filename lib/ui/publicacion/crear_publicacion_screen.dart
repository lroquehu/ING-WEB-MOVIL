import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/categoria_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/publicaciones_service.dart';

class CrearPublicacionScreen extends StatefulWidget {
  const CrearPublicacionScreen({super.key});

  @override
  State<CrearPublicacionScreen> createState() => _CrearPublicacionScreenState();
}

class _CrearPublicacionScreenState extends State<CrearPublicacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = PublicacionesService();
  bool _isLoading = false;

  // Controladores
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();

  // Estado del Formulario
  List<Categoria> _categorias = [];
  String? _categoriaSeleccionada;
  String _tipoSeleccionado = 'Producto';
  List<XFile> _imagenesSeleccionadas = [];

  @override
  void initState() {
    super.initState();
    _cargarCategorias();

    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _correoCtrl.text = user.email;
    }
  }

  Future<void> _cargarCategorias() async {
    final cats = await _service.getCategorias();
    setState(() {
      _categorias = cats;
    });
  }

  void _mostrarOpcionesImagen() {
    if (_imagenesSeleccionadas.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Límite de 5 imágenes alcanzado')),
      );
      return;
    }

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
                "Agregar Fotos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),
                title: const Text('Galería'),
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
                title: const Text('Cámara'),
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
    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile> images = await picker.pickMultiImage(
        limit: 5 - _imagenesSeleccionadas.length,
      );
      if (images.isNotEmpty) {
        setState(() {
          _imagenesSeleccionadas.addAll(images);
        });
      }
    } catch (e) {
      print("Error galería: $e");
    }
  }

  Future<void> _tomarFoto() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo != null) {
        setState(() {
          _imagenesSeleccionadas.add(photo);
        });
      }
    } catch (e) {
      print("Error cámara: $e");
    }
  }

  void _guardarPublicacion() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaSeleccionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona una categoría')));
      return;
    }

    setState(() => _isLoading = true);

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    final data = {
      'id_usuario': user.id,
      'titulo': _tituloCtrl.text,
      'descripcion': _descCtrl.text,
      'categoria_id': _categoriaSeleccionada!,
      'tipo': _tipoSeleccionado,
      'precio': _precioCtrl.text,
      'telefono_contacto': _telefonoCtrl.text,
      'correo_contacto': _correoCtrl.text,
    };

    final resultado = await _service.crearPublicacion(
      data,
      _imagenesSeleccionadas,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (resultado['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Publicación creada con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['message'] ?? 'Error al crear'),
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
          'Crear Publicación',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea( // <--- AÑADIDO PARA EVITAR SUPERPOSICIÓN
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Información Básica"),

                      TextFormField(
                        controller: _tituloCtrl,
                        maxLength: 150,
                        decoration: const InputDecoration(
                          labelText: 'Título de la publicación *',
                          hintText: 'Ej: Laptop HP i5 8GB RAM',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (v) => (v == null || v.length < 5)
                            ? 'Mínimo 5 caracteres'
                            : null,
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 5,
                        maxLength: 2000,
                        decoration: const InputDecoration(
                          labelText: 'Descripción *',
                          hintText: 'Detalles, estado, características...',
                          alignLabelWithHint: true,
                        ),
                        validator: (v) => (v == null || v.length < 10)
                            ? 'Mínimo 10 caracteres'
                            : null,
                      ),
                      const SizedBox(height: 15),

                      // --- CAMBIO: De Row a Column ---
                      // Categoría
                      DropdownButtonFormField<String>(
                        value: _categoriaSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Categoría *',
                        ),
                        isExpanded: true,
                        items: _categorias.map((cat) {
                          return DropdownMenuItem(
                            value: cat.id,
                            child: Text(
                              cat.nombre,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _categoriaSeleccionada = val),
                      ),
                      const SizedBox(height: 15),

                      // Tipo
                      DropdownButtonFormField<String>(
                        value: _tipoSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Tipo *',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Producto',
                            child: Text('Producto'),
                          ),
                          DropdownMenuItem(
                            value: 'Servicio',
                            child: Text('Servicio'),
                          ),
                        ],
                        onChanged: (val) =>
                            setState(() => _tipoSeleccionado = val!),
                      ),
                      // --- FIN DEL CAMBIO ---

                      const SizedBox(height: 25),

                      _buildSectionTitle("Precio y Contacto"),

                      TextFormField(
                        controller: _precioCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Precio (S/) *',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        validator: (v) => v!.isEmpty ? 'Ingresa el precio' : null,
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        controller: _telefonoCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono / WhatsApp',
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _correoCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo de contacto',
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),

                      const SizedBox(height: 25),

                      _buildSectionTitle("Imágenes"),

                      InkWell(
                        onTap: _mostrarOpcionesImagen,
                        child: Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border.all(
                              color: Colors.grey[400]!,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_a_photo,
                                size: 30,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Toca para agregar fotos (Máx 5)",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (_imagenesSeleccionadas.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _imagenesSeleccionadas.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: FileImage(
                                          File(
                                            _imagenesSeleccionadas[index].path,
                                          ),
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 10,
                                    top: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _imagenesSeleccionadas.removeAt(index);
                                        });
                                      },
                                      child: const CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.red,
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 25),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(10),
                          border: const Border(
                            left: BorderSide(color: AppTheme.primary, width: 4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Consejos para una buena publicación:",
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text("📸 Usa fotos claras y con buena luz."),
                            Text("📝 Sé detallado en la descripción."),
                            Text("💰 Investiga precios similares."),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Botón de Guardar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _guardarPublicacion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'CREAR PUBLICACIÓN',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
