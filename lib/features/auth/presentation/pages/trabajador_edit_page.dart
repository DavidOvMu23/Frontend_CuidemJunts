import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/core/widgets/loading_skeleton.dart';
import 'package:frontend_cuidemjunts/core/widgets/responsive_form_body.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/trabajador.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/trabajador_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/grupo_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/grupo.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

// Página para editar los datos de un trabajador existente.
// Recibe el trabajador a editar y callbacks para cancelar o confirmar.
class EditarTrabajadorPage extends ConsumerStatefulWidget {
  // El trabajador cuyos datos se van a modificar.
  final Trabajador trabajador;
  // Función que se llama si el usuario cancela la edición.
  final VoidCallback? onCancel;
  // Función que se llama cuando los cambios se han guardado correctamente.
  final VoidCallback? onSaved;
  const EditarTrabajadorPage({super.key, required this.trabajador, this.onCancel, this.onSaved});

  @override
  ConsumerState<EditarTrabajadorPage> createState() => _EditarTrabajadorPageState();
}

// Estado y lógica del formulario de edición de trabajadores.
class _EditarTrabajadorPageState extends ConsumerState<EditarTrabajadorPage> {
  // Clave para validar el formulario antes de enviarlo.
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para cada campo editable del formulario.
  late TextEditingController _nombreCtrl;
  late TextEditingController _apellidosCtrl;
  late TextEditingController _correoCtrl;
  late TextEditingController _telefonoCtrl;
  // La contraseña se deja vacía; solo se cambia si el usuario escribe algo.
  late TextEditingController _contrasenaCtrl;
  // NIA y DNI son de solo lectura al editar (no se pueden cambiar).
  late TextEditingController _niaCtrl;
  late TextEditingController _dniCtrl;

  // Rol del trabajador (no se puede cambiar al editar).
  String _rol = AppRoles.teleoperador;

  // ID del grupo asignado (solo para teleoperadores, sí se puede cambiar).
  int? _grupoId;

  // Estado activo/inactivo de la cuenta del trabajador.
  bool _activo = true;

  // Lista de grupos activos disponibles para el desplegable.
  List<Grupo> _grupos = <Grupo>[];

  // Lista completa de grupos (activos e inactivos) para comprobar el estado
  // del grupo actual del trabajador.
  List<Grupo> _todosGrupos = <Grupo>[];

  // Indica si los grupos están cargándose desde el servidor.
  bool _cargandoGrupos = false;

  // Devuelve true si el grupo asignado al trabajador está inactivo.
  bool get _grupoActualInactivo =>
      _grupoId != null &&
      _todosGrupos.any((g) => g.id == _grupoId && !g.activo);

  // Inicializa los campos del formulario con los datos actuales del trabajador.
  @override
  void initState() {
    super.initState();
    // Usamos una variable corta para acceder más cómodamente al trabajador.
    final t = widget.trabajador;
    _nombreCtrl = TextEditingController(text: t.nombre);
    _apellidosCtrl = TextEditingController(text: t.apellidos);
    _correoCtrl = TextEditingController(text: t.correo);
    _telefonoCtrl = TextEditingController(text: t.telefono ?? '');
    // La contraseña empieza vacía; si se deja vacía al guardar, no se cambia.
    _contrasenaCtrl = TextEditingController();
    _niaCtrl = TextEditingController(text: t.nia ?? '');
    _dniCtrl = TextEditingController(text: t.dni ?? '');
    _rol = t.rol;
    _grupoId = t.grupoId;
    _activo = t.activo;
    // Cargamos los grupos disponibles para el selector.
    _fetchGrupos();
  }

  // Obtiene todos los grupos del servidor. Los activos van al desplegable;
  // todos se guardan en _todosGrupos para comprobar el estado del grupo actual.
  Future<void> _fetchGrupos() async {
    setState(() => _cargandoGrupos = true);
    try {
      final grupoService = ref.read(grupoServiceProvider);
      final grupos = await grupoService.findAll();
      setState(() {
        _todosGrupos = grupos;
        _grupos = grupos.where((g) => g.activo).toList();
      });
    } catch (_) {} finally {
      setState(() => _cargandoGrupos = false);
    }
  }

