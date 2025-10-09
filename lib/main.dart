import 'package:flutter/material.dart';
import 'app/theme/app_theme.dart';
import 'catalog/catalog_page.dart';

void main() {
  runApp(const CuidemJuntsApp());
}

class CuidemJuntsApp extends StatefulWidget {
  const CuidemJuntsApp({super.key});

  @override
  State<CuidemJuntsApp> createState() => _CuidemJuntsAppState();
}

class _CuidemJuntsAppState extends State<CuidemJuntsApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuidem Junts',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cuidem Junts'),
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => setState(() => isDark = !isDark),
            ),
          ],
        ),
        body: const CatalogPage(),
      ),
    );
  }
}
