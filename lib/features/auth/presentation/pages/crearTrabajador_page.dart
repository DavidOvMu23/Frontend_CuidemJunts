import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/trabajador_service.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/supervisor/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';

// Página para crear un nuevo trabajador (teleoperador, supervisor, etc.).
// Sigue el mismo patrón y estilo de comentarios que el resto de páginas
// del proyecto para mantener consistencia y facilitar la lectura.
class CrearTrabajadorPage extends ConsumerStatefulWidget {
  const CrearTrabajadorPage({super.key});

  @override
  ConsumerState<CrearTrabajadorPage> createState() =>
      _CrearTrabajadorPageState();
}

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
  // Grupo opcional (id). Lo dejamos como string para simplificar el formulario.
  String? _grupoId;
  final TextEditingController _grupoCtrl = TextEditingController();

  late final TrabajadorService _trabajadorService;

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

  // Envía el payload al backend para crear el trabajador.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Leemos el valor del campo grupo desde su controlador.
    _grupoId = _grupoCtrl.text.trim().isEmpty ? null : _grupoCtrl.text.trim();

    // Validaciones específicas según el rol (coinciden con las reglas del backend)
    // Contraseña mínima
    final contrasena = _contrasenaCtrl.text.trim();
    if (contrasena.length < 6) {
      general_snackbar_error(
        context,
        'La contraseña debe tener al menos 6 caracteres',
        3,
      );
      return;
    }

    // (validación role-specific siguiente)

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

    if (_rol == 'supervisor') {
      final dni = _dniCtrl.text.trim().toUpperCase();
      if (!RegExp(r'^[0-9]{8}[A-Z]$').hasMatch(dni)) {
        general_snackbar_error(context, 'DNI inválido: formato 12345678A', 3);
        return;
      }
    }
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
      // Algunos backends esperan camelCase 'grupoId' en lugar de 'grupo_id'.
      // Incluimos ambas claves para mejorar compatibilidad.
      'grupoId': _grupoId == null || _grupoId!.isEmpty
          ? null
          : int.tryParse(_grupoId!),
    };

    // Añadimos campos según tipo
    if (_rol == 'teleoperador') {
      payload['nia'] = _niaCtrl.text.trim();
    }
    if (_rol == 'supervisor') {
      payload['dni'] = _dniCtrl.text.trim().toUpperCase();
    }

    // DEBUG: imprime el payload en la consola para depuración
    // Revisa la salida de flutter run o build logs para ver esto.
    // Esto te permitirá confirmar si el NIA/DNI y la contraseña llegan al payload.
    // Si aquí está vacío o mal formado, el backend puede responder 500/400.
    // Pega la salida aquí si quieres que la revise.
    // Ejemplo visible en terminal: "Creating trabajador payload: {...}"
    // (Se puede quitar cuando esté todo solucionado).
    // ignore: avoid_print
    print('Creating trabajador payload: $payload');

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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

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

                  // Contraseña temporal/definitiva (campo con validación inline)
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
                        if (!RegExp(r'^[0-9]{8} ? ?$').hasMatch(s)) {
                          // Simple check: exactamente 8 dígitos
                          if (!RegExp(r'^[0-9]{8} ? ?$').hasMatch(s)) {
                            return 'NIA inválido: debe tener 8 dígitos';
                          }
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
                        if (!RegExp(r'^[0-9]{8}[A-Z] ? ?$').hasMatch(s)) {
                          if (!RegExp(r'^[0-9]{8}[A-Z] ? ?$').hasMatch(s)) {
                            return 'DNI inválido: formato 12345678A';
                          }
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
