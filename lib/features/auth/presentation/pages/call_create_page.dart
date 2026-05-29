import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/grupo.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/core/widgets/loading_skeleton.dart';
import 'package:frontend_cuidemjunts/core/widgets/responsive_form_body.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/usuario_provider.dart';
import 'package:flutter/services.dart';

// Formulario para crear o editar una llamada.
// Puede mostrarse como pantalla completa o incrustado dentro de otra.
class CallFormPage extends ConsumerStatefulWidget {
  // Llamada existente con la que rellenar el formulario (modo edición).
  // Si es null, el formulario empieza vacío (modo creación).
  final Llamadas? llamadaInicial;

  // Función que el padre proporciona para guardar la llamada en el servidor.
  final Future<void> Function(CallFormData data) onSubmit;

  // Función para cancelar y volver atrás.
  final VoidCallback? onCancel;

  // Indica si el formulario está en modo edición (true) o creación (false).
  final bool isEdit;

  // Lista de grupos activos para que el supervisor elija a qué grupo asignar la llamada.
  // Solo se pasa cuando el usuario conectado es supervisor.
  final List<Grupo>? grupos;

  const CallFormPage({
    super.key,
    this.llamadaInicial,
    required this.onSubmit,
    this.onCancel,
    this.isEdit = false,
    this.grupos,
  });

  @override
  ConsumerState<CallFormPage> createState() => _CallFormPageState();
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
  // Grupo al que pertenece el teleoperador; se usa como grupo de la llamada cuando
  // un supervisor crea una llamada asignándola a este teleoperador.
  final int? grupoId;
  TeleoperadorBusqueda({required this.id, required this.nombreCompleto, this.grupoId});
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
  // ID del grupo seleccionado en el formulario (opcional, solo para supervisores).
  final int? grupoIdFormulario;

  CallFormData({
    required this.usuarioId,
    required this.resumen,
    required this.duracion,
    required this.estado,
    required this.observaciones,
    required this.fecha,
    required this.hora,
    this.grupoIdFormulario,
  });
}

// Estado y lógica interna del formulario de llamadas.
class _CallFormPageState extends ConsumerState<CallFormPage> {
  // Clave para validar el formulario antes de enviarlo.
  final _formKey = GlobalKey<FormState>();

  // Clave del botón de seleccionar fecha; la usamos para hacer scroll a ese
  // campo cuando el usuario intenta crear la llamada y falta la fecha.
  final GlobalKey _fechaFieldKey = GlobalKey();

  // Controlador de scroll del formulario para poder llevar al usuario al
  // primer campo con error si la validación falla.
  final ScrollController _scrollController = ScrollController();

  // Indica si el usuario ya ha intentado enviar el formulario al menos una
  // vez. Mientras es false, no destacamos visualmente los campos vacíos
  // para no alarmar antes de que se haya intentado guardar.
  bool _submitAttempted = false;

  // Controladores de texto para los campos del formulario.
  late TextEditingController _resumenController;
  late TextEditingController _duracionController;
  late TextEditingController _observacionesController;
  late TextEditingController _horaController;

  // Fecha seleccionada mediante el selector de fechas.
  DateTime? _fecha;

  // Estado seleccionado en el desplegable (completada, pendiente, no contestada).
  String? _estado;

  // Usuario seleccionado para esta llamada (solo uno).
  UsuarioBusqueda? _usuarioSeleccionado;

  // Texto introducido en el buscador de usuarios; filtra la lista en memoria.
  String _busquedaUsuario = '';

  // Grupo seleccionado en el desplegable (solo supervisores).
  Grupo? _grupoSeleccionado;

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

