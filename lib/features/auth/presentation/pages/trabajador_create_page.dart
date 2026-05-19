import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/core/widgets/loading_skeleton.dart';
import 'package:frontend_cuidemjunts/core/widgets/responsive_form_body.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/emergency_contacts_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/calls_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/notifications_page.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/trabajador_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/grupo.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/grupo_provider.dart';

// Página para crear un nuevo trabajador (teleoperador, supervisor, etc.)
class CrearTrabajadorPage extends ConsumerStatefulWidget {
  // Función que se llama si el usuario cancela la creación.
  final VoidCallback? onCancel;
  // Función que se llama cuando el trabajador se ha guardado correctamente.
  final VoidCallback? onSaved;
  const CrearTrabajadorPage({super.key, this.onCancel, this.onSaved});

  @override
  ConsumerState<CrearTrabajadorPage> createState() =>
      _CrearTrabajadorPageState();
}

// Controlador de la página de creación de trabajadores.
// Gestiona los campos del formulario y envía los datos al servidor.
class _CrearTrabajadorPageState extends ConsumerState<CrearTrabajadorPage> {
  // Clave única del formulario, necesaria para poder validarlo antes de enviarlo.
  final _formKey = GlobalKey<FormState>();

  // Controladores que guardan el texto que el usuario escribe en cada campo.
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidosCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  final TextEditingController _contrasenaCtrl = TextEditingController();
  final TextEditingController _niaCtrl = TextEditingController();
  final TextEditingController _dniCtrl = TextEditingController();

  // Rol seleccionado en el desplegable. Por defecto es teleoperador.
  String _rol = AppRoles.teleoperador;

  // ID del grupo seleccionado. Solo aplica para teleoperadores.
  int? _grupoId;

  // Lista de grupos activos disponibles para asignar al teleoperador.
  List<Grupo> _grupos = <Grupo>[];

  // Indica si se están cargando los grupos desde el servidor.
  bool _cargandoGrupos = false;

  // Al iniciar la página, cargamos los grupos disponibles.
  @override
  void initState() {
    super.initState();
    _fetchGrupos();
  }

  // Obtiene todos los grupos activos del servidor para mostrarlos en el desplegable.
  Future<void> _fetchGrupos() async {
    setState(() => _cargandoGrupos = true);
    try {
      final grupoService = ref.read(grupoServiceProvider);
      final grupos = await grupoService.findAll();
      setState(() {
        // Solo mostramos los grupos que están activos.
        _grupos = grupos.where((g) => g.activo).toList();
      });
    } catch (e) {
      // Si falla la carga, simplemente dejamos la lista vacía.
    } finally {
      setState(() => _cargandoGrupos = false);
    }
  }

  // Libera la memoria de los controladores de texto cuando la página se cierra.
  // Es importante hacerlo para evitar fugas de memoria.
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

