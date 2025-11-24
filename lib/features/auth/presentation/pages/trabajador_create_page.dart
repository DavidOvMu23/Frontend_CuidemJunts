import 'dart:convert';
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
        'La contraseña debe tener al menos 6 caracteres',
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
          'NIA inválido: debe tener 8 dígitos',
          3,
        );
        return;
      }
    }

    // si es supervisor, validamos el DNI
    if (_rol == 'supervisor') {
      final dni = _dniCtrl.text.trim().toUpperCase();
      if (!RegExp(r'^[0-9]{8}[A-Z]$').hasMatch(dni)) {
        general_snackbar_error(context, 'DNI inválido: formato 12345678A', 3);
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
      general_snackbar(context, 'Trabajador creado correctamente', 2);
      Navigator.pop(context);
    } catch (e) {
      general_snackbar_error(
        context,
        'Error al crear trabajador: ${e.toString()}',
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
    String? userName;
    String? userRole;

    if (authState.userData != null) {
      try {
        // Convertimos el JSON a un Map
        final userData =
            jsonDecode(authState.userData!) as Map<String, dynamic>;

        // Intentamos obtener el nombre del usuario
        userName =
            userData['nombre']?.toString() ??
            userData['name']?.toString() ??
            userData['correo']?.toString() ??
            userData['email']?.toString();
        userRole = userData['rol']?.toString();
      } catch (e) {
        // Si hay error al parsear el JSON, simplemente no mostramos nombre
        userName = null;
      }
    }

    // Genera el formulario
    return Scaffold(
      appBar: appMainAppBar(onNotifications: () {}),
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
                  Text('Nombre', style: textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  general_textfield('Nombre', false, controller: _nombreCtrl),
                  const SizedBox(height: 12),

                  // Apellidos
                  Text('Apellidos', style: textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  general_textfield(
                    'Apellidos',
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
                  Text('Teléfono', style: textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  general_textfield(
                    'Teléfono',
                    false,
                    controller: _telefonoCtrl,
                  ),
                  const SizedBox(height: 12),

                  // Contraseña temporal/definitiva
                  Text('Contraseña', style: textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _contrasenaCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Rol
                  Text('Rol', style: textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _rol,
                    items: const [
                      DropdownMenuItem(
                        value: 'teleoperador',
                        child: Text('Teleoperador'),
                      ),
                      DropdownMenuItem(
                        value: 'supervisor',
                        child: Text('Supervisor'),
                      ),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
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
                    Text('NIA (8 dígitos)', style: textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _niaCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'NIA',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                      ),
                      validator: (v) {
                        final s = v?.trim() ?? '';
                        if (!RegExp(r'^[0-9]{8}$').hasMatch(s)) {
                          return 'NIA inválido: debe tener 8 dígitos';
                        }
                        return null;
                      },
                    ),
                    // Grupo (id) - opcional
                    Text('Grupo (id) - opcional', style: textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    general_textfield(
                      'Grupo id',
                      false,
                      controller: _grupoCtrl,
                    ),
                    const SizedBox(height: 12),
                  ] else if (_rol == 'supervisor') ...[
                    Text(
                      'DNI (8 dígitos + letra)',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _dniCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'DNI',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                      ),
                      validator: (v) {
                        final s = (v ?? '').trim().toUpperCase();
                        if (!RegExp(r'^[0-9]{8}[A-Z]$').hasMatch(s)) {
                          return 'DNI inválido: formato 12345678A';
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
                          'Crear trabajador',
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
