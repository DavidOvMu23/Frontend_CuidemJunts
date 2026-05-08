import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';

class CatalogListTilesPage extends StatelessWidget {
  const CatalogListTilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List Tiles')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(context, 'general_listtile (unselected)'),
            general_listtile(
              context: context,
              icon: Icons.phone,
              texto: 'Calls',
            ),
            const SizedBox(height: 8),
            _label(context, 'general_listtile (selected)'),
            general_listtile(
              context: context,
              icon: Icons.people,
              texto: 'Users',
              selected: true,
            ),
            const SizedBox(height: 24),
            _label(context, 'general_listtile_logout'),
            general_listtile_logout(
              context: context,
              icon: Icons.logout,
              texto: 'Log out',
              onTap: () => general_snackbar(context, 'Log out tapped', 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String name) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(name, style: Theme.of(context).textTheme.labelLarge),
      );
}
