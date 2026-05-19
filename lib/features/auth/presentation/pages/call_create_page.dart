import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/core/widgets/responsive_form_body.dart';
import 'package:flutter/services.dart';

// Formulario para crear o editar una llamada.
// Puede mostrarse como pantalla completa o incrustado dentro de otra.
class CallFormPage extends StatefulWidget {
  // Llamada existente con la que rellenar el formulario (modo edición).
  // Si es null, el formulario empieza vacío (modo creación).
  final Llamadas? llamadaInicial;

  // Función que el padre proporciona para buscar usuarios por nombre/DNI.
  final Future<List<UsuarioBusqueda>> Function(String query) buscarUsuarios;

  // Función que el padre proporciona para guardar la llamada en el servidor.
  final Future<void> Function(CallFormData data) onSubmit;

  // Función para cancelar y volver atrás.
  final VoidCallback? onCancel;

  // Indica si el formulario está en modo edición (true) o creación (false).
  final bool isEdit;

  // Lista de teleoperadores disponibles para que el supervisor elija quién hizo la llamada.
  // Solo se pasa cuando el usuario conectado es supervisor.
  final List<TeleoperadorBusqueda>? teleoperadores;

  const CallFormPage({
    super.key,
    this.llamadaInicial,
    required this.buscarUsuarios,
    required this.onSubmit,
    this.onCancel,
    this.isEdit = false,
    this.teleoperadores,
  });

  @override
  State<CallFormPage> createState() => _CallFormPageState();
}

// Clase de datos que representa un usuario encontrado en la búsqueda.
// Solo necesitamos su ID (DNI) y nombre completo para el formulario.
class UsuarioBusqueda {
  final String id;
  final String nombreCompleto;
  UsuarioBusqueda({required this.id, required this.nombreCompleto});
}

// Clase de datos que representa un teleoperador disponible para asignar a la llamada.
class TeleoperadorBusqueda {
  final int id;
  final String nombreCompleto;
  TeleoperadorBusqueda({required this.id, required this.nombreCompleto});
}

// Clase que agrupa todos los datos del formulario que se envían al servidor.
class CallFormData {
  // ID del usuario que recibió la llamada.
  final String usuarioId;
  // Resumen o descripción breve de la llamada.
  final String resumen;
  // Duración de la llamada en minutos.
  final String duracion;
  // Estado de la llamada (completada, pendiente, no contestada).
  final String estado;
  // Observaciones adicionales sobre la llamada.
  final String observaciones;
  // Fecha en que se realizó la llamada.
  final DateTime fecha;
  // Hora en que se realizó la llamada (formato HH:MM).
  final String hora;
  // ID del teleoperador que hizo la llamada (opcional, solo para supervisores).
  final int? teleoperadorId;

  CallFormData({
    required this.usuarioId,
    required this.resumen,
    required this.duracion,
    required this.estado,
    required this.observaciones,
    required this.fecha,
    required this.hora,
    this.teleoperadorId,
  });
}

// Estado y lógica interna del formulario de llamadas.
class _CallFormPageState extends State<CallFormPage> {
  // Controlador del campo de búsqueda de usuarios.
  final TextEditingController _usuarioBusquedaController = TextEditingController();

  // Clave para validar el formulario antes de enviarlo.
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para los campos del formulario.
  late TextEditingController _resumenController;
  late TextEditingController _duracionController;
  late TextEditingController _observacionesController;
  late TextEditingController _horaController;

  // Fecha seleccionada mediante el selector de fechas.
  DateTime? _fecha;

  // Estado seleccionado en el desplegable (completada, pendiente, no contestada).
  String? _estado;

  // Usuario seleccionado en el buscador de usuarios.
  UsuarioBusqueda? _usuarioSeleccionado;

  // Resultados de la última búsqueda de usuarios.
  List<UsuarioBusqueda> _usuariosBusqueda = [];

  // Indica si la búsqueda de usuarios está en curso.
  bool _buscandoUsuario = false;

  // Teleoperador seleccionado en el desplegable (solo supervisores).
  TeleoperadorBusqueda? _teleoperadorSeleccionado;

  // Lista de estados posibles para una llamada.
  final List<String> _estados = [
    CallStatus.completada,
    CallStatus.pendiente,
    CallStatus.noContesto,
  ];

