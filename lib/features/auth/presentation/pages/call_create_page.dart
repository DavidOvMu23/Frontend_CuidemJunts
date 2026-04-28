import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:flutter/services.dart';

class CallFormPage extends StatefulWidget {
  final Llamadas? llamadaInicial;
  final Future<List<UsuarioBusqueda>> Function(String query) buscarUsuarios;
  final Future<void> Function(CallFormData data) onSubmit;
  final bool isEdit;

  const CallFormPage({
    super.key,
    this.llamadaInicial,
    required this.buscarUsuarios,
    required this.onSubmit,
    this.isEdit = false,
  });

  @override
  State<CallFormPage> createState() => _CallFormPageState();
}

class UsuarioBusqueda {
  final String id;
  final String nombreCompleto;
  UsuarioBusqueda({required this.id, required this.nombreCompleto});
}

class CallFormData {
  final String usuarioId;
  final String resumen;
  final String duracion;
  final String estado;
  final String observaciones;
  final DateTime fecha;
  final String hora;
  CallFormData({
    required this.usuarioId,
    required this.resumen,
    required this.duracion,
    required this.estado,
    required this.observaciones,
    required this.fecha,
    required this.hora,
  });
}

class _CallFormPageState extends State<CallFormPage> {
      // ...existing code...
      String _estadoLegible(String estado, AppLocalizations l10n) {
        switch (estado) {
          case 'completada':
            return l10n.completed;
          case 'pendiente':
            return l10n.pending;
          case 'no_contesto':
            return l10n.noAnswer;
          default:
            return estado;
        }
      }
    // ...existing code...
    final TextEditingController _usuarioBusquedaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _resumenController;
  late TextEditingController _duracionController;
  late TextEditingController _observacionesController;
  late TextEditingController _horaController;
  DateTime? _fecha;
  String? _estado;
  UsuarioBusqueda? _usuarioSeleccionado;
  List<UsuarioBusqueda> _usuariosBusqueda = [];
  bool _buscandoUsuario = false;

  final List<String> _estados = [
    'completada',
    'pendiente',
    'no_contesto',
  ];

  @override
  void initState() {
    super.initState();
    final llamada = widget.llamadaInicial;
    _resumenController = TextEditingController(text: llamada?.resumen ?? '');
    _duracionController = TextEditingController(text: llamada?.duracion ?? '');
    _observacionesController = TextEditingController(text: llamada?.observaciones ?? '');
    _horaController = TextEditingController(text: llamada?.hora ?? '');
    _fecha = llamada?.fecha;
    _estado = llamada?.estado;
    if (llamada != null && llamada.usuarioId != null) {
      _usuarioSeleccionado = UsuarioBusqueda(
        id: llamada.usuarioId.toString(),
        nombreCompleto: (llamada.usuarioNombre ?? '') + (llamada.usuarioApellidos != null ? ' ' + llamada.usuarioApellidos! : ''),
      );
    }
  }

  @override
  void dispose() {
    _resumenController.dispose();
    _duracionController.dispose();
    _observacionesController.dispose();
    _horaController.dispose();
    _usuarioBusquedaController.dispose();
    super.dispose();
  }

  void _buscarUsuario(String query) async {
    setState(() => _buscandoUsuario = true);
    final resultados = await widget.buscarUsuarios(query);
    setState(() {
      _usuariosBusqueda = resultados;
      _buscandoUsuario = false;
    });
  }

