import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/core/widgets/responsive_form_body.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_create_page.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/trabajador.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/trabajador_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/grupo_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/grupo.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

class EditarTrabajadorPage extends ConsumerStatefulWidget {
  final Trabajador trabajador;
  const EditarTrabajadorPage({super.key, required this.trabajador});

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
      general_snackbar(context, l10n.workerCreatedSuccessfully, 2); // Cambia a workerUpdatedSuccessfully si existe
      Navigator.pop(context, true);
    } catch (e) {
      general_snackbar_error(context, l10n.errorCreatingWorker(e.toString()), 3); // Cambia a errorUpdatingWorker si existe
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.edit)),
      body: ResponsiveFormBody(
        title: l10n.edit,
        form: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.edit, style: textTheme.titleMedium?.copyWith(fontSize: 22)),
              const SizedBox(height: 12),
              Text(l10n.name, style: textTheme.bodyMedium),
              const SizedBox(height: 6),
              general_textfield(l10n.name, false, controller: _nombreCtrl),
              const SizedBox(height: 12),
              Text(l10n.lastName, style: textTheme.bodyMedium),
              const SizedBox(height: 6),
              general_textfield(l10n.lastName, false, controller: _apellidosCtrl),
              const SizedBox(height: 12),
              Text(l10n.email, style: textTheme.bodyMedium),
              const SizedBox(height: 6),
              general_textfield(l10n.email, false, controller: _correoCtrl),
              const SizedBox(height: 12),
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
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
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
                ),
                const SizedBox(height: 12),
                Text(l10n.group_label, style: textTheme.bodyMedium),
                const SizedBox(height: 6),
                _cargandoGrupos
                    ? Center(child: CircularProgressIndicator())
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
                const SizedBox(height: 12),
              ] else if (_rol == 'supervisor') ...[
                Text(l10n.dniLabel, style: textTheme.bodyMedium),
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
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: general_filledbutton(
                      l10n.save,
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
