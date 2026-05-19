import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/core/widgets/responsive_form_body.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/grupo.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/grupo_provider.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

// Página que sirve tanto para crear un grupo nuevo como para editar uno existente.
// Si se pasa el parámetro 'grupo', la página entra en modo edición.
// Si no se pasa, la página entra en modo creación.
class GrupoCreateEditPage extends ConsumerStatefulWidget {
  // El grupo a editar. Si es null, estamos creando uno nuevo.
  final Grupo? grupo;
  // Función que se llama si el usuario cancela la operación.
  final VoidCallback? onCancel;
  // Función que se llama cuando el grupo se ha guardado correctamente.
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

// Estado y lógica del formulario de creación/edición de grupos.
class _GrupoCreateEditPageState extends ConsumerState<GrupoCreateEditPage> {
  // Clave para poder validar el formulario antes de enviarlo.
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para el nombre y la descripción del grupo.
  late TextEditingController _nombreCtrl;
  late TextEditingController _descripcionCtrl;

  // Estado activo/inactivo del grupo. Por defecto está activo al crear.
  bool _activo = true;

  // Devuelve true si estamos editando un grupo existente, false si estamos creando.
  bool get _isEdit => widget.grupo != null;

  // Inicializa los campos con los datos del grupo si estamos editando,
  // o con valores vacíos si estamos creando uno nuevo.
  @override
  void initState() {
    super.initState();
    // Usamos la variable corta 'g' para acceder al grupo más fácilmente.
    final g = widget.grupo;
    _nombreCtrl = TextEditingController(text: g?.nombre ?? '');
    _descripcionCtrl = TextEditingController(text: g?.descripcion ?? '');
    // Si hay grupo, usamos su estado; si no, por defecto activo.
    _activo = g?.activo ?? true;
  }

  // Libera los controladores al cerrar la página para no desperdiciar memoria.
  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  // Valida el formulario y envía los datos al servidor para crear o actualizar el grupo.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    // Detectamos si el grupo está siendo desactivado (antes activo, ahora inactivo).
    final seDesactiva = _isEdit && widget.grupo!.activo && !_activo;
    // Detectamos si el grupo está siendo reactivado (antes inactivo, ahora activo).
    final seReactiva = _isEdit && !widget.grupo!.activo && _activo;

    // Si se va a desactivar el grupo, pedimos confirmación extra porque
    // esto también desactivará a todos sus teleoperadores.
    if (seDesactiva) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.confirmDeactivateGroup),
          content: Text(l10n.confirmDeactivateGroupContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            // Botón de confirmar en color de error para resaltar la gravedad.
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
              ),
              child: Text(l10n.accept),
            ),
          ],
        ),
      );
      // Si el usuario canceló la confirmación, no hacemos nada.
      if (confirmed != true) return;
    }

    final grupoService = ref.read(grupoServiceProvider);

    // Construimos el objeto con los datos que se enviarán al servidor.
    final payload = <String, dynamic>{
      'nombre': _nombreCtrl.text.trim(),
      'descripcion': _descripcionCtrl.text.trim(),
      'activo': _activo,
    };

    try {
      if (_isEdit) {
        // Modo edición: actualizamos el grupo existente.
        await grupoService.update(widget.grupo!.id, payload);
        if (!mounted) return;

        // Si el grupo fue reactivado, informamos al usuario de que los
        // teleoperadores deberán reactivarse manualmente.
        if (seReactiva) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: Text(l10n.groupReactivated),
              content: Text(l10n.groupReactivatedWorkersManual),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.accept),
                ),
              ],
            ),
          );
          if (!mounted) return;
        } else if (seDesactiva) {
          // Si se desactivó, avisamos de que los teleoperadores también se desactivaron.
          general_snackbar(context, l10n.groupDeactivatedWorkersAlso, 4);
        } else {
          // Actualización normal sin cambio de estado.
          general_snackbar(context, l10n.groupUpdatedSuccessfully, 2);
        }
      } else {
        // Modo creación: creamos un grupo nuevo.
        await grupoService.create(payload);
        if (!mounted) return;
        general_snackbar(context, l10n.groupCreatedSuccessfully, 2);
      }

      // Notificamos al padre que el grupo se guardó para que actualice la lista.
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

  // Construye el formulario visual con los campos de nombre, descripción y estado.
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    // Función auxiliar: crea el texto de la etiqueta encima de cada campo.
    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(text, style: textTheme.bodyMedium),
        );

    final formBody = ResponsiveFormBody(
      // El título cambia según si estamos editando o creando.
      title: _isEdit ? l10n.edit : l10n.newGroup,
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de nombre del grupo.
            label(l10n.name),
            general_textfield(l10n.name, false, controller: _nombreCtrl),
            const SizedBox(height: 16),

            // Campo de descripción del grupo (acepta varias líneas).
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
              // La descripción es obligatoria.
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.requiredField;
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Interruptor para marcar el grupo como activo o inactivo.
            // Al desactivar, todos los teleoperadores del grupo también se desactivan.
            Builder(builder: (context) {
              final colorScheme = Theme.of(context).colorScheme;
              return Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: Text(l10n.groupStatus, style: textTheme.bodyMedium),
                  // Si está inactivo y editando, mostramos una advertencia adicional.
                  subtitle: Text(
                    _activo
                        ? l10n.active
                        : (_isEdit
                            ? l10n.inactiveGroupWorkersWarning
                            : l10n.inactive),
                    style: TextStyle(
                      color: _activo
                          ? Colors.green.shade700
                          : colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: _activo,
                  // Al tocar el interruptor, actualizamos el estado local.
                  onChanged: (v) => setState(() => _activo = v),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
              );
            }),

            const SizedBox(height: 24),
            // Botones de acción: cancelar y guardar.
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
                  // Botón principal que ejecuta la validación y el envío.
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

    // Si estamos incrustados, devolvemos solo el formulario.
    if (widget.onCancel != null) return formBody;

    // Si somos pantalla completa, envolvemos con Scaffold.
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? l10n.edit : l10n.newGroup)),
      body: formBody,
    );
  }
}
