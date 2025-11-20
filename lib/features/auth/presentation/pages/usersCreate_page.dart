import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_cuidemjunts/features/auth/data/service/usuario_service.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/supervisor/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

class CrearUserPage extends StatefulWidget {
  final void Function(bool) onToggleTheme;
  final void Function(Locale) onChangeLocale;

  const CrearUserPage({
    super.key,
    required this.onToggleTheme,
    required this.onChangeLocale,
  });

  @override
  State<CrearUserPage> createState() => _CrearUserPageState();
}

class _CrearUserPageState extends State<CrearUserPage> {
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

  late final UsuarioService _usuarioService;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _usuarioService = UsuarioService(
      baseUrl: 'http://cuidemjunts.zapto.org:3000',
    );
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
      initialDate: DateTime(now.year - 70),
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
      'informacion': _informacionCtrl.text.trim(),
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
      await _usuarioService.create(payload);
      general_snackbar(context, l10n.userCreatedSuccess, 2);
      Navigator.pop(context);
    } catch (e) {
      general_snackbar_error(context, l10n.userCreatedError, 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: appMainAppBar(onNotifications: () {}),
      drawer: appDrawer(
        context: context,
        selected: DrawerItem.users,
        onTapHome: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeSupervisorPage(
              onToggleTheme: widget.onToggleTheme,
              onChangeLocale: widget.onChangeLocale,
            ),
          ),
        ),
        onTapCalls: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UsersPage(
              onToggleTheme: widget.onToggleTheme,
              onChangeLocale: widget.onChangeLocale,
            ),
          ),
        ),
        onTapPreferences: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PreferencesPage(
              onToggleTheme: widget.onToggleTheme,
              onChangeLocale: widget.onChangeLocale,
            ),
          ),
        ),
        onLogoutConfirmed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginPage(
              onToggleTheme: widget.onToggleTheme,
              onChangeLocale: widget.onChangeLocale,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.createUser,
              style: textTheme.titleMedium?.copyWith(fontSize: 27),
            ),
            Text(l10n.createUserDescription, style: textTheme.bodyMedium),
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
                          l10n.newUser,
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
                                ),
                                const SizedBox(height: 15),

                                // Nombre y apellidos
                                Text(l10n.name, style: textTheme.bodyMedium),
                                const SizedBox(height: 4),
                                general_textfield_NoICON(
                                  l10n.name,
                                  controller: _nombreCtrl,
                                  borderRadius: 12.0,
                                ),
                                const SizedBox(height: 8),
                                general_textfield_NoICON(
                                  l10n.lastName,
                                  controller: _apellidosCtrl,
                                  borderRadius: 12.0,
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
                                  l10n.information,
                                  style: textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                general_textfield_NoICON(
                                  l10n.information,
                                  controller: _informacionCtrl,
                                  borderRadius: 12.0,
                                  maxLines: 4,
                                ),
                                const SizedBox(height: 15),

                                Text(
                                  l10n.optionalData,
                                  style: textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
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
                                        l10n.createUser,
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
