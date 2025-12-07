import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Importante para ver las fotos viejas
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/publicacion_model.dart';
import '../../models/categoria_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/publicaciones_service.dart';

class EditarPublicacionScreen extends StatefulWidget {
  final Publicacion producto; // El producto a editar

  const EditarPublicacionScreen({super.key, required this.producto});

  @override
  State<EditarPublicacionScreen> createState() =>
      _EditarPublicacionScreenState();
}

class _EditarPublicacionScreenState extends State<EditarPublicacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = PublicacionesService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;

  // Controladores
  late TextEditingController _tituloCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _correoCtrl;

  // Estado
  List<Categoria> _categorias = [];
  String? _categoriaSeleccionada;
  String? _tipoSeleccionado;

  // Gestión de Imágenes
  List<ImagenGaleria> _imagenesExistentes = []; // Las que vienen del servidor
  List<String> _idsEliminar = []; // IDs marcados para borrar
  List<XFile> _imagenesNuevas = []; // Nuevas fotos de cámara/galería

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  void _cargarDatosIniciales() async {
    // 1. Cargar Categorías
    final cats = await _service.getCategorias();

    // 2. Cargar detalle fresco del producto (por si acaso faltan datos)
    final detalle = await _service.getDetalle(widget.producto.id);
    final prod = detalle ?? widget.producto;

    setState(() {
      _categorias = cats;

      // Llenar formulario
      _tituloCtrl = TextEditingController(text: prod.titulo);
      _descCtrl = TextEditingController(text: prod.descripcion);
      _precioCtrl = TextEditingController(text: prod.precio.toString());
      _telefonoCtrl = TextEditingController(text: prod.telefono);
      _correoCtrl = TextEditingController(text: prod.correo);

      // Selectores
      // Buscamos el ID de la categoría basado en el nombre si no lo tenemos, o usamos el del objeto
      // Simplificación: Asumimos que el usuario re-selecciona si falla el match,
      // o idealmente el modelo debería traer id_categoria.
      // Por ahora, trataremos de buscar por nombre en la lista de categorias:
      try {
        final catMatch = cats.firstWhere((c) => c.nombre == prod.categoria);
        _categoriaSeleccionada = catMatch.id;
      } catch (_) {}

      _tipoSeleccionado =
          "Producto"; // Ojo: Tu modelo actual no guarda 'tipo' en el detalle, asumo Producto por defecto

      // Imágenes
      if (prod.galeria != null) {
        _imagenesExistentes = List.from(prod.galeria!);
      }
      _isLoading = false;
    });
  }

  // --- LÓGICA DE IMÁGENES ---

  void _mostrarOpcionesImagen() {
    int total =
        (_imagenesExistentes.length - _idsEliminar.length) +
        _imagenesNuevas.length;
    if (total >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Límite de 5 imágenes alcanzado')),
      );
      return;
    }

    // ... (Mismo código del BottomSheet de Crear) ...
    // Puedes copiar el showModalBottomSheet de CrearPublicacionScreen aquí
    // Para ahorrar espacio en la respuesta, asumo que usas la misma lógica de _tomarFoto y _seleccionarGaleria
    _seleccionarGaleria(); // Simplificado para el ejemplo
  }

  Future<void> _seleccionarGaleria() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) setState(() => _imagenesNuevas.addAll(images));
  }

  void _marcarParaEliminar(int indexExistente) {
    setState(() {
      // Guardamos el ID de la imagen que vamos a borrar
      _idsEliminar.add(_imagenesExistentes[indexExistente].id);
      // La quitamos de la vista local
      _imagenesExistentes.removeAt(indexExistente);
    });
  }

  // ---------------------------

  void _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = context.read<AuthProvider>().currentUser;

    final data = {
      'id_usuario': user!.id,
      'id_publicacion': widget.producto.id, // ¡Importante!
      'titulo': _tituloCtrl.text,
      'descripcion': _descCtrl.text,
      'categoria_id': _categoriaSeleccionada ?? '1', // Fallback
      'tipo': _tipoSeleccionado ?? 'Producto',
      'precio': _precioCtrl.text,
      'telefono_contacto': _telefonoCtrl.text,
      'correo_contacto': _correoCtrl.text,
    };

    final resultado = await _service.editarPublicacion(
      data: data,
      nuevasImagenes: _imagenesNuevas,
      idsEliminar: _idsEliminar,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (resultado['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Actualizado!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Volver y recargar
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['message'] ?? 'Error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Editar Publicación",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _tituloCtrl,
                      decoration: const InputDecoration(labelText: 'Título'),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _precioCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Precio (S/)',
                      ),
                    ),

                    const SizedBox(height: 25),
                    const Text(
                      "Imágenes",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // LISTA DE IMÁGENES (Viejas + Nuevas)
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Botón Agregar
                          InkWell(
                            onTap: _mostrarOpcionesImagen,
                            child: Container(
                              width: 80,
                              height: 100,
                              margin: const EdgeInsets.only(right: 10),
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.add_a_photo,
                                color: Colors.grey,
                              ),
                            ),
                          ),

                          // 1. Imágenes Existentes (Vienen de URL)
                          ..._imagenesExistentes.map(
                            (img) => Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  margin: const EdgeInsets.only(right: 10),
                                  child: CachedNetworkImage(
                                    imageUrl: img.url,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 10,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () => _marcarParaEliminar(
                                      _imagenesExistentes.indexOf(img),
                                    ),
                                    child: const CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.red,
                                      child: Icon(
                                        Icons.close,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 2. Imágenes Nuevas (Vienen de File)
                          ..._imagenesNuevas.map(
                            (file) => Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  margin: const EdgeInsets.only(right: 10),
                                  child: Image.file(
                                    File(file.path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 10,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () => setState(
                                      () => _imagenesNuevas.remove(file),
                                    ),
                                    child: const CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.green,
                                      child: Icon(
                                        Icons.close,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _guardarCambios,
                        child: const Text("GUARDAR CAMBIOS"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