  // Valida el formulario y envía los datos al servidor para crear el trabajador.
  Future<void> _submit() async {
    // Si algún campo obligatorio falla la validación, no continuamos.
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    // Los teleoperadores deben tener un grupo asignado obligatoriamente.
    if (_rol == AppRoles.teleoperador && _grupoId == null) {
      general_snackbar_error(context, l10n.noGroupAssigned, 3);
      return;
    }

    // La contraseña debe tener al menos 6 caracteres (regla del servidor).
    final contrasena = _contrasenaCtrl.text.trim();
    if (contrasena.length < 6) {
      general_snackbar_error(context, l10n.passwordLengthError, 3);
      return;
    }

    // Si es teleoperador, el NIA debe ser exactamente 8 dígitos numéricos.
    if (_rol == AppRoles.teleoperador) {
      final nia = _niaCtrl.text.trim();
      if (!RegExp(r'^[0-9]{8}$').hasMatch(nia)) {
        general_snackbar_error(context, l10n.invalidNIA, 3);
        return;
      }
    }

    // Si es supervisor, el DNI debe tener el formato español: 8 dígitos + letra.
    if (_rol == AppRoles.supervisor) {
      final dni = _dniCtrl.text.trim().toUpperCase();
      if (!RegExp(r'^[0-9]{8}[A-Z]$').hasMatch(dni)) {
        general_snackbar_error(context, l10n.invalidDNI, 3);
        return;
      }
    }

    // Construimos el objeto con los datos que se enviarán al servidor.
    final payload = <String, dynamic>{
      'nombre': _nombreCtrl.text.trim(),
      'apellidos': _apellidosCtrl.text.trim(),
      'correo': _correoCtrl.text.trim(),
      'contrasena': contrasena,
      'rol': _rol,
      'grupoId': _grupoId,
    };

    // Eliminamos los campos vacíos (null) para no enviarlos al servidor.
    payload.removeWhere((key, value) => value == null);

    // El teléfono es opcional; solo lo añadimos si el usuario lo rellenó.
    if (_telefonoCtrl.text.trim().isNotEmpty) {
      payload['telefono'] = _telefonoCtrl.text.trim();
    }

    // El NIA solo se añade si el trabajador es teleoperador.
    if (_rol == AppRoles.teleoperador) {
      payload['nia'] = _niaCtrl.text.trim();
    }

    // El DNI solo se añade si el trabajador es supervisor.
    if (_rol == AppRoles.supervisor) {
      payload['dni'] = _dniCtrl.text.trim().toUpperCase();
    }

    // Enviamos los datos al servidor. Si todo va bien, avisamos al usuario y cerramos.
    try {
      final trabajadorService = ref.read(trabajadorServiceProvider);
      await trabajadorService.create(payload);
      general_snackbar(context, l10n.workerCreatedSuccessfully, 2);
      if (widget.onSaved != null) {
        // Si estamos incrustados, notificamos al padre para que actualice la lista.
        widget.onSaved!();
      } else {
        // Si somos una pantalla completa, simplemente volvemos atrás.
        Navigator.pop(context);
      }
    } catch (e) {
      general_snackbar_error(context, '${l10n.error}: ${extractErrorMessage(e)}', 5);
    }
  }

  // Construye el formulario visual con todos los campos necesarios.
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    // Leemos los datos del usuario que ha iniciado sesión para el menú lateral.
    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final userRole = authState.rol;

