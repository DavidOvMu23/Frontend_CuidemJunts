import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/core/widgets/responsive_form_body.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/contacto_emergencia_service.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/usuario_provider.dart';

class EmergencyContactCreatePage extends ConsumerStatefulWidget {
  final ContactoEmergencia? contacto;
  final VoidCallback? onCancel;
  final VoidCallback? onSaved;

  const EmergencyContactCreatePage({super.key, this.contacto, this.onCancel, this.onSaved});

  @override
  ConsumerState<EmergencyContactCreatePage> createState() => _EmergencyContactCreatePageState();
}

class _EmergencyContactCreatePageState extends ConsumerState<EmergencyContactCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidosCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();

  bool get _isUsuarioSistema =>
      (widget.contacto?.dniUsuarioRef ?? '').isNotEmpty;
  

  String _search = '';
  final Set<String> _selectedDnis = {};

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidosCtrl.dispose();
    _telefonoCtrl.dispose();
    
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final c = widget.contacto;
    if (c != null) {
      _nombreCtrl.text = c.nombre;
      _apellidosCtrl.text = c.apellidos;
      _telefonoCtrl.text = c.telefono;
      if (c.usuariosDnis.isNotEmpty) _selectedDnis.addAll(c.usuariosDnis);
      else if ((c.dniUsuarioRef ?? '').trim().isNotEmpty) _selectedDnis.add(c.dniUsuarioRef!);
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final contactoService = ref.read(contactoEmergenciaServiceProvider);

    // Para usuarios del sistema solo actualizamos las relaciones
    if (!_isUsuarioSistema) {
      final nombre = _nombreCtrl.text.trim();
      final apellidos = _apellidosCtrl.text.trim();
      final telefono = _telefonoCtrl.text.trim();
      if (nombre.isEmpty || apellidos.isEmpty || telefono.isEmpty) {
        general_snackbar_error(context, l10n.fillAllFields, 2);
        return;
      }
    }

    // Normalizar y validar DNIs seleccionados
    final normalizedDnis = <String>[];
    for (final d in _selectedDnis) {
      final up = d.trim().toUpperCase();
      if (!RegExp(r'^[0-9]{8}[A-Z]$').hasMatch(up)) {
        general_snackbar_error(context, l10n.invalidDniValue(d.trim().toUpperCase()), 3);
        return;
      }
      normalizedDnis.add(up);
    }

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
        await contactoService.update(widget.contacto!.id, payload);
      } else {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final usuariosFuture = ref.read(usuarioServiceProvider).getAll();
    final isEdit = widget.contacto != null;
    final formBody = ResponsiveFormBody(
      title: isEdit ? l10n.edit : l10n.add,
      form: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            final gap = isWide ? 16.0 : 15.0;
            final textTheme = Theme.of(context).textTheme;

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
                  // Row 1: User search + list (full width)
                  fieldGroup(
                    l10n.searchUsers,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        Container(
                          constraints: const BoxConstraints(maxHeight: 220),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: FutureBuilder<List<Usuario>>(
                            future: usuariosFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                              if (snapshot.hasError) return Text('${l10n.error}: ${snapshot.error}', style: TextStyle(color: Theme.of(context).colorScheme.error));

                              final selfDni = (widget.contacto?.dniUsuarioRef ?? '').trim().toUpperCase();
                              final usuarios = snapshot.data ?? [];
                              final filtered = usuarios.where((u) {
                                if (selfDni.isNotEmpty && u.dni.toUpperCase() == selfDni) return false;
                                final full = '${u.nombre} ${u.apellidos} (${u.dni})'.toLowerCase();
                                return _search.isEmpty || full.contains(_search.toLowerCase());
                              }).toList();

                              if (filtered.isEmpty) return Center(child: Text(l10n.noResultsFound));

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

                  // Row 2: Selected count
                  Row(children: [Text('${l10n.selectedUser}: ${_selectedDnis.length}'), const Spacer()]),
                  SizedBox(height: gap),

                  // Aviso cuando el contacto es un usuario del sistema
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

                  // Row 3: Nombre | Apellidos
                  fieldRow(
                    fieldGroup(l10n.name, general_textfield_NoICON(l10n.name, controller: _nombreCtrl, borderRadius: 12.0, enabled: !_isUsuarioSistema)),
                    fieldGroup(l10n.lastName, general_textfield_NoICON(l10n.lastName, controller: _apellidosCtrl, borderRadius: 12.0, enabled: !_isUsuarioSistema)),
                  ),
                  SizedBox(height: gap),

                  // Row 4: Teléfono (full width)
                  fieldGroup(l10n.phone, general_textfield_NoICON(l10n.phone, controller: _telefonoCtrl, borderRadius: 12.0, enabled: !_isUsuarioSistema)),

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

    if (widget.onCancel != null) {
      return formBody;
    }
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? l10n.edit : l10n.add)),
      body: formBody,
    );
  }
}