  // Inicializa los campos del formulario con los datos de la llamada existente (si los hay).
  @override
  void initState() {
    super.initState();
    final llamada = widget.llamadaInicial;
    _resumenController = TextEditingController(text: llamada?.resumen ?? '');
    _duracionController = TextEditingController(text: llamada?.duracion ?? '');
    _observacionesController = TextEditingController(text: llamada?.observaciones ?? '');
    _horaController = TextEditingController(text: llamada?.hora ?? '');
    _fecha = llamada?.fecha;
    _estado = llamada?.estado;

    // Si la llamada tiene usuario asignado, lo pre-seleccionamos en el buscador.
    if (llamada != null && llamada.usuarioId != null) {
      _usuarioSeleccionado = UsuarioBusqueda(
        id: llamada.usuarioId.toString(),
        nombreCompleto: '${llamada.usuarioNombre ?? ''}${llamada.usuarioApellidos != null ? ' ${llamada.usuarioApellidos}' : ''}',
      );
    }

    // Si la llamada tiene teleoperador asignado y tenemos la lista de teleoperadores,
    // pre-seleccionamos el teleoperador correspondiente.
    if (llamada != null && llamada.teleoperadorId != null && widget.teleoperadores != null) {
      _teleoperadorSeleccionado = widget.teleoperadores!.where((t) => t.id == llamada.teleoperadorId).firstOrNull;
    }
  }

  // Libera los controladores al cerrar el formulario.
  @override
  void dispose() {
    _resumenController.dispose();
    _duracionController.dispose();
    _observacionesController.dispose();
    _horaController.dispose();
    _usuarioBusquedaController.dispose();
    super.dispose();
  }

  // Busca usuarios en el servidor que coincidan con el texto escrito.
  // Se activa cuando el usuario escribe en el campo de búsqueda.
  void _buscarUsuario(String query) async {
    setState(() => _buscandoUsuario = true);
    final resultados = await widget.buscarUsuarios(query);
    setState(() {
      _usuariosBusqueda = resultados;
      _buscandoUsuario = false;
    });
  }