    // Número de notificaciones pendientes para la barra superior.
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);

    // Cuerpo del formulario con diseño responsivo (se adapta al tamaño de pantalla).
    final formBody = ResponsiveFormBody(
      title: l10n.newWorker,
      form: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Si la pantalla es suficientemente ancha, ponemos campos en dos columnas.
            final isWide = constraints.maxWidth >= AppBreakpoints.formWide;
            final gap = isWide ? 16.0 : 15.0;

            // Función auxiliar: crea el texto de la etiqueta encima de cada campo.
            Widget label(String text) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(text, style: textTheme.bodyMedium),
                );

            // Función auxiliar: agrupa la etiqueta con su campo de formulario.
            Widget fieldGroup(String labelText, Widget field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [label(labelText), field],
                );

            // Función auxiliar: en pantalla ancha pone dos campos lado a lado;
            // en pantalla estrecha los apila uno encima del otro.
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
                  // Fila 1: Nombre y apellidos uno al lado del otro.
                  fieldRow(
                    fieldGroup(l10n.name, general_textfield(l10n.name, false, controller: _nombreCtrl)),
                    fieldGroup(l10n.lastName, general_textfield(l10n.lastName, false, controller: _apellidosCtrl)),
                  ),
                  SizedBox(height: gap),

                  // Fila 2: Correo electrónico (ocupa todo el ancho).
                  fieldGroup(l10n.email, general_textfield(l10n.email, false, controller: _correoCtrl)),
                  SizedBox(height: gap),

                  // Fila 3: Teléfono y contraseña uno al lado del otro.
                  fieldRow(
                    fieldGroup(l10n.telephone, general_textfield(l10n.telephone, false, controller: _telefonoCtrl)),
                    fieldGroup(
                      l10n.password,
                      // Campo de contraseña con texto oculto (asteriscos).
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
                        validator: (v) {
                          if (v == null || v.trim().length < 6) {
                            return l10n.passwordLengthError;
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: gap),

                  // Fila 4: Desplegable para elegir el rol del trabajador.
                  fieldGroup(
                    l10n.role,
                    DropdownButtonFormField<String>(
                      value: _rol,
                      items: [
                        DropdownMenuItem(value: AppRoles.teleoperador, child: Text(l10n.teleoperator)),
                        DropdownMenuItem(value: AppRoles.supervisor, child: Text(l10n.supervisor)),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _rol = v ?? AppRoles.teleoperador;
                          // Si cambia a supervisor, limpiamos el grupo seleccionado.
                          if (_rol != AppRoles.teleoperador) _grupoId = null;
                        });
                      },
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

                  // Fila 5: Campos que cambian según el rol seleccionado.
                  // Si es teleoperador: muestra NIA y grupo.
                  if (_rol == AppRoles.teleoperador)
                    fieldRow(
                      fieldGroup(
                        l10n.nia8digits,
                        // Campo numérico para el NIA (8 dígitos exactamente).
                        TextFormField(
                          controller: _niaCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: l10n.nia,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                          ),
                          validator: (v) {
                            final s = v?.trim() ?? '';
                            if (!RegExp(r'^[0-9]{8}$').hasMatch(s)) {
                              return l10n.invalidNIA;
                            }
                            return null;
                          },
                        ),
                      ),
                      fieldGroup(
                        l10n.group_label,
                        // Mientras cargamos los grupos, mostramos un esqueleto animado.
                        _cargandoGrupos
                            ? const AppSkeletonBox(height: 56)
                            // Si no hay grupos disponibles, mostramos una advertencia.
                            : _grupos.isEmpty
                                ? Builder(builder: (context) {
                                    final cs = Theme.of(context).colorScheme;
                                    return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: cs.errorContainer.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.warning_amber_rounded, size: 18, color: cs.error),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              l10n.noGroupsAvailableCreateFirst,
                                              style: TextStyle(color: cs.onErrorContainer, fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  })
                                // Desplegable con los grupos activos disponibles.
                                : DropdownButtonFormField<int>(
                                    value: _grupoId,
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
                                      // El grupo es obligatorio para los teleoperadores.
                                      if (_rol == AppRoles.teleoperador && v == null) {
                                        return l10n.noGroupAssigned;
                                      }
                                      return null;
                                    },
                                  ),
                      ),
                    )
                  // Si es supervisor: muestra el campo DNI (solo lectura al editar).
                  else if (_rol == AppRoles.supervisor)
                    fieldGroup(
                      l10n.dniLabel,
                      TextFormField(
                        controller: _dniCtrl,
                        // Convierte automáticamente el texto a mayúsculas.
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: l10n.dni,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                        ),
                        validator: (v) {
                          final s = (v ?? '').trim().toUpperCase();
                          if (!RegExp(r'^[0-9]{8}[A-Z]$').hasMatch(s)) {
                            return l10n.invalidDNI;
                          }
                          return null;
                        },
                      ),
                    ),

                  const SizedBox(height: 24),
                  // Botones de acción: cancelar (en rojo) y crear.
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
                          child: Text(l10n.createWorkerBtn),
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

    // Si estamos incrustados (tenemos callback), devolvemos solo el formulario.
    if (widget.onCancel != null) {
      return formBody;
    }

    // Si somos una pantalla completa, envolvemos el formulario con Scaffold.
    return Scaffold(
      appBar: appMainAppBar(
        numeroNotificaciones: notificacionesSinLeerAsync.when(
          data: (count) => count,
          loading: () => 0,
          error: (_, __) => 0,
        ),
        onNotifications: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsPage()),
          );
        },
        context: context,
      ),
      drawer: appDrawer(
        userName: userName,
        userRole: userRole,
        context: context,
        selected: DrawerItem.telemarketers,
        onTapHome: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeSupervisorPage()),
        ),
        onTapCalls: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LlamadasPage()),
        ),
        onTapTelemarketers: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WorkersPage()),
        ),
        onTapUsers: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UsersPage()),
        ),
        onTapEmergencyContacts: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EmergencyContactsPage()),
        ),
        onTapNotifications: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsPage()),
        ),
        onTapPreferences: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PreferencesPage()),
        ),
        onLogoutConfirmed: () async {
          await ref.read(authProvider.notifier).logout();
          if (!context.mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        },
      ),
      body: formBody,
    );
  }
}
