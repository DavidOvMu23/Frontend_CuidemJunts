import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/contacto_emergencia_service.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/usuario_provider.dart';

class EmergencyContactCreatePage extends ConsumerStatefulWidget {
  final ContactoEmergencia? contacto;

  const EmergencyContactCreatePage({super.key, this.contacto});

  @override
  ConsumerState<EmergencyContactCreatePage> createState() => _EmergencyContactCreatePageState();
}

class _EmergencyContactCreatePageState extends ConsumerState<EmergencyContactCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidosCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  

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

    final nombre = _nombreCtrl.text.trim();
    final apellidos = _apellidosCtrl.text.trim();
    final telefono = _telefonoCtrl.text.trim();
    if (nombre.isEmpty || apellidos.isEmpty || telefono.isEmpty) {
      general_snackbar_error(context, l10n.fillAllFields, 2);
      return;
    }

    // Validar DNIs seleccionados (si hay) antes de enviarlos
      final dniValidator = RegExp(r'^[0-9]{8}[A-Z]$');
      final dniRegexCorrect = RegExp(r'^[0-9]{8}[A-Z]$');
      final dniRegexFinal = RegExp(r'^[0-9]{8}[A-Z]$');
      final dniPattern = RegExp(r'^[0-9]{8}[A-Z]$');
      final dniCorrect = RegExp(r'^[0-9]{8}[A-Z]$');
    // Normalize and validate DNIs: uppercase and 8 digits + letter
    final normalizedDnis = <String>[];
      final dniCheck = RegExp(r'^[0-9]{8}[A-Z]$');
    for (final d in _selectedDnis) {
      final up = d.trim().toUpperCase();
        if (!RegExp(r'^[0-9]{8}[A-Z]$').hasMatch(up)) {
        general_snackbar_error(context, 'DNI inválido: $d', 3);
        return;
      }
      normalizedDnis.add(up);
    }

    final payload = {
      'nombre': nombre,
      'apellidos': apellidos,
      'telefono': telefono,
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
      Navigator.pop(context, true);
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

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? l10n.edit : l10n.add)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? l10n.edit : l10n.add,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 27),
            ),
            Text(
              isEdit ? l10n.editUserDescription : l10n.createUserDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Material(
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Buscador y lista de usuarios
                          Text(l10n.searchUsers, style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 6),
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

                                final usuarios = snapshot.data ?? [];
                                final filtered = usuarios.where((u) {
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
                          const SizedBox(height: 12),
                          Row(children: [Text('${l10n.selectedUser}: ${_selectedDnis.length}'), const Spacer()]),
                          const SizedBox(height: 12),
                          // Campos del contacto
                          Text(l10n.name, style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 6),
                          general_textfield_NoICON(l10n.name, controller: _nombreCtrl, borderRadius: 12.0),
                          const SizedBox(height: 10),
                          Text(l10n.lastName, style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 6),
                          general_textfield_NoICON(l10n.lastName, controller: _apellidosCtrl, borderRadius: 12.0),
                          const SizedBox(height: 10),
                          Text(l10n.phone, style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 6),
                          general_textfield_NoICON(l10n.phone, controller: _telefonoCtrl, borderRadius: 12.0),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(onPressed: _submit, child: Text(isEdit ? l10n.save : l10n.create)),
                              ),
                            ],
                          ),
                        ],
                      ),
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
