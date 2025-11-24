import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/trabajador_service.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';

// Página para crear un nuevo trabajador (teleoperador, supervisor, etc.)
class CrearTrabajadorPage extends ConsumerStatefulWidget {
  const CrearTrabajadorPage({super.key});

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

  // Grupo opcional (id). Lo dejamos como string para simplificar el formulario
  String? _grupoId;
  final TextEditingController _grupoCtrl = TextEditingController();

  // Servicio de trabajadores el late es para que se inicialice en el initState
  late final TrabajadorService _trabajadorService;

  // Inicializa el servicio de trabajadores
  @override
  void initState() {
    super.initState();
    _trabajadorService = TrabajadorService(
      baseUrl: 'http://cuidemjunts.zapto.org:3000',
    );
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
    _grupoCtrl.dispose();
    super.dispose();
  }

  // Envía el payload al backend para crear el trabajador
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    // Leemos el valor del campo grupo desde su controlador
    _grupoId = _grupoCtrl.text.trim().isEmpty ? null : _grupoCtrl.text.trim();

    // Validaciones específicas según el rol (coinciden con las reglas del backend)
    // Contraseña mínima

    // Obtenemos el valor del campo contraseña
    final contrasena = _contrasenaCtrl.text.trim();

    // Si la contraseña es menor a 6 caracteres, mostramos un snackbar de error
    if (contrasena.length < 6) {
      general_snackbar_error(
        context,
        l10n.passwordLengthError,
        3,
      );
      return;
    }

    // Si es teleoperador, validamos el NIA
    if (_rol == 'teleoperador') {
      final nia = _niaCtrl.text.trim();
      if (!RegExp(r'^[0-9]{8}$').hasMatch(nia)) {
        general_snackbar_error(
          context,
          l10n.invalidNIA,
          3,
        );
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
      'telefono': _telefonoCtrl.text.trim().isEmpty
          ? null
          : _telefonoCtrl.text.trim(),
      'rol': _rol,
      'grupo_id': _grupoId == null || _grupoId!.isEmpty
          ? null
          : int.tryParse(_grupoId!),

      'grupoId': _grupoId == null || _grupoId!.isEmpty
          ? null
          : int.tryParse(_grupoId!),
    };

    // Añadimos campos según tipo
    // Si es teleoperador, añadimos el NIA
    if (_rol == 'teleoperador') {
      payload['nia'] = _niaCtrl.text.trim();
    }
    // Si es supervisor, añadimos el DNI
    if (_rol == 'supervisor') {
      payload['dni'] = _dniCtrl.text.trim().toUpperCase();
    }

    print('Creating trabajador payload: $payload');

    // Enviamos el payload al backend
    //si todo va bien, mostramos un snackbar de exito y volvemos a la pagina de inicio
    try {
      await _trabajadorService.create(payload);
      general_snackbar(context, l10n.workerCreatedSuccessfully, 2);
      Navigator.pop(context);
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

    // Genera el formulario
    return Scaffold(
      appBar: appMainAppBar(onNotifications: () {}),
      drawer: appDrawer(
        context: context,
        selected: DrawerItem.telemarketers,
        onTapHome: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeSupervisorPage()),
        ),
        onTapCalls: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WorkersPage()),
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
                    l10n.newWorker,
                    style: textTheme.titleMedium?.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 12),

                  // Nombre
                  Text(l10n.name, style: textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  general_textfield(l10n.name, false, controller: _nombreCtrl),
                  const SizedBox(height: 12),

                  // Apellidos
                  Text(l10n.lastName, style: textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  general_textfield(
                    l10n.lastName,
                    false,
                    controller: _apellidosCtrl,
                  ),
                  const SizedBox(height: 12),

                  // Correo
                  Text(l10n.email, style: textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  general_textfield(l10n.email, false, controller: _correoCtrl),
                  const SizedBox(height: 12),

                  // Teléfono
                  Text(l10n.telephone, style: textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  general_textfield(
                    l10n.telephone,
                    false,
                    controller: _telefonoCtrl,
                  ),
                  const SizedBox(height: 12),

                  // Contraseña temporal/definitiva
                  Text(l10n.password, style: textTheme.bodyMedium),
                  const SizedBox(height: 6),
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
                  const SizedBox(height: 12),

                  // Rol
                  Text(l10n.role, style: textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _rol,
                    items: [
                      DropdownMenuItem(
                        value: 'teleoperador',
                        child: Text(l10n.teleoperator),
                      ),
                      DropdownMenuItem(
                        value: 'supervisor',
                        child: Text(l10n.supervisor),
                      ),
                      DropdownMenuItem(value: 'admin', child: Text(l10n.admin)),
                    ],
                    onChanged: (v) =>
                        setState(() => _rol = v ?? 'teleoperador'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Campos dependientes del rol
                  if (_rol == 'teleoperador') ...[
                    const SizedBox(height: 18),
                    Text(l10n.nia8digits, style: textTheme.bodyMedium),
                    const SizedBox(height: 6),
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
                    // Grupo (id) - opcional
                    Text(l10n.groupIdOptional, style: textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    general_textfield(
                      l10n.groupId,
                      false,
                      controller: _grupoCtrl,
                    ),
                    const SizedBox(height: 12),
                  ] else if (_rol == 'supervisor') ...[
                    Text(
                      l10n.dniLabel,
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
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
                    const SizedBox(height: 12),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: general_filledbutton(
                          l10n.createWorkerBtn,
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
