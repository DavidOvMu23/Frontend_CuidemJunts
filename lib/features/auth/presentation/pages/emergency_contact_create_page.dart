import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/core/widgets/loading_skeleton.dart';
import 'package:frontend_cuidemjunts/core/widgets/responsive_form_body.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/contacto_emergencia_service.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/usuario_provider.dart';

// Página para crear un contacto de emergencia nuevo o editar uno existente.
// Un contacto puede ser externo (persona de contacto libre) o del sistema
// (un usuario ya registrado en la aplicación).
class EmergencyContactCreatePage extends ConsumerStatefulWidget {
  // El contacto a editar. Si es null, estamos creando uno nuevo.
  final ContactoEmergencia? contacto;
  // Función que se llama si el usuario cancela la operación.
  final VoidCallback? onCancel;
  // Función que se llama cuando el contacto se ha guardado correctamente.
  final VoidCallback? onSaved;

  const EmergencyContactCreatePage({super.key, this.contacto, this.onCancel, this.onSaved});

  @override
  ConsumerState<EmergencyContactCreatePage> createState() => _EmergencyContactCreatePageState();
}

// Estado y lógica del formulario de creación/edición de contactos de emergencia.
class _EmergencyContactCreatePageState extends ConsumerState<EmergencyContactCreatePage> {
  // Clave para validar el formulario antes de enviarlo.
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para nombre, apellidos y teléfono.
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidosCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();

  // Devuelve true si el contacto está vinculado a un usuario del sistema.
  // En ese caso los campos de nombre y teléfono son de solo lectura.
  bool get _isUsuarioSistema =>
      (widget.contacto?.dniUsuarioRef ?? '').isNotEmpty;

  // Texto que el usuario escribe para buscar usuarios del sistema.
  String _search = '';

  // Conjunto de DNIs de usuarios seleccionados para asociar a este contacto.
  final Set<String> _selectedDnis = {};

  // Libera los controladores al cerrar la página.
  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidosCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  // Inicializa los campos del formulario.
  // Si estamos editando, cargamos los datos del contacto existente.
  @override
  void initState() {
    super.initState();
    final c = widget.contacto;
    if (c != null) {
      _nombreCtrl.text = c.nombre;
      _apellidosCtrl.text = c.apellidos;
      _telefonoCtrl.text = c.telefono;
      // Cargamos los DNIs de usuarios ya asociados a este contacto.
      if (c.usuariosDnis.isNotEmpty) _selectedDnis.addAll(c.usuariosDnis);
      // Si es un contacto del sistema, añadimos también el DNI de referencia.
      else if ((c.dniUsuarioRef ?? '').trim().isNotEmpty) _selectedDnis.add(c.dniUsuarioRef!);
    }
  }

  // Valida los datos y los envía al servidor para crear o actualizar el contacto.
  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final contactoService = ref.read(contactoEmergenciaServiceProvider);

    // Para contactos externos (no del sistema), validamos que los campos obligatorios estén rellenos.
    if (!_isUsuarioSistema) {
      final nombre = _nombreCtrl.text.trim();
      final apellidos = _apellidosCtrl.text.trim();
      final telefono = _telefonoCtrl.text.trim();
      if (nombre.isEmpty || apellidos.isEmpty || telefono.isEmpty) {
        general_snackbar_error(context, l10n.fillAllFields, 2);
        return;
      }
    }

    // Normalizamos los DNIs a mayúsculas y verificamos que tengan el formato correcto.
    final normalizedDnis = <String>[];
    for (final dniRaw in _selectedDnis) {
      final dniNormalizado = dniRaw.trim().toUpperCase();
      // El DNI español tiene 8 dígitos seguidos de una letra mayúscula.
      if (!RegExp(r'^[0-9]{8}[A-Z]$').hasMatch(dniNormalizado)) {
        general_snackbar_error(context, l10n.invalidDniValue(dniRaw.trim().toUpperCase()), 3);
        return;
      }
      normalizedDnis.add(dniNormalizado);
    }

    // Para contactos del sistema, solo actualizamos las relaciones con usuarios.
    // Para contactos externos, enviamos también los datos del contacto.
    final payload = _isUsuarioSistema
        ? {'usuariosDnis': normalizedDnis}
        : {
            'nombre': _nombreCtrl.text.trim(),
            'apellidos': _apellidosCtrl.text.trim(),
            'telefono': _telefonoCtrl.text.trim(),
            'usuariosDnis': normalizedDnis,
          };

    try {
      if (widget.contacto != null) {
        // Modo edición: actualizamos el contacto existente.
        await contactoService.update(widget.contacto!.id, payload);
      } else {
        // Modo creación: creamos el contacto nuevo.
        await contactoService.create(payload);
      }
      if (!mounted) return;
      general_snackbar(context, l10n.userCreatedSuccess, 2);
      if (widget.onSaved != null) {
        widget.onSaved!();
      } else {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;

      // Extraemos el mensaje de error del servidor para mostrarlo al usuario.
      String message = '$e';
      try {
        if (e is DioException) {
          final resp = e.response;
          if (resp != null && resp.data != null) {
            if (resp.data is Map && resp.data['message'] != null) {
              message = resp.data['message'].toString();
            } else {
              message = resp.data.toString();
            }
          } else {
            message = e.message ?? e.toString();
          }
        }
      } catch (_) {}
      general_snackbar_error(context, '${l10n.error}: $message', 6);
    }
  }

