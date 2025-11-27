import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widgets_communications_demo.dart';

// -------- DEMO: APPBAR --------
// Muestra el AppBar estándar con badge de notificaciones
// y el Drawer reutilizable con opciones y logout.

class AppbarDemo extends StatelessWidget {
  const AppbarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      // AppBar de demo con badge de la carpeta catalog/widgets
      appBar: AppBar(
        title: Text(l10n.cuidemJunts),
        centerTitle: true,
        actions: [widget_badge_demo(10, Icons.notifications, onPressed: () {})],
      ),
    );
  }
}
