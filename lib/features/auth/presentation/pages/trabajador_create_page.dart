import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
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
  final VoidCallback? onCancel;
  final VoidCallback? onSaved;
  const CrearTrabajadorPage({super.key, this.onCancel, this.onSaved});

  @override
  ConsumerState<CrearTrabajadorPage> createState() =>
      _CrearTrabajadorPageState();
}

// Controlador de la página de creación de trabajadores
class _CrearTrabajadorPageState extends ConsumerState<CrearTrabajadorPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de los campos del formulario.
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidosCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  final TextEditingController _contrasenaCtrl = TextEditingController();
  final TextEditingController _niaCtrl = TextEditingController();
  final TextEditingController _dniCtrl = TextEditingController();

  // Rol por defecto: teleoperador.
  String _rol = 'teleoperador';

  // Grupo opcional (id). Solo para teleoperadores
  int? _grupoId;
  List<Grupo> _grupos = <Grupo>[];
  bool _cargandoGrupos = false;

  // Inicializa el servicio de trabajadores
  @override
  void initState() {
    super.initState();
    _fetchGrupos();
  }

  Future<void> _fetchGrupos() async {
    setState(() => _cargandoGrupos = true);
    try {
      final grupoService = ref.read(grupoServiceProvider);
      final grupos = await grupoService.findAll();
      setState(() {
        _grupos = grupos.where((g) => g.activo).toList();
      });
    } catch (e) {
      // Manejar error si es necesario
    } finally {
      setState(() => _cargandoGrupos = false);
    }
  }

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

  // Envía el payload al backend para crear el trabajador
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    // El grupo solo es obligatorio para teleoperadores
    if (_rol == 'teleoperador' && _grupoId == null) {
      general_snackbar_error(context, l10n.noGroupAssigned, 3);
      return;
    }

    // Validaciones específicas según el rol (coinciden con las reglas del backend)
    // Contraseña mínima

    // Obtenemos el valor del campo contraseña
    final contrasena = _contrasenaCtrl.text.trim();

    // Si la contraseña es menor a 6 caracteres, mostramos un snackbar de error
    if (contrasena.length < 6) {
      general_snackbar_error(context, l10n.passwordLengthError, 3);
      return;
    }

    // Si es teleoperador, validamos el NIA
    if (_rol == 'teleoperador') {
      final nia = _niaCtrl.text.trim();
      if (!RegExp(r'^[0-9]{8}$').hasMatch(nia)) {
        general_snackbar_error(context, l10n.invalidNIA, 3);
        return;
      }
    }

    // si es supervisor, validamos el DNI
    if (_rol == 'supervisor') {
      final dni = _dniCtrl.text.trim().toUpperCase();
      if (!RegExp(r'^[0-9]{8}[A-Z]$').hasMatch(dni)) {
        general_snackbar_error(context, l10n.invalidDNI, 3);
        return;
      }
    }
    // Creamos el payload con los datos del formulario
    final payload = <String, dynamic>{
      'nombre': _nombreCtrl.text.trim(),
      'apellidos': _apellidosCtrl.text.trim(),
      'correo': _correoCtrl.text.trim(),
      'contrasena': contrasena,
      'rol': _rol,
      'grupoId': _grupoId,
    };

    // Remove keys with null values to avoid sending nulls to backend
    payload.removeWhere((key, value) => value == null);

    // Añadimos campos según tipo
    // Si es teleoperador, añadimos el NIA
    if (_rol == 'teleoperador') {
      payload['nia'] = _niaCtrl.text.trim();
    }
    // Si es supervisor, añadimos el DNI
    if (_rol == 'supervisor') {
      payload['dni'] = _dniCtrl.text.trim().toUpperCase();
    }

    print('Creating trabajador payload: $payload'); // Solo debe contener grupoId, nunca grupo_id
    try {
      print('Creating trabajador payload JSON: ${jsonEncode(payload)}');
    } catch (_) {}

    // Enviamos el payload al backend
    //si todo va bien, mostramos un snackbar de exito y volvemos a la pagina de inicio
    try {
      final trabajadorService = ref.read(trabajadorServiceProvider);
      await trabajadorService.create(payload);
      general_snackbar(context, l10n.workerCreatedSuccessfully, 2);
      if (widget.onSaved != null) {
        widget.onSaved!();
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      general_snackbar_error(
        context,
        l10n.errorCreatingWorker(e.toString()),
        3,
      );
    }
  }

  // Genera el formulario
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    // -------- OBTENER NOMBRE DEL USUARIO DESDE RIVERPOD --------
    // Obtenemos el estado de autenticación del provider
    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final userRole = authState.rol;
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);

    // Genera el formulario
    final formBody = ResponsiveFormBody(
      title: l10n.newWorker,
      form: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            final gap = isWide ? 16.0 : 15.0;

            Widget label(String text) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(text, style: textTheme.bodyMedium),
                );

            Widget fieldGroup(String labelText, Widget field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [label(labelText), field],
                );

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
                  // Row 1: Nombre | Apellidos
                  fieldRow(
                    fieldGroup(l10n.name, general_textfield(l10n.name, false, controller: _nombreCtrl)),
                    fieldGroup(l10n.lastName, general_textfield(l10n.lastName, false, controller: _apellidosCtrl)),
                  ),
                  SizedBox(height: gap),

                  // Row 2: Correo (full width)
                  fieldGroup(l10n.email, general_textfield(l10n.email, false, controller: _correoCtrl)),
                  SizedBox(height: gap),

                  // Row 3: Teléfono | Contraseña
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

                  // Row 4: Rol (full width)
                  fieldGroup(
                    l10n.role,
                    DropdownButtonFormField<String>(
                      value: _rol,
                      items: [
                        DropdownMenuItem(value: 'teleoperador', child: Text(l10n.teleoperator)),
                        DropdownMenuItem(value: 'supervisor', child: Text(l10n.supervisor)),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _rol = v ?? 'teleoperador';
                          if (_rol != 'teleoperador') _grupoId = null;
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

                  // Row 5: Role-dependent fields
                  if (_rol == 'teleoperador')
                    fieldRow(
                      fieldGroup(
                        l10n.nia8digits,
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
                        _cargandoGrupos
                            ? const Center(child: CircularProgressIndicator())
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
                                  if (_rol == 'teleoperador' && v == null) {
                                    return l10n.noGroupAssigned;
                                  }
                                  return null;
                                },
                              ),
                      ),
                    )
                  else if (_rol == 'supervisor')
                    fieldGroup(
                      l10n.dniLabel,
                      TextFormField(
                        controller: _dniCtrl,
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

    if (widget.onCancel != null) {
      return formBody;
    }

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
