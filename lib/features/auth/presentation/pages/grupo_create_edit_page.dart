import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/core/widgets/responsive_form_body.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/grupo.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/grupo_provider.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

class GrupoCreateEditPage extends ConsumerStatefulWidget {
  final Grupo? grupo;
  final VoidCallback? onCancel;
  final VoidCallback? onSaved;

  const GrupoCreateEditPage({
    super.key,
    this.grupo,
    this.onCancel,
    this.onSaved,
  });

  @override
  ConsumerState<GrupoCreateEditPage> createState() =>
      _GrupoCreateEditPageState();
}

class _GrupoCreateEditPageState extends ConsumerState<GrupoCreateEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _descripcionCtrl;
  bool _activo = true;

  bool get _isEdit => widget.grupo != null;

  @override
  void initState() {
    super.initState();
    final g = widget.grupo;
    _nombreCtrl = TextEditingController(text: g?.nombre ?? '');
    _descripcionCtrl = TextEditingController(text: g?.descripcion ?? '');
    _activo = g?.activo ?? true;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    final grupoService = ref.read(grupoServiceProvider);
    final payload = <String, dynamic>{
      'nombre': _nombreCtrl.text.trim(),
      'descripcion': _descripcionCtrl.text.trim(),
      'activo': _activo,
    };
    try {
      if (_isEdit) {
        await grupoService.update(widget.grupo!.id, payload);
        if (!mounted) return;
        general_snackbar(context, l10n.groupUpdatedSuccessfully, 2);
      } else {
        await grupoService.create(payload);
        if (!mounted) return;
        general_snackbar(context, l10n.groupCreatedSuccessfully, 2);
      }
      if (widget.onSaved != null) {
        widget.onSaved!();
      } else {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      general_snackbar_error(
          context, '${l10n.error}: ${extractErrorMessage(e)}', 5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(text, style: textTheme.bodyMedium),
        );

    final formBody = ResponsiveFormBody(
      title: _isEdit ? l10n.edit : l10n.newGroup,
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            label(l10n.name),
            general_textfield(l10n.name, false, controller: _nombreCtrl),
            const SizedBox(height: 16),
            label(l10n.description),
            TextFormField(
              controller: _descripcionCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.description,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.requiredField;
                return null;
              },
            ),
            const SizedBox(height: 16),
            Builder(builder: (context) {
              final colorScheme = Theme.of(context).colorScheme;
              return Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: Text(l10n.accountStatus, style: textTheme.bodyMedium),
                  subtitle: Text(
                    _activo ? l10n.active : l10n.inactive,
                    style: TextStyle(
                      color: _activo
                          ? Colors.green.shade700
                          : colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: _activo,
                  onChanged: (v) => setState(() => _activo = v),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                    child: Text(l10n.cancel,
                        style: const TextStyle(color: Colors.redAccent)),
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
      ),
    );

    if (widget.onCancel != null) return formBody;
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? l10n.edit : l10n.newGroup)),
      body: formBody,
    );
  }
}