    // En edición pre-seleccionamos el grupo al que pertenecía la llamada.
    if (llamada != null && widget.grupos != null) {
      _grupoSeleccionado = widget.grupos!.where((g) => g.id == llamada.grupoId).firstOrNull;
    }
  }

  // Libera los controladores al cerrar el formulario.
  @override
  void dispose() {
    _resumenController.dispose();
    _duracionController.dispose();
    _observacionesController.dispose();
    _horaController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Abre el selector de hora del sistema (TimePicker). Si el campo ya tiene un
  // valor válido HH:MM, lo usamos como hora inicial; si no, partimos de la hora
  // actual. Forzamos formato de 24 horas para coincidir con el HH:MM que
  // guardamos en el servidor.
  Future<void> _pickHora() async {
    TimeOfDay initial = TimeOfDay.now();
    final current = _horaController.text.trim();
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(current);
    if (match != null) {
      final h = int.tryParse(match.group(1)!);
      final m = int.tryParse(match.group(2)!);
      if (h != null && m != null && h < 24 && m < 60) {
        initial = TimeOfDay(hour: h, minute: m);
      }
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (picked != null) {
      final hh = picked.hour.toString().padLeft(2, '0');
      final mm = picked.minute.toString().padLeft(2, '0');
      setState(() {
        _horaController.text = '$hh:$mm';
      });
    }
  }

  // Campo "Hora" no editable directamente: al pulsarlo se abre el TimePicker.
  // El texto resultante (HH:MM) se valida igual que antes para el envío.
  Widget _buildHoraField(AppLocalizations l10n) {
    return TextFormField(
      controller: _horaController,
      readOnly: true,
      onTap: _pickHora,
      decoration: InputDecoration(
        hintText: l10n.time,
        suffixIcon: const Icon(Icons.access_time),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return l10n.requiredField;
        final regex = RegExp(r'^([01]?\d|2[0-3]):[0-5]\d$');
        if (!regex.hasMatch(v)) return l10n.formatHHMM;
        return null;
      },
    );
  }

  // Marca que el usuario ha pulsado "Crear" al menos una vez para activar la
  // indicación visual de campos obligatorios (p. ej. borde rojo en Fecha).
  void _markSubmitAttempted() {
    if (!_submitAttempted) {
      setState(() => _submitAttempted = true);
    }
  }

  // Desplaza el scroll hasta el botón de Fecha para que el usuario vea el
  // campo que falta. Se llama tras un error de validación cuando _fecha es
  // null, que es el motivo más frecuente de bloqueo del formulario.
  void _scrollToFecha() {
    final ctx = _fechaFieldKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        alignment: 0.1,
      );
    } else if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // Muestra un aviso rojo bien visible al usuario cuando hay campos sin
  // rellenar. Reemplaza la SnackBar gris por una de error con icono.
  void _showFormErrorSnack(String mensaje) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Valida el formulario y llama a la función del padre para guardar la llamada.
  void _onSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    _markSubmitAttempted();

    // Si algún campo obligatorio falla, avisamos con SnackBar y desplazamos
    // la vista al primer campo problemático (típicamente la Fecha).
    if (_formKey.currentState?.validate() != true) {
      _showFormErrorSnack(l10n.requiredField);
      if (_fecha == null) _scrollToFecha();
      return;
    }

    // El usuario es obligatorio; si no se seleccionó ninguno, lo indicamos.
    if (_usuarioSeleccionado == null) {
      _showFormErrorSnack(l10n.selectUser);
      return;
    }

    // La fecha también es obligatoria.
    if (_fecha == null) {
      _showFormErrorSnack(l10n.selectDate);
      _scrollToFecha();
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
      // El grupo seleccionado por el supervisor (null para teleoperadores).
      grupoIdFormulario: _grupoSeleccionado?.id,
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

              // Bloque de selección de usuario: misma UX que el formulario de
              // contactos de emergencia — buscador + lista filtrada con
              // casillas, pero con selección única (solo un usuario por llamada).
              final usuariosAsync = ref.watch(usuariosProvider);
              final userSearch = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo de búsqueda por nombre, apellidos o DNI.
                  TextField(
                    decoration: InputDecoration(
                      hintText: l10n.searchUser,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                    ),
                    onChanged: (v) => setState(() => _busquedaUsuario = v),
                  ),
                  const SizedBox(height: 8),
                  // Lista de usuarios con casillas — solo se puede tener uno marcado.
                  Container(
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: usuariosAsync.when(
                      loading: () => const AppSkeletonList(count: 4, itemHeight: 72),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '${l10n.error}: $e',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                      data: (usuarios) {
                        // Filtramos por texto buscado (nombre, apellidos, DNI o teléfono).
                        final query = _busquedaUsuario.trim().toLowerCase();
                        final filtered = usuarios.where((u) {
                          if (query.isEmpty) return true;
                          return u.nombre.toLowerCase().contains(query) ||
                              u.apellidos.toLowerCase().contains(query) ||
                              u.dni.toLowerCase().contains(query) ||
                              u.telefono.toLowerCase().contains(query);
                        }).toList();

                        if (filtered.isEmpty) {
                          return Center(child: Text(l10n.noResultsFound));
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final u = filtered[index];
                            final selected = _usuarioSeleccionado?.id == u.dni;
                            return CheckboxListTile(
                              value: selected,
                              title: Text('${u.nombre} ${u.apellidos} (${u.dni})'),
                              controlAffinity: ListTileControlAffinity.leading,
                              // Selección única: marcar uno reemplaza al anterior;
                              // desmarcar el actual deja la llamada sin usuario.
                              onChanged: (checked) => setState(() {
                                if (checked == true) {
                                  _usuarioSeleccionado = UsuarioBusqueda(
                                    id: u.dni,
                                    nombreCompleto: '${u.nombre} ${u.apellidos}',
                                  );
                                } else {
                                  _usuarioSeleccionado = null;
                                }
                              }),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // Indicador del usuario actualmente seleccionado.
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

              // Selector visual de fecha; comparte UI entre desktop y móvil.
              // Se renderiza como un campo de entrada (mismo aspecto que Hora /
              // Duración) y se marca en rojo si el usuario intentó crear sin
              // elegir fecha.
              Widget buildFechaSelector() {
                final faltaFecha = _submitAttempted && _fecha == null;
                final colorScheme = Theme.of(context).colorScheme;
                Future<void> abrirPicker() async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _fecha ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) setState(() => _fecha = picked);
                }

                final fechaTexto = _fecha != null
                    ? '${_fecha!.day.toString().padLeft(2, '0')}/${_fecha!.month.toString().padLeft(2, '0')}/${_fecha!.year}'
                    : null;

                return Column(
                  key: _fechaFieldKey,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TextFormField de solo lectura para que combine visualmente
                    // con los demás campos de la fila (Estado, Hora, Duración).
                    TextFormField(
                      readOnly: true,
                      onTap: abrirPicker,
                      controller: TextEditingController(text: fechaTexto ?? ''),
                      decoration: InputDecoration(
                        hintText: l10n.selectDate,
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        // Borde rojo cuando falta la fecha y ya se intentó enviar.
                        enabledBorder: faltaFecha
                            ? OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: colorScheme.error,
                                  width: 1.5,
                                ),
                              )
                            : null,
                      ),
                    ),
                    if (faltaFecha)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Text(
                          l10n.selectDate,
                          style: TextStyle(
                            color: colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                );
              }

              return SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Buscador de usuario en su propia fila para que la lista
                    // disponga de toda la anchura. La fecha se ha movido a la
                    // siguiente fila, junto a Hora.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        label(l10n.user),
                        userSearch,
                      ],
                    ),
                    SizedBox(height: gap),

                    if (isWide)
                      // En escritorio: estado, fecha, hora y duración en la misma fila.
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
                                label(l10n.date),
                                buildFechaSelector(),
                              ],
                            ),
                          ),
                          SizedBox(width: gap),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                label(l10n.time),
                                // Campo de hora con selector visual (TimePicker).
                                _buildHoraField(l10n),
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
                                    // Si la llamada está pendiente (por hacer), la
                                    // duración no es obligatoria, pero si se rellena
                                    // debe seguir siendo un número válido.
                                    final esPendiente = _estado == CallStatus.pendiente;
                                    if (v == null || v.isEmpty) {
                                      return esPendiente ? null : l10n.requiredField;
                                    }
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
                          // Fecha justo encima de Hora para que vayan juntas.
                          label(l10n.date),
                          buildFechaSelector(),
                          SizedBox(height: gap),
                          label(l10n.time),
                          // Campo de hora con selector visual (TimePicker).
                          _buildHoraField(l10n),
                          SizedBox(height: gap),
                          label(l10n.duration),
                          general_textfield_NoICON(
                            l10n.duration,
                            controller: _duracionController,
                            borderRadius: 12.0,
                            validator: (v) {
                              // Si la llamada está pendiente (por hacer), la
                              // duración no es obligatoria, pero si se rellena
                              // debe seguir siendo un número válido.
                              final esPendiente = _estado == CallStatus.pendiente;
                              if (v == null || v.isEmpty) {
                                return esPendiente ? null : l10n.requiredField;
                              }
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
                        // El resumen es obligatorio salvo que la llamada esté
                        // pendiente (por hacer): en ese caso aún no hay nada que
                        // resumir, así que se permite dejarlo vacío.
                        general_textfield_NoICON(
                          l10n.summary,
                          controller: _resumenController,
                          borderRadius: 12.0,
                          validator: (v) {
                            if (_estado == CallStatus.pendiente) return null;
                            return v == null || v.isEmpty ? l10n.requiredField : null;
                          },
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

                    // Selector de grupo (solo visible para supervisores).
                    // Obligatorio al crear: la llamada queda vinculada al grupo seleccionado.
                    // En edición permite cambiar el grupo o dejarlo sin cambios.
                    if (widget.grupos != null && widget.grupos!.isNotEmpty) ...[
                      SizedBox(height: gap),
                      label(l10n.group_label),
                      DropdownButtonFormField<Grupo?>(
                        value: _grupoSeleccionado,
                        hint: Text(widget.isEdit ? l10n.none : l10n.selectGroup),
                        items: [
                          if (widget.isEdit)
                            DropdownMenuItem<Grupo?>(
                              value: null,
                              child: Text(l10n.none),
                            ),
                          ...widget.grupos!.map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g.nombre),
                          )),
                        ],
                        onChanged: (v) => setState(() => _grupoSeleccionado = v),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                        ),
                        validator: widget.isEdit ? null : (v) => v == null ? l10n.requiredField : null,
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
