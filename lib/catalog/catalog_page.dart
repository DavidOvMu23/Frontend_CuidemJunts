import 'package:flutter/material.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Catálogo de componentes',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}
