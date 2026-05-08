import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/core/widgets/loading_skeleton.dart';
import 'package:frontend_cuidemjunts/core/widgets/responsive_form_body.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/trabajador.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/trabajador_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/grupo_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/grupo.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

class EditarTrabajadorPage extends ConsumerStatefulWidget {
  final Trabajador trabajador;
  final VoidCallback? onCancel;
  final VoidCallback? onSaved;
  const EditarTrabajadorPage({super.key, required this.trabajador, this.onCancel, this.onSaved});

  @override
  ConsumerState<EditarTrabajadorPage> createState() => _EditarTrabajadorPageState();
}

class _EditarTrabajadorPageState extends ConsumerState<EditarTrabajadorPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _apellidosCtrl;
  late TextEditingController _correoCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _contrasenaCtrl;
  late TextEditingController _niaCtrl;
  late TextEditingController _dniCtrl;
  String _rol = 'teleoperador';
  int? _grupoId;
  bool _activo = true;
  List<Grupo> _grupos = <Grupo>[];
  bool _cargandoGrupos = false;

  @override
  void initState() {
    super.initState();
    final t = widget.trabajador;
    _nombreCtrl = TextEditingController(text: t.nombre);
    _apellidosCtrl = TextEditingController(text: t.apellidos);
    _correoCtrl = TextEditingController(text: t.correo);
    _telefonoCtrl = TextEditingController();
    _contrasenaCtrl = TextEditingController();
    _niaCtrl = TextEditingController();
    _dniCtrl = TextEditingController();
    _rol = t.rol;
    _grupoId = t.grupoId;
    _activo = t.activo;
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
    } catch (_) {} finally {
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    if (_rol == 'teleoperador' && _grupoId == null) {
      general_snackbar_error(context, l10n.noGroupAssigned, 3);
      return;
    }
    final payload = <String, dynamic>{
      'nombre': _nombreCtrl.text.trim(),
      'apellidos': _apellidosCtrl.text.trim(),
      'correo': _correoCtrl.text.trim(),
      'rol': _rol,
      'grupoId': _grupoId,
      'activo': _activo,
    };
    if (_contrasenaCtrl.text.trim().isNotEmpty) {
      payload['contrasena'] = _contrasenaCtrl.text.trim();
    }
    if (_rol == 'teleoperador') {
      payload['nia'] = _niaCtrl.text.trim();
    }
    if (_rol == 'supervisor') {
      payload['dni'] = _dniCtrl.text.trim().toUpperCase();
    }
    // Remove null values to avoid sending null keys
    payload.removeWhere((key, value) => value == null);
    try {
      final trabajadorService = ref.read(trabajadorServiceProvider);
      try {
        print('Updating trabajador payload: $payload');
        print('Updating trabajador payload JSON: ${jsonEncode(payload)}');
      } catch (_) {}
      await trabajadorService.update(widget.trabajador.id, payload);
      general_snackbar(context, l10n.workerCreatedSuccessfully, 2);
      if (widget.onSaved != null) {
        widget.onSaved!();
      } else {
        Navigator.pop(context, true);
      }
    } catch (e) {
      general_snackbar_error(context, '${l10n.error}: ${extractErrorMessage(e)}', 5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final formBody = ResponsiveFormBody(
      title: l10n.edit,
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
                        ),
                      ),
                      fieldGroup(
                        l10n.group_label,
                        _cargandoGrupos
                            ? const AppSkeletonBox(height: 56)
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
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Estado activo/inactivo
                  Builder(builder: (context) {
                    final colorScheme = Theme.of(context).colorScheme;
                    return Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile(
                        title: Text(l10n.accountStatus, style: textTheme.bodyMedium),
                        subtitle: Text(
                          _activo ? l10n.active : l10n.inactive,
                          style: TextStyle(
                            color: _activo ? Colors.green.shade700 : colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        value: _activo,
                        onChanged: (v) => setState(() => _activo = v),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      ),
                    );
                  }),

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
                          child: Text(l10n.save),
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
      appBar: AppBar(title: Text(l10n.edit)),
      body: formBody,
    );
  }
}
