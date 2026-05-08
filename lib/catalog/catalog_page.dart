import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/theme_provider.dart';
import 'package:frontend_cuidemjunts/catalog/pages/buttons_page.dart';
import 'package:frontend_cuidemjunts/catalog/pages/textfields_page.dart';
import 'package:frontend_cuidemjunts/catalog/pages/communications_page.dart';
import 'package:frontend_cuidemjunts/catalog/pages/list_tiles_page.dart';
import 'package:frontend_cuidemjunts/catalog/pages/skeletons_page.dart';

class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sections = [
      (title: 'Buttons', page: const CatalogButtonsPage()),
      (title: 'Text Fields', page: const CatalogTextFieldsPage()),
      (title: 'Communications', page: const CatalogCommunicationsPage()),
      (title: 'List Tiles', page: const CatalogListTilesPage()),
      (title: 'Skeletons', page: const CatalogSkeletonsPage()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Catalog'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: sections.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) => ListTile(
              title: Text(sections[i].title),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => sections[i].page),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
