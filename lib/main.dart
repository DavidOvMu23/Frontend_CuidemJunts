import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/catalog/catalog_page.dart';

void main() {
  runApp(const CuidemJuntsApp());
}

class CuidemJuntsApp extends StatelessWidget {
  const CuidemJuntsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CatalogPage();
  }
}