  void _onSubmit() async {
    if (_formKey.currentState?.validate() != true) return;
    final l10n = AppLocalizations.of(context)!;
    if (_usuarioSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectUser)),
      );
      return;
    }
    if (_fecha == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectDate)),
      );
      return;
    }

    final data = CallFormData(
      usuarioId: _usuarioSeleccionado!.id,
      resumen: _resumenController.text.trim(),
      duracion: _duracionController.text.trim(),
      estado: _estado!,
      observaciones: _observacionesController.text.trim(),
      fecha: _fecha!,
      hora: _horaController.text.trim(),
    );

    try {
      await widget.onSubmit(data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final horizontalPadding = isDesktop ? 20.0 : 12.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? l10n.editCall : l10n.createCall),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEdit ? l10n.editCall : l10n.createCall,
              style: textTheme.titleMedium?.copyWith(fontSize: 27),
            ),
            Text(
              widget.isEdit ? l10n.editUserDescription : l10n.createUserDescription,
              style: textTheme.bodyMedium,
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
                          // Usuario
                          Text(l10n.user, style: textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _usuarioBusquedaController,
                                decoration: InputDecoration(
                                  hintText: l10n.searchUser,
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: _buscandoUsuario
                                      ? const Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        )
                                      : (_usuarioBusquedaController.text.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(Icons.clear),
                                              onPressed: () {
                                                setState(() {
                                                  _usuarioBusquedaController.clear();
                                                  _usuariosBusqueda = [];
                                                  _usuarioSeleccionado = null;
                                                });
                                              },
                                            )
                                          : null),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                ),
                                onChanged: (value) {
                                  if (value.length > 2) {
                                    _buscarUsuario(value);
                                  } else {
                                    setState(() => _usuariosBusqueda = []);
                                  }
                                },
                                validator: (_) => _usuarioSeleccionado == null ? l10n.selectUser : null,
                              ),
                              const SizedBox(height: 6),
                              if (_usuarioBusquedaController.text.isNotEmpty && _usuarioSeleccionado == null)
                                Container(
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                  ),
                                  child: _buscandoUsuario
                                      ? const Center(child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ))
                                      : (_usuariosBusqueda.isEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.info_outline, color: Colors.grey),
                                                  SizedBox(width: 8),
                                                  Text('No hay resultados', style: TextStyle(color: Colors.grey)),
                                                ],
                                              ),
                                            )
                                            : ListView.separated(
                                              shrinkWrap: true,
                                              padding: const EdgeInsets.symmetric(vertical: 6),
                                              itemCount: _usuariosBusqueda.length,
                                              separatorBuilder: (_, __) => const Divider(height: 1),
                                              itemBuilder: (context, i) {
                                                final u = _usuariosBusqueda[i];
                                                return ListTile(
                                                  title: Text(u.nombreCompleto),
                                                  onTap: () {
                                                    setState(() {
                                                      _usuarioSeleccionado = u;
                                                      _usuariosBusqueda = [];
                                                      _usuarioBusquedaController.text = u.nombreCompleto;
                                                    });
                                                  },
                                                  selected: _usuarioSeleccionado?.id == u.id,
                                                  leading: Icon(Icons.person_outline),
                                                );
                                              },
                                            )),
                                ),
                              if (_usuarioSeleccionado != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.green, size: 18),
                                      const SizedBox(width: 6),
                                      Flexible(child: Text('${l10n.selectedUser}: ${_usuarioSeleccionado!.nombreCompleto}')),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          // Fecha
                          Text(l10n.date, style: textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _fecha ?? DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2035),
                                    );
                                    if (picked != null) setState(() => _fecha = picked);
                                  },
                                  child: Text(
                                    _fecha != null
                                        ? '${_fecha!.day.toString().padLeft(2, '0')}/${_fecha!.month.toString().padLeft(2, '0')}/${_fecha!.year}'
                                        : l10n.selectDate,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          // Hora
                          Text(l10n.time, style: textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          general_textfield_NoICON(
                            l10n.time,
                            controller: _horaController,
                            borderRadius: 12.0,
                            validator: (v) {
                              if (v == null || v.isEmpty) return l10n.requiredField;
                              final regex = RegExp(r'^([01]?\d|2[0-3]):[0-5]\d$');
                              if (!regex.hasMatch(v)) return 'Formato HH:MM';
                              return null;
                            },
                            // Solo permitir números y dos puntos
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                              LengthLimitingTextInputFormatter(5),
                            ],
                          ),
                          const SizedBox(height: 15),
                          // Resumen
                          Text(l10n.summary, style: textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          general_textfield_NoICON(
                            l10n.summary,
                            controller: _resumenController,
                            borderRadius: 12.0,
                            validator: (v) => v == null || v.isEmpty ? l10n.requiredField : null,
                          ),
                          const SizedBox(height: 15),
                          // Duración
                          Text(l10n.duration, style: textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          general_textfield_NoICON(
                            l10n.duration,
                            controller: _duracionController,
                            borderRadius: 12.0,
                              validator: (v) {
                                if (v == null || v.isEmpty) return l10n.requiredField;
                                // Aceptar solo números (1-3 dígitos)
                                if (!RegExp(r'^\d{1,3}$').hasMatch(v)) return 'Solo números';
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                          ),
                          const SizedBox(height: 15),
                          // Estado de la llamada
                          Text(l10n.callStatus, style: textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            value: _estado,
                            hint: Text(l10n.callStatus),
                            items: _estados
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(_estadoLegible(e, l10n)),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _estado = v),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                            ),
                            validator: (v) => v == null ? l10n.requiredField : null,
                          ),
                          if (_estado == null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                              child: Text(
                                l10n.callStatus,
                                style: TextStyle(color: Colors.redAccent, fontSize: 13),
                              ),
                            ),
                          const SizedBox(height: 15),
                          // Observaciones
                          Text(l10n.comments, style: textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          general_textfield_NoICON(
                            l10n.comments,
                            controller: _observacionesController,
                            borderRadius: 12.0,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(l10n.cancel),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  onPressed: _onSubmit,
                                  child: Text(widget.isEdit ? l10n.save : l10n.create),
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
            ),
          ],
        ),
      ),
    );
  }
}