  // Libera los controladores al cerrar la página para no desperdiciar memoria.
  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidosCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _contrasenaCtrl.dispose();
    _niaCtrl.dispose();
    _dniCtrl.dispose();
    super.dispose();
  }

  // Valida el formulario y envía los cambios al servidor.
  Future<void> _submit() async {
    // Si algún campo obligatorio no es válido, no continuamos.
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    // Los teleoperadores deben tener siempre un grupo asignado.
    if (_rol == AppRoles.teleoperador && _grupoId == null) {
      general_snackbar_error(context, l10n.noGroupAssigned, 3);
      return;
    }

    // No se puede reactivar un teleoperador si su grupo está inactivo.
    if (_activo && _grupoActualInactivo) {
      general_snackbar_error(context, l10n.cannotActivateWorkerInactiveGroup, 5);
      return;
    }

    // Construimos el objeto con los datos actualizados.
    final payload = <String, dynamic>{
      'nombre': _nombreCtrl.text.trim(),
      'apellidos': _apellidosCtrl.text.trim(),
      'correo': _correoCtrl.text.trim(),
      'rol': _rol,
      'grupoId': _grupoId,
      'activo': _activo,
    };

    // La contraseña es opcional: solo se envía si el usuario escribió una nueva.
    if (_contrasenaCtrl.text.trim().isNotEmpty) {
      payload['contrasena'] = _contrasenaCtrl.text.trim();
    }

    // El teléfono también es opcional.
    if (_telefonoCtrl.text.trim().isNotEmpty) {
      payload['telefono'] = _telefonoCtrl.text.trim();
    }

    // El NIA solo aplica a los teleoperadores.
    if (_rol == AppRoles.teleoperador) {
      payload['nia'] = _niaCtrl.text.trim();
    }

    // El DNI solo aplica a los supervisores.
    if (_rol == AppRoles.supervisor) {
      payload['dni'] = _dniCtrl.text.trim().toUpperCase();
    }

    // Eliminamos campos nulos para no enviarlos al servidor.
    payload.removeWhere((key, value) => value == null);

    try {
      final trabajadorService = ref.read(trabajadorServiceProvider);
      // Actualizamos el trabajador en el servidor usando su ID.
      await trabajadorService.update(widget.trabajador.id, payload);
      if (!mounted) return;
      general_snackbar(context, l10n.workerCreatedSuccessfully, 2);
      if (widget.onSaved != null) {
        widget.onSaved!();
      } else {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      general_snackbar_error(context, '${l10n.error}: ${extractErrorMessage(e)}', 5);
    }
  }

  // Construye la interfaz visual del formulario de edición.
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    // Color de fondo para los campos de solo lectura (NIA, DNI, rol).
    final readOnlyFillColor = colorScheme.onSurface.withValues(alpha: 0.08);
    final l10n = AppLocalizations.of(context)!;

    final formBody = ResponsiveFormBody(
      title: l10n.edit,
      form: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // En pantallas anchas usamos dos columnas.
            final isWide = constraints.maxWidth >= AppBreakpoints.formWide;
            final gap = isWide ? 16.0 : 15.0;

            // Etiqueta de texto encima de cada campo.
            Widget label(String text) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(text, style: textTheme.bodyMedium),
                );

            // Agrupa la etiqueta con su campo.
            Widget fieldGroup(String labelText, Widget field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [label(labelText), field],
                );

            // En pantalla ancha: dos campos en fila. En estrecha: uno encima del otro.
            Widget fieldRow(Widget left, Widget right) {
              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [left, SizedBox(height: gap), right],
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

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila 1: Nombre y apellidos.
                  fieldRow(
                    fieldGroup(l10n.name, general_textfield(l10n.name, false, controller: _nombreCtrl)),
                    fieldGroup(l10n.lastName, general_textfield(l10n.lastName, false, controller: _apellidosCtrl)),
                  ),
                  SizedBox(height: gap),

                  // Fila 2: Correo electrónico (ocupa todo el ancho).
                  fieldGroup(l10n.email, general_textfield(l10n.email, false, controller: _correoCtrl)),
                  SizedBox(height: gap),

                  // Fila 3: Teléfono y contraseña (vacía = no se cambia).
                  fieldRow(
                    fieldGroup(l10n.telephone, general_textfield(l10n.telephone, false, controller: _telefonoCtrl)),
                    fieldGroup(
                      l10n.password,
                      TextFormField(
                        controller: _contrasenaCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: l10n.password,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: gap),

                  // Fila 4: Rol (deshabilitado al editar, no se puede cambiar el rol).
                  fieldGroup(
                    l10n.role,
                    DropdownButtonFormField<String>(
                      initialValue: _rol,
                      items: [
                        DropdownMenuItem(value: AppRoles.teleoperador, child: Text(l10n.teleoperator)),
                        DropdownMenuItem(value: AppRoles.supervisor, child: Text(l10n.supervisor)),
                      ],
                      // onChanged: null significa que el campo es de solo lectura.
                      onChanged: null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                      ),
                    ),
                  ),
                  SizedBox(height: gap),

                  // Fila 5: Campos específicos según el rol.
                  // Para teleoperadores: NIA (solo lectura) y grupo (editable).
                  if (_rol == AppRoles.teleoperador)
                    fieldRow(
                      fieldGroup(
                        l10n.nia8digits,
                        // El NIA no se puede cambiar una vez creado.
                        TextFormField(
                          controller: _niaCtrl,
                          readOnly: true,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: l10n.nia,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            // Color más apagado para indicar que es solo lectura.
                            fillColor: readOnlyFillColor,
                          ),
                        ),
                      ),
                      fieldGroup(
                        l10n.group_label,
                        // Mientras cargan los grupos, mostramos una animación.
                        _cargandoGrupos
                            ? const AppSkeletonBox(height: 56)
                            : DropdownButtonFormField<int>(
                                initialValue: _grupoId,
                                items: _grupos
                                    .map<DropdownMenuItem<int>>((Grupo g) => DropdownMenuItem<int>(
                                          value: g.id,
                                          child: Text(g.nombre),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() => _grupoId = v),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                ),
                                validator: (v) {
                                  if (_rol == AppRoles.teleoperador && v == null) {
                                    return l10n.noGroupAssigned;
                                  }
                                  return null;
                                },
                              ),
                      ),
                    )
                  // Para supervisores: DNI (solo lectura, no se puede cambiar).
                  else if (_rol == AppRoles.supervisor)
                    fieldGroup(
                      l10n.dniLabel,
                      TextFormField(
                        controller: _dniCtrl,
                        readOnly: true,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: l10n.dni,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: readOnlyFillColor,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Interruptor para activar o desactivar la cuenta del trabajador.
                  // Al desactivar, el trabajador no puede acceder a la aplicación.
                  Builder(builder: (context) {
                    final colorScheme = Theme.of(context).colorScheme;
                    return Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile(
                        title: Text(l10n.accountStatus, style: textTheme.bodyMedium),
                        // Muestra "Activo" o "Inactivo" según el estado del interruptor.
                        subtitle: Text(
                          _activo ? l10n.active : l10n.inactive,
                          style: TextStyle(
                            color: _activo ? Colors.green.shade700 : colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        value: _activo,
                        onChanged: (v) {
                          // Bloquear reactivación si el grupo del trabajador está inactivo.
                          if (v && _grupoActualInactivo) {
                            general_snackbar_error(context, l10n.cannotActivateWorkerInactiveGroup, 5);
                            return;
                          }
                          setState(() => _activo = v);
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),
                  // Botones de acción: cancelar y guardar cambios.
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
                        // Botón principal que ejecuta la validación y el envío.
                        child: FilledButton(
                          onPressed: _submit,
                          child: Text(l10n.save),
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

    // Si estamos incrustados, devolvemos solo el formulario sin Scaffold.
    if (widget.onCancel != null) {
      return formBody;
    }
    // Si somos pantalla completa, envolvemos con Scaffold.
    return Scaffold(
      appBar: AppBar(title: Text(l10n.edit)),
      body: formBody,
    );
  }
}
