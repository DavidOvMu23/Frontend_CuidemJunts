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

  @override
  void initState() {
    super.initState();
    _usuarioService = UsuarioService(baseUrl: 'http://localhost:3000');
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
      general_snackbar_error(context, 'Selecciona la fecha de nacimiento', 2);
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
      general_snackbar(context, 'Usuario creado correctamente', 2);
      Navigator.pop(context);
    } catch (e) {
      general_snackbar_error(
        context,
        'Error al crear usuario: ${e.toString()}',
        3,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.newUser,
                    style: textTheme.titleMedium?.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 12),

                  // DNI
                  Text('DNI', style: textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  general_textfield(
                    'DNI',
                    false,
                    controller: _dniCtrl,
                    borderRadius: 12.0,
                  ),
                  const SizedBox(height: 12),

                  // Nombre y apellidos
                  Text('Nombre', style: textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  general_textfield('Nombre', false, controller: _nombreCtrl),
                  const SizedBox(height: 8),
                  general_textfield(
                    'Apellidos',
                    false,
                    controller: _apellidosCtrl,
                  ),
                  const SizedBox(height: 12),

                  // Informacion
                  Text('Información', style: textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  general_textfield(
                    'Información',
                    false,
                    controller: _informacionCtrl,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),

                  // Fecha nacimiento
                  Text('Fecha de nacimiento', style: textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _pickFechaNacimiento,
                          child: Text(
                            _fechaNacimiento == null
                                ? 'Selecciona fecha'
                                : DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(_fechaNacimiento!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Estado cuenta
                  Text('Estado cuenta', style: textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _estadoCuenta,
                    items: const [
                      DropdownMenuItem(value: 'activo', child: Text('Activo')),
                      DropdownMenuItem(
                        value: 'suspendido',
                        child: Text('Suspendido'),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _estadoCuenta = v ?? 'activo'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Nivel dependencia
                  Text('Nivel de dependencia', style: textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _nivelDependencia,
                    items: const [
                      DropdownMenuItem(
                        value: 'ninguna',
                        child: Text('Ninguna'),
                      ),
                      DropdownMenuItem(value: 'leve', child: Text('Leve')),
                      DropdownMenuItem(
                        value: 'moderada',
                        child: Text('Moderada'),
                      ),
                      DropdownMenuItem(value: 'severa', child: Text('Severa')),
                    ],
                    onChanged: (v) =>
                        setState(() => _nivelDependencia = v ?? 'ninguna'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                    ),
                  ),

                  const SizedBox(height: 12),
                  general_textfield(
                    'Datos médicos / dolencias',
                    false,
                    controller: _datosMedicosCtrl,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  general_textfield(
                    'Medicacion',
                    false,
                    controller: _medicacionCtrl,
                  ),
                  const SizedBox(height: 8),
                  general_textfield(
                    'Teléfono',
                    false,
                    controller: _telefonoCtrl,
                  ),
                  const SizedBox(height: 8),
                  general_textfield(
                    'Dirección',
                    false,
                    controller: _direccionCtrl,
                  ),

                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: general_filledbutton(
                          'Crear usuario',
                          onPressed: _submit,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
