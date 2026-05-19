import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/core/widgets/responsive_form_body.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/calls_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/emergency_contacts_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/notifications_page.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/usuario_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/contacto_emergencia_service.dart';

// Página que sirve tanto para crear un nuevo usuario (persona atendida) como para editarlo.
// Si se pasa el parámetro 'usuario', entra en modo edición; si no, en modo creación.
class CrearUserPage extends ConsumerStatefulWidget {
  // El usuario a editar. Si es null, estamos creando uno nuevo.
  final Usuario? usuario;
  // Función que se llama si el usuario cancela la operación.
  final VoidCallback? onCancel;
  // Función que se llama cuando el usuario se ha guardado correctamente.
  final VoidCallback? onSaved;
  const CrearUserPage({super.key, this.usuario, this.onCancel, this.onSaved});

  @override
  ConsumerState<CrearUserPage> createState() => _CrearUserPageState();
}

// Estado y lógica del formulario de creación/edición de usuarios.
class _CrearUserPageState extends ConsumerState<CrearUserPage> {
  // Clave para validar el formulario antes de enviarlo.
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para cada campo del formulario.
  final TextEditingController _dniCtrl = TextEditingController();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidosCtrl = TextEditingController();
  final TextEditingController _informacionCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  final TextEditingController _datosMedicosCtrl = TextEditingController();
  final TextEditingController _medicacionCtrl = TextEditingController();
  final TextEditingController _direccionCtrl = TextEditingController();

  // Fecha de nacimiento seleccionada mediante el selector de fechas.
  DateTime? _fechaNacimiento;

  // Estado de la cuenta del usuario (activo/inactivo).
  String _estadoCuenta = 'activo';

  // Nivel de dependencia del usuario (ninguna, leve, moderada, severa).
  String _nivelDependencia = 'ninguna';

  // Devuelve true si estamos editando un usuario existente.
  bool get _isEditing => widget.usuario != null;

  // Acceso directo a las traducciones para evitar repetir código.
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  // Inicializa los campos del formulario.
  // Si estamos editando, los rellenamos con los datos actuales del usuario.
  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      // Cargamos los datos del usuario existente en los campos del formulario.
      final u = widget.usuario!;
      _dniCtrl.text = u.dni;
      _nombreCtrl.text = u.nombre;
      _apellidosCtrl.text = u.apellidos;
      _informacionCtrl.text = u.informacion;
      _telefonoCtrl.text = u.telefono;
      _datosMedicosCtrl.text = u.datosMedicosDolencias ?? '';
      _medicacionCtrl.text = u.medicacion ?? '';
      _direccionCtrl.text = u.direccion;
      _fechaNacimiento = u.f_nac;
      _estadoCuenta = u.estadoCuenta;