  // Construye el formulario visual.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Lista de usuarios del sistema en tiempo real (provider con polling).
    final usuariosAsync = ref.watch(usuariosProvider);

    // El título del formulario cambia según si estamos editando o creando.
    final isEdit = widget.contacto != null;

    final formBody = ResponsiveFormBody(
      title: isEdit ? l10n.edit : l10n.add,
      form: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // En pantallas anchas usamos dos columnas.
            final isWide = constraints.maxWidth >= AppBreakpoints.formWide;
            final gap = isWide ? 16.0 : 15.0;
            final textTheme = Theme.of(context).textTheme;

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
                  // Sección de búsqueda y selección de usuarios del sistema.
                  // Permite vincular este contacto con uno o varios usuarios registrados.
                  fieldGroup(
                    l10n.searchUsers,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Campo de búsqueda de usuarios por nombre o DNI.
                        TextField(
                          decoration: InputDecoration(
                            hintText: l10n.searchUsers,
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                          ),
                          onChanged: (v) => setState(() => _search = v),
                        ),
                        const SizedBox(height: 8),
                        // Lista de usuarios con casillas de verificación para seleccionar.
                        Container(
                          constraints: const BoxConstraints(maxHeight: 220),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: usuariosAsync.when(
                            loading: () => const AppSkeletonList(count: 4, itemHeight: 72),
                            error: (e, _) => Text('${l10n.error}: $e', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                            data: (usuarios) {
                              // El DNI del usuario de referencia (si lo hay) se excluye de la lista.
                              final selfDni = (widget.contacto?.dniUsuarioRef ?? '').trim().toUpperCase();

                              // Filtramos los usuarios que coinciden con el texto buscado.
                              final filtered = usuarios.where((u) {
                                // Excluimos al propio usuario de referencia de la lista.
                                if (selfDni.isNotEmpty && u.dni.toUpperCase() == selfDni) return false;
                                final full = '${u.nombre} ${u.apellidos} (${u.dni})'.toLowerCase();
                                return _search.isEmpty || full.contains(_search.toLowerCase());
                              }).toList();

                              if (filtered.isEmpty) return Center(child: Text(l10n.noResultsFound));

                              // Lista con casillas para marcar/desmarcar cada usuario.
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final u = filtered[index];
                                  final selected = _selectedDnis.contains(u.dni);
                                  return CheckboxListTile(
                                    value: selected,
                                    title: Text('${u.nombre} ${u.apellidos} (${u.dni})'),
                                    controlAffinity: ListTileControlAffinity.leading,
                                    // Al marcar/desmarcar, actualizamos el conjunto de DNIs seleccionados.
                                    onChanged: (checked) => setState(() {
                                      if (checked == true)
                                        _selectedDnis.add(u.dni);
                                      else
                                        _selectedDnis.remove(u.dni);
                                    }),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: gap),

                  // Contador que muestra cuántos usuarios están seleccionados.
                  Row(children: [Text('${l10n.selectedUser}: ${_selectedDnis.length}'), const Spacer()]),
                  SizedBox(height: gap),

                  // Aviso informativo cuando el contacto es un usuario del sistema.
                  // En ese caso los campos de nombre y teléfono están bloqueados.
                  if (_isUsuarioSistema) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.systemUser,
                              style: textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: gap),
                  ],

                  // Campos de nombre y apellidos.
                  // Para contactos del sistema son de solo lectura (enabled: false).
                  fieldRow(
                    fieldGroup(l10n.name, general_textfield_NoICON(l10n.name, controller: _nombreCtrl, borderRadius: 12.0, enabled: !_isUsuarioSistema)),
                    fieldGroup(l10n.lastName, general_textfield_NoICON(l10n.lastName, controller: _apellidosCtrl, borderRadius: 12.0, enabled: !_isUsuarioSistema)),
                  ),
                  SizedBox(height: gap),

                  // Campo de teléfono. También bloqueado para contactos del sistema.
                  fieldGroup(l10n.phone, general_textfield_NoICON(l10n.phone, controller: _telefonoCtrl, borderRadius: 12.0, enabled: !_isUsuarioSistema)),

                  const SizedBox(height: 24),
                  // Botones de acción: cancelar y guardar/crear.
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
                        // El texto del botón cambia según si estamos editando o creando.
                        child: FilledButton(
                          onPressed: _submit,
                          child: Text(isEdit ? l10n.save : l10n.create),
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
      appBar: AppBar(title: Text(isEdit ? l10n.edit : l10n.add)),
      body: formBody,
    );
  }
}
