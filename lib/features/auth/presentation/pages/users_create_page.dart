import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/calls_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/emergency_contacts_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/notifications_page.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/usuario_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';

class CrearUserPage extends ConsumerStatefulWidget {
  final Usuario? usuario;
  const CrearUserPage({super.key, this.usuario});

  @override
  ConsumerState<CrearUserPage> createState() => _CrearUserPageState();
}

class _CrearUserPageState extends ConsumerState<CrearUserPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dniCtrl = TextEditingController();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidosCtrl = TextEditingController();
  final TextEditingController _informacionCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  final TextEditingController _datosMedicosCtrl = TextEditingController();
  final TextEditingController _medicacionCtrl = TextEditingController();
  final TextEditingController _direccionCtrl = TextEditingController();

  DateTime? _fechaNacimiento;
  String _estadoCuenta = 'activo';
  String _nivelDependencia = 'ninguna';
  bool get _isEditing => widget.usuario != null;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
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

      // Mapear nivel de dependencia
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

  Future<void> _pickFechaNacimiento() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(now.year - 70),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _fechaNacimiento = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fechaNacimiento == null) {
      general_snackbar_error(context, l10n.selectBirthDate, 2);
      return;
    }

    final payload = {
      'dni': _dniCtrl.text.trim().toUpperCase(),
      'nombre': _nombreCtrl.text.trim(),
      'apellidos': _apellidosCtrl.text.trim(),
      'informacion': _informacionCtrl.text.trim().isEmpty
          ? null
          : _informacionCtrl.text.trim(),
      'estado_cuenta': _estadoCuenta,
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
        await usuarioService.update(widget.usuario!.dni, payload);
        if (!mounted) return;
        general_snackbar(context, l10n.userUpdatedSuccess, 2);
        Navigator.pop(context, true);
      } else {
        await usuarioService.create(payload);
        if (!mounted) return;
        general_snackbar(context, l10n.userCreatedSuccess, 2);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;

      // Log del error para depuración
      print('Error al crear/editar usuario: $e');

      String errorMessage = _isEditing
          ? l10n.userUpdatedError
          : l10n.userCreatedError;
      final errorString = e.toString();

      // Verificar errores específicos conocidos
      if (errorString.contains('Formato de DNI incorrecto')) {
        errorMessage = l10n.invalidDNI; // "DNI inválido: formato 12345678A"
      } else if (errorString.contains('El usuario con este DNI ya existe')) {
        errorMessage = l10n.userErrorDNiExists;
      } else if (errorString.contains('must be a string')) {
        errorMessage = 'Error de tipo de datos: verifica los campos de texto';
      }

      general_snackbar_error(
        context,
        errorMessage,
        4, // Un poco más de tiempo para leer
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final userRole = authState.rol;
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? l10n.edit : l10n.createUser,
              style: textTheme.titleMedium?.copyWith(fontSize: 27),
            ),
            Text(
              _isEditing
                  ? l10n.editUserDescription
                  : l10n.createUserDescription,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Material(
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing ? l10n.edit : l10n.newUser,
                          style: textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // DNI
                                Text(l10n.dni, style: textTheme.bodyMedium),
                                const SizedBox(height: 4),
                                general_textfield_NoICON(
                                  l10n.dni,
                                  controller: _dniCtrl,
                                  borderRadius: 12.0,
                                  enabled: !_isEditing,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return l10n.fillAllFields;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),

                                // Nombre y apellidos
                                Text(l10n.name, style: textTheme.bodyMedium),
                                const SizedBox(height: 4),
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
                                const SizedBox(height: 8),
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
                                const SizedBox(height: 15),
                                Text(
                                  l10n.telephone,
                                  style: textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
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
                                const SizedBox(height: 15),
                                // Fecha nacimiento
                                Text(
                                  l10n.birthDate,
                                  style: textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: _pickFechaNacimiento,
                                        child: Text(
                                          _fechaNacimiento == null
                                              ? l10n.selectBirthDate
                                              : DateFormat(
                                                  'dd/MM/yyyy',
                                                ).format(_fechaNacimiento!),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Nivel dependencia
                                Text(
                                  l10n.dependencyLevel,
                                  style: textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<String>(
                                  value: _nivelDependencia,
                                  borderRadius: BorderRadius.circular(12),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'ninguna',
                                      child: Text(l10n.searchNoDependency),
                                    ),
                                    DropdownMenuItem(
                                      value: 'leve',
                                      child: Text(
                                        l10n.searchModerateDependency,
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'moderada',
                                      child: Text(l10n.searchSevereDependency),
                                    ),
                                    DropdownMenuItem(
                                      value: 'severa',
                                      child: Text(l10n.searchHighDependency),
                                    ),
                                  ],
                                  onChanged: (v) => setState(
                                    () => _nivelDependencia = v ?? 'ninguna',
                                  ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                  ),
                                ),
                                const SizedBox(height: 15),

                                // Informacion
                                Text(
                                  l10n.optionalInformation,
                                  style: textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                general_textfield_NoICON(
                                  l10n.information,
                                  controller: _informacionCtrl,
                                  borderRadius: 12.0,
                                  maxLines: 4,
                                ),
                                const SizedBox(height: 8),
                                general_textfield_NoICON(
                                  l10n.medicalData,
                                  controller: _datosMedicosCtrl,
                                  borderRadius: 12.0,
                                ),
                                const SizedBox(height: 8),
                                general_textfield_NoICON(
                                  l10n.medication,
                                  controller: _medicacionCtrl,
                                  borderRadius: 12.0,
                                ),
                                const SizedBox(height: 8),
                                general_textfield_NoICON(
                                  l10n.direction,
                                  controller: _direccionCtrl,
                                  borderRadius: 12.0,
                                ),

                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    general_textbutton(
                                      l10n.cancel,
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: general_filledbutton(
                                        _isEditing
                                            ? l10n.edit
                                            : l10n.createUser,
                                        onPressed: _submit,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