      // El nivel de dependencia puede venir en varios formatos del servidor.
      // Lo normalizamos a los valores que usa la aplicación.
      final nivel = u.nivelDependencia.trim().toUpperCase();
      if (nivel == 'G1' || nivel == 'LEVE') {
        _nivelDependencia = 'leve';
      } else if (nivel == 'G2' || nivel == 'MODERADA' || nivel == 'MODERADO') {
        _nivelDependencia = 'moderada';
      } else if (nivel == 'G3' || nivel == 'SEVERA' || nivel == 'SEVERO') {
        _nivelDependencia = 'severa';
      } else {
        _nivelDependencia = 'ninguna';
      }
    }
  }

  // Libera los controladores de texto al cerrar la página.
  @override
  void dispose() {
    _dniCtrl.dispose();
    _nombreCtrl.dispose();
    _apellidosCtrl.dispose();
    _informacionCtrl.dispose();
    _telefonoCtrl.dispose();
    _datosMedicosCtrl.dispose();
    _medicacionCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  // Abre el selector de fecha para que el usuario elija la fecha de nacimiento.
  Future<void> _pickFechaNacimiento() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      // Por defecto abre en el año hace 70 años (perfil típico de usuario).
      initialDate: _fechaNacimiento ?? DateTime(now.year - 70),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    // Si el usuario seleccionó una fecha, la guardamos.
    if (picked != null) setState(() => _fechaNacimiento = picked);
  }

  // Valida el formulario y envía los datos al servidor para crear o actualizar el usuario.
  Future<void> _submit() async {
    // Si algún campo obligatorio falla la validación, no continuamos.
    if (!_formKey.currentState!.validate()) return;

    // La fecha de nacimiento es obligatoria pero no está dentro del Form validator.
    if (_fechaNacimiento == null) {
      general_snackbar_error(context, l10n.selectBirthDate, 2);
      return;
    }

    // Construimos el objeto con todos los datos del usuario.
    final payload = {
      'dni': _dniCtrl.text.trim().toUpperCase(),
      'nombre': _nombreCtrl.text.trim(),
      'apellidos': _apellidosCtrl.text.trim(),
      // Los campos opcionales se envían como null si están vacíos.
      'informacion': _informacionCtrl.text.trim().isEmpty
          ? null
          : _informacionCtrl.text.trim(),
      'estado_cuenta': _estadoCuenta,
      // La fecha se envía en formato ISO para que el servidor la entienda.
      'f_nac': DateFormat('yyyy-MM-dd').format(_fechaNacimiento!),
      'nivel_dependencia': _nivelDependencia,
      'datos_medicos_dolencias': _datosMedicosCtrl.text.trim().isEmpty
          ? null
          : _datosMedicosCtrl.text.trim(),
      'medicacion': _medicacionCtrl.text.trim().isEmpty
          ? null
          : _medicacionCtrl.text.trim(),
      'telefono': _telefonoCtrl.text.trim().isEmpty
          ? null
          : _telefonoCtrl.text.trim(),
      'direccion': _direccionCtrl.text.trim().isEmpty
          ? null
          : _direccionCtrl.text.trim(),
    };

    try {
      final usuarioService = ref.read(usuarioServiceProvider);

      if (_isEditing) {
        // Modo edición: actualizamos el usuario existente por su DNI.
        await usuarioService.update(widget.usuario!.dni, payload);
        if (!mounted) return;
        general_snackbar(context, l10n.userUpdatedSuccess, 2);
        if (widget.onSaved != null) {
          widget.onSaved!();
        } else {
          Navigator.pop(context, true);
        }
      } else {
        // Modo creación: creamos el usuario nuevo.
        await usuarioService.create(payload);

        // Al crear un usuario nuevo, el servidor genera automáticamente su contacto
        // de emergencia. Hacemos una petición para asegurarnos de que queda sincronizado.
        try {
          final contactoService = ref.read(contactoEmergenciaServiceProvider);
          await contactoService.getByUsuario(payload['dni'] as String);
        } catch (_) {
          // Si falla la sincronización, no bloqueamos al usuario; el backend ya lo hizo.
        }
        if (!mounted) return;
        general_snackbar(context, l10n.userCreatedSuccess, 2);
        if (widget.onSaved != null) {
          widget.onSaved!();
        } else {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (!mounted) return;
      general_snackbar_error(context, '${l10n.error}: ${extractErrorMessage(e)}', 5);
    }
  }

  // Construye el formulario visual con todos los campos del usuario.
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Leemos los datos del usuario conectado para el menú lateral.
    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final userRole = authState.rol;
    // Número de notificaciones para la barra superior.
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);

    final formBody = ResponsiveFormBody(
      // El título y subtítulo cambian según si estamos creando o editando.
      title: _isEditing ? l10n.edit : l10n.createUser,
      subtitle: _isEditing ? l10n.editUserDescription : l10n.createUserDescription,
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
                  // Fila 1: DNI (ocupa todo el ancho). Deshabilitado al editar.
                  fieldGroup(
                    l10n.dni,
                    general_textfield_NoICON(
                      l10n.dni,
                      controller: _dniCtrl,
                      borderRadius: 12.0,
                      // El DNI no se puede cambiar una vez creado el usuario.
                      enabled: !_isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.fillAllFields;
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: gap),

                  // Fila 2: Nombre y apellidos.
                  fieldRow(
                    fieldGroup(
                      l10n.name,
                      general_textfield_NoICON(
                        l10n.name,
                        controller: _nombreCtrl,
                        borderRadius: 12.0,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.fillAllFields;
                          }
                          return null;
                        },
                      ),
                    ),
                    fieldGroup(
                      l10n.lastName,
                      general_textfield_NoICON(
                        l10n.lastName,
                        controller: _apellidosCtrl,
                        borderRadius: 12.0,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.fillAllFields;
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: gap),

                  // Fila 3: Teléfono y fecha de nacimiento.
                  fieldRow(
                    fieldGroup(
                      l10n.telephone,
                      general_textfield_NoICON(
                        l10n.telephone,
                        controller: _telefonoCtrl,
                        borderRadius: 12.0,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.fillAllFields;
                          }
                          return null;
                        },
                      ),
                    ),
                    fieldGroup(
                      l10n.birthDate,
                      // Botón que abre el selector de fecha de nacimiento.
                      SizedBox(
                        height: 56,
                        child: FilledButton(
                          onPressed: _pickFechaNacimiento,
                          child: Text(
                            _fechaNacimiento == null
                                ? l10n.selectBirthDate
                                // Si ya hay fecha, la mostramos en formato dd/mm/aaaa.
                                : DateFormat('dd/MM/yyyy').format(_fechaNacimiento!),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: gap),

                  // Fila 4: Nivel de dependencia (ocupa todo el ancho).
                  fieldGroup(
                    l10n.dependencyLevel,
                    DropdownButtonFormField<String>(
                      value: _nivelDependencia,
                      borderRadius: BorderRadius.circular(12),
                      items: [
                        DropdownMenuItem(value: 'ninguna', child: Text(l10n.searchNoDependency)),
                        DropdownMenuItem(value: 'leve', child: Text(l10n.searchModerateDependency)),
                        DropdownMenuItem(value: 'moderada', child: Text(l10n.searchSevereDependency)),
                        DropdownMenuItem(value: 'severa', child: Text(l10n.searchHighDependency)),
                      ],
                      onChanged: (v) => setState(() => _nivelDependencia = v ?? 'ninguna'),
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

                  // Fila 5: Información adicional (campo de texto largo, opcional).
                  fieldGroup(
                    l10n.optionalInformation,
                    general_textfield_NoICON(
                      l10n.information,
                      controller: _informacionCtrl,
                      borderRadius: 12.0,
                      maxLines: 4,
                    ),
                  ),
                  SizedBox(height: gap),

                  // Fila 6: Datos médicos y medicación (campos opcionales).
                  fieldRow(
                    fieldGroup(
                      l10n.medicalData,
                      general_textfield_NoICON(
                        l10n.medicalData,
                        controller: _datosMedicosCtrl,
                        borderRadius: 12.0,
                      ),
                    ),
                    fieldGroup(
                      l10n.medication,
                      general_textfield_NoICON(
                        l10n.medication,
                        controller: _medicacionCtrl,
                        borderRadius: 12.0,
                      ),
                    ),
                  ),
                  SizedBox(height: gap),

                  // Fila 7: Dirección del usuario (opcional, ocupa todo el ancho).
                  fieldGroup(
                    l10n.direction,
                    general_textfield_NoICON(
                      l10n.direction,
                      controller: _direccionCtrl,
                      borderRadius: 12.0,
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Botones de acción: cancelar y crear/guardar.
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
                        // El texto del botón cambia según si estamos creando o editando.
                        child: FilledButton(
                          onPressed: _submit,
                          child: Text(_isEditing ? l10n.edit : l10n.createUser),
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

    // Si estamos incrustados, devolvemos solo el formulario.
    if (widget.onCancel != null) {
      return formBody;
    }

    // Si somos pantalla completa, envolvemos con Scaffold.
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
        selected: DrawerItem.users,
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