  // Valida el formulario y llama a la función del padre para guardar la llamada.
  void _onSubmit() async {
    // Si algún campo obligatorio falla, no continuamos.
    if (_formKey.currentState?.validate() != true) return;
    final l10n = AppLocalizations.of(context)!;

    // El usuario es obligatorio; si no se seleccionó ninguno, lo indicamos.
    if (_usuarioSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectUser)),
      );
      return;
    }

    // La fecha también es obligatoria.
    if (_fecha == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectDate)),
      );
      return;
    }

    // Construimos el objeto con todos los datos del formulario.
    final data = CallFormData(
      usuarioId: _usuarioSeleccionado!.id,
      resumen: _resumenController.text.trim(),
      duracion: _duracionController.text.trim(),
      estado: _estado!,
      observaciones: _observacionesController.text.trim(),
      fecha: _fecha!,
      hora: _horaController.text.trim(),
      // El teleoperador es opcional; solo se incluye si se seleccionó uno.
      teleoperadorId: _teleoperadorSeleccionado?.id,
    );

    try {
      // Llamamos a la función del padre para guardar en el servidor.
      await widget.onSubmit(data);
    } catch (e) {
      if (!mounted) return;
      general_snackbar_error(context, '${AppLocalizations.of(context)!.error}: ${extractErrorMessage(e)}', 5);
    }
  }

  // Convierte el código interno del estado a un texto legible para el usuario.
  String _estadoLegible(String estado, AppLocalizations l10n) {
    switch (estado) {
      case CallStatus.completada:
        return l10n.completed;
      case CallStatus.pendiente:
        return l10n.pending;
      case CallStatus.noContesto:
        return l10n.noAnswer;
      default:
        // Si el estado no es uno de los conocidos, lo mostramos tal cual.
        return estado;
    }
  }

  // Construye el formulario visual con todos los campos.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    final formBody = ResponsiveFormBody(
      // El título cambia según si estamos creando o editando.
      title: widget.isEdit ? l10n.editCall : l10n.createCall,
      form: Form(
        key: _formKey,
        child: LayoutBuilder(
            builder: (context, constraints) {
              // En pantallas anchas usamos dos columnas.
              final isWide = constraints.maxWidth >= 900;
              final gap = isWide ? 16.0 : 15.0;

              // Etiqueta de texto encima de cada campo.
              Widget label(String text) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(text, style: textTheme.bodyMedium),
                  );

              // En pantalla ancha: dos campos en fila. En estrecha: uno encima del otro.
              Widget fieldRow(Widget left, Widget right) {
                if (!isWide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      left,
                      SizedBox(height: gap),
                      right,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: left),
                    SizedBox(width: gap),
                    Expanded(child: right),
                  ],
                );
              }

              // Bloque de búsqueda de usuario: campo de texto + lista de resultados
              // + indicador del usuario seleccionado.
              final userSearch = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo de texto para buscar usuarios.
                  TextFormField(
                    controller: _usuarioBusquedaController,
                    decoration: InputDecoration(
                      hintText: l10n.searchUser,
                      prefixIcon: const Icon(Icons.search),
                      // Icono de carga mientras busca, o botón de limpiar si hay texto.
                      suffixIcon: _buscandoUsuario
                          ? const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : (_usuarioBusquedaController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    // Limpiamos la búsqueda y el usuario seleccionado.
                                    setState(() {
                                      _usuarioBusquedaController.clear();
                                      _usuariosBusqueda = [];
                                      _usuarioSeleccionado = null;
                                    });
                                  },
                                )
                              : null),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                    ),
                    // Buscamos cuando el texto tiene más de 2 caracteres para evitar
                    // búsquedas con resultados demasiado amplios.
                    onChanged: (value) {
                      if (value.length > 2) {
                        _buscarUsuario(value);
                      } else {
                        setState(() => _usuariosBusqueda = []);
                      }
                    },
                    // El campo falla la validación si no se ha seleccionado ningún usuario.
                    validator: (_) => _usuarioSeleccionado == null ? l10n.selectUser : null,
                  ),
                  const SizedBox(height: 6),
                  // Lista de resultados de búsqueda (solo visible si hay texto y no hay selección).
                  if (_usuarioBusquedaController.text.isNotEmpty && _usuarioSeleccionado == null)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: _buscandoUsuario
                          // Mientras busca, mostramos un indicador circular.
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _usuariosBusqueda.isEmpty
                              // Si no hay resultados, lo indicamos.
                              ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info_outline, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(l10n.noResults, style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                )
                              // Lista de resultados donde el usuario puede seleccionar uno.
                              : ListView.separated(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  itemCount: _usuariosBusqueda.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1),
                                  itemBuilder: (context, i) {
                                    final u = _usuariosBusqueda[i];
                                    return ListTile(
                                      title: Text(u.nombreCompleto),
                                      // Al pulsar, seleccionamos este usuario y cerramos la lista.
                                      onTap: () {
                                        setState(() {
                                          _usuarioSeleccionado = u;
                                          _usuariosBusqueda = [];
                                          // Actualizamos el campo de texto con el nombre seleccionado.
                                          _usuarioBusquedaController.text = u.nombreCompleto;
                                        });
                                      },
                                      selected: _usuarioSeleccionado?.id == u.id,
                                      leading: const Icon(Icons.person_outline),
                                    );
                                  },
                                ),
                    ),
                  // Si hay un usuario seleccionado, mostramos su nombre con un check verde.
                  if (_usuarioSeleccionado != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 18),
                          const SizedBox(width: 6),
                          Flexible(child: Text('${l10n.selectedUser}: ${_usuarioSeleccionado!.nombreCompleto}')),
                        ],
                      ),
                    ),
                ],
              );

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isWide)
                      // En escritorio: buscador de usuario y selector de fecha en la misma fila.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                label(l10n.user),
                                userSearch,
                              ],
                            ),
                          ),
                          SizedBox(width: gap),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                label(l10n.date),
                                // Botón que abre el selector de fecha.
                                SizedBox(
                                  height: 56,
                                  child: FilledButton(
                                    onPressed: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: _fecha ?? DateTime.now(),
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2035),
                                      );
                                      if (picked != null) setState(() => _fecha = picked);
                                    },
                                    child: Text(
                                      _fecha != null
                                          // Si hay fecha, la mostramos en formato dd/mm/aaaa.
                                          ? '${_fecha!.day.toString().padLeft(2, '0')}/${_fecha!.month.toString().padLeft(2, '0')}/${_fecha!.year}'
                                          : l10n.selectDate,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      // En móvil: buscador de usuario y fecha en columna.
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          label(l10n.user),
                          userSearch,
                          SizedBox(height: gap),
                          label(l10n.date),
                          SizedBox(
                            height: 56,
                            child: FilledButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _fecha ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2035),
                                );
                                if (picked != null) setState(() => _fecha = picked);
                              },
                              child: Text(
                                _fecha != null
                                    ? '${_fecha!.day.toString().padLeft(2, '0')}/${_fecha!.month.toString().padLeft(2, '0')}/${_fecha!.year}'
                                    : l10n.selectDate,
                              ),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: gap),

                    if (isWide)
                      // En escritorio: estado, hora y duración en la misma fila.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                label(l10n.callStatus),
                                // Desplegable para seleccionar el estado de la llamada.
                                DropdownButtonFormField<String>(
                                  value: _estado,
                                  hint: Text(l10n.callStatus),
                                  items: _estados
                                      .map((e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(_estadoLegible(e, l10n)),
                                          ))
                                      .toList(),
                                  onChanged: (v) => setState(() => _estado = v),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                  ),
                                  validator: (v) => v == null ? l10n.requiredField : null,
                                ),
                                // Texto de error adicional si no se seleccionó estado.
                                if (_estado == null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                                    child: Text(
                                      l10n.callStatus,
                                      style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(width: gap),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                label(l10n.time),
                                // Campo de hora con formato HH:MM validado.
                                general_textfield_NoICON(
                                  l10n.time,
                                  controller: _horaController,
                                  borderRadius: 12.0,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return l10n.requiredField;
                                    final regex = RegExp(r'^([01]?\d|2[0-3]):[0-5]\d$');
                                    if (!regex.hasMatch(v)) return l10n.formatHHMM;
                                    return null;
                                  },
                                  // Solo permite números y el carácter ":".
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                                    LengthLimitingTextInputFormatter(5),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: gap),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                label(l10n.duration),
                                // Campo de duración en minutos (solo números, máximo 3 dígitos).
                                general_textfield_NoICON(
                                  l10n.duration,
                                  controller: _duracionController,
                                  borderRadius: 12.0,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return l10n.requiredField;
                                    if (!RegExp(r'^\d{1,3}$').hasMatch(v)) return l10n.onlyNumbers;
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      // En móvil: estado, hora y duración en columna.
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          label(l10n.callStatus),
                          DropdownButtonFormField<String>(
                            value: _estado,
                            hint: Text(l10n.callStatus),
                            items: _estados
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(_estadoLegible(e, l10n)),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _estado = v),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                            ),
                            validator: (v) => v == null ? l10n.requiredField : null,
                          ),
                          if (_estado == null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                              child: Text(
                                l10n.callStatus,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                              ),
                            ),
                          SizedBox(height: gap),
                          label(l10n.time),
                          general_textfield_NoICON(
                            l10n.time,
                            controller: _horaController,
                            borderRadius: 12.0,
                            validator: (v) {
                              if (v == null || v.isEmpty) return l10n.requiredField;
                              final regex = RegExp(r'^([01]?\d|2[0-3]):[0-5]\d$');
                              if (!regex.hasMatch(v)) return l10n.formatHHMM;
                              return null;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                              LengthLimitingTextInputFormatter(5),
                            ],
                          ),
                          SizedBox(height: gap),
                          label(l10n.duration),
                          general_textfield_NoICON(
                            l10n.duration,
                            controller: _duracionController,
                            borderRadius: 12.0,
                            validator: (v) {
                              if (v == null || v.isEmpty) return l10n.requiredField;
                              if (!RegExp(r'^\d{1,3}$').hasMatch(v)) return l10n.onlyNumbers;
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                          ),
                        ],
                      ),
                    SizedBox(height: gap),

                    // Campos de resumen y observaciones (siempre en columna).
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        label(l10n.summary),
                        // Campo de resumen obligatorio.
                        general_textfield_NoICON(
                          l10n.summary,
                          controller: _resumenController,
                          borderRadius: 12.0,
                          validator: (v) => v == null || v.isEmpty ? l10n.requiredField : null,
                        ),
                        SizedBox(height: gap),
                        label(l10n.comments),
                        // Campo de observaciones opcional, acepta varias líneas.
                        general_textfield_NoICON(
                          l10n.comments,
                          controller: _observacionesController,
                          borderRadius: 12.0,
                          maxLines: 3,
                        ),
                      ],
                    ),

                    // Selector de teleoperador (solo visible para supervisores).
                    // Permite asignar la llamada a un teleoperador específico.
                    if (widget.teleoperadores != null && widget.teleoperadores!.isNotEmpty) ...[
                      SizedBox(height: gap),
                      label(l10n.teleoperator),
                      DropdownButtonFormField<TeleoperadorBusqueda?>(
                        value: _teleoperadorSeleccionado,
                        // La opción "ninguno" permite dejar la llamada sin teleoperador asignado.
                        hint: Text(l10n.none),
                        items: [
                          DropdownMenuItem<TeleoperadorBusqueda?>(
                            value: null,
                            child: Text(l10n.none),
                          ),
                          ...widget.teleoperadores!.map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.nombreCompleto),
                          )),
                        ],
                        onChanged: (v) => setState(() => _teleoperadorSeleccionado = v),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    // Botones de acción: cancelar y guardar/crear.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          child: TextButton(
                            onPressed: () {
                              if (widget.onCancel != null) {
                                widget.onCancel!();
                              } else {
                                Navigator.pop(context);
                              }
                            },
                            child: Text(
                              l10n.cancel,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 140,
                          // El texto cambia según si estamos editando o creando.
                          child: FilledButton(
                            onPressed: _onSubmit,
                            child: Text(widget.isEdit ? l10n.save : l10n.create),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
    );

    // Si tiene callback onCancel, está siendo usado incrustado sin Scaffold.
    if (widget.onCancel != null) {
      return formBody;
    }

    // Si no, lo mostramos como pantalla completa con Scaffold.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? l10n.editCall : l10n.createCall),
      ),
      body: formBody,
    );
  }
}
