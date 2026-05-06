import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/core/widgets/responsive_form_body.dart';
import 'package:flutter/services.dart';

class CallFormPage extends StatefulWidget {
  final Llamadas? llamadaInicial;
  final Future<List<UsuarioBusqueda>> Function(String query) buscarUsuarios;
  final Future<void> Function(CallFormData data) onSubmit;
  final VoidCallback? onCancel;
  final bool isEdit;

  const CallFormPage({
    super.key,
    this.llamadaInicial,
    required this.buscarUsuarios,
    required this.onSubmit,
    this.onCancel,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    final formBody = ResponsiveFormBody(
      title: widget.isEdit ? l10n.editCall : l10n.createCall,
      form: Form(
        key: _formKey,
        child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final gap = isWide ? 16.0 : 15.0;

              Widget label(String text) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(text, style: textTheme.bodyMedium),
                  );

              Widget fieldRow(Widget left, Widget right) {
                if (!isWide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      left,
                      SizedBox(height: gap),
                      right,
                    ],
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

              final userSearch = Column(
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
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: _buscandoUsuario
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _usuariosBusqueda.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
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
                                      leading: const Icon(Icons.person_outline),
                                    );
                                  },
                                ),
                    ),
                  if (_usuarioSeleccionado != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 18),
                          const SizedBox(width: 6),
                          Flexible(child: Text('${l10n.selectedUser}: ${_usuarioSeleccionado!.nombreCompleto}')),
                        ],
                      ),
                    ),
                ],
              );

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isWide)
                      // Desktop: Usuario y Fecha en una fila
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                label(l10n.user),
                                userSearch,
                              ],
                            ),
                          ),
                          SizedBox(width: gap),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                label(l10n.date),
                                SizedBox(
                                  height: 56,
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
                          ),
                        ],
                      )
                    else
                      // Mobile: Usuario y Fecha en columna
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          label(l10n.user),
                          userSearch,
                          SizedBox(height: gap),
                          label(l10n.date),
                          SizedBox(
                            height: 56,
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
                    SizedBox(height: gap),
                    if (isWide)
                      // Desktop: Estado, Hora, Duración en una fila
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                label(l10n.callStatus),
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
                                      style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(width: gap),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                label(l10n.time),
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
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                                    LengthLimitingTextInputFormatter(5),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: gap),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                label(l10n.duration),
                                general_textfield_NoICON(
                                  l10n.duration,
                                  controller: _duracionController,
                                  borderRadius: 12.0,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return l10n.requiredField;
                                    if (!RegExp(r'^\d{1,3}$').hasMatch(v)) return 'Solo números';
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      // Mobile: Estado, Hora, Duración en columna
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          label(l10n.callStatus),
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
                                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                              ),
                            ),
                          SizedBox(height: gap),
                          label(l10n.time),
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
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                              LengthLimitingTextInputFormatter(5),
                            ],
                          ),
                          SizedBox(height: gap),
                          label(l10n.duration),
                          general_textfield_NoICON(
                            l10n.duration,
                            controller: _duracionController,
                            borderRadius: 12.0,
                            validator: (v) {
                              if (v == null || v.isEmpty) return l10n.requiredField;
                              if (!RegExp(r'^\d{1,3}$').hasMatch(v)) return 'Solo números';
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                          ),
                        ],
                      ),
                    SizedBox(height: gap),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        label(l10n.summary),
                        general_textfield_NoICON(
                          l10n.summary,
                          controller: _resumenController,
                          borderRadius: 12.0,
                          validator: (v) => v == null || v.isEmpty ? l10n.requiredField : null,
                        ),
                        SizedBox(height: gap),
                        label(l10n.comments),
                        general_textfield_NoICON(
                          l10n.comments,
                          controller: _observacionesController,
                          borderRadius: 12.0,
                          maxLines: 3,
                        ),
                      ],
                    ),
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
                            onPressed: _onSubmit,
                            child: Text(widget.isEdit ? l10n.save : l10n.create),
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

    // Si tiene callback onCancel, está siendo usado como incrustado (sin Scaffold)
    if (widget.onCancel != null) {
      return formBody;
    }

    // Si no, mostrar con Scaffold (para uso como ruta completa)
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? l10n.editCall : l10n.createCall),
      ),
      body: formBody,
    );
  }
}
