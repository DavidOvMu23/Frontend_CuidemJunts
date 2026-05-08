import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';

class CatalogTextFieldsPage extends StatelessWidget {
  const CatalogTextFieldsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Fields')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(context, 'general_textfield (with icon)'),
            general_textfield('Hint text', false, icono: Icons.person),
            const SizedBox(height: 24),
            _label(context, 'general_textfield (obscure)'),
            general_textfield('Password', true, icono: Icons.lock),
            const SizedBox(height: 24),
            _label(context, 'general_textfield (multiline)'),
            general_textfield('Comments', false, maxLines: 4),
            const SizedBox(height: 24),
            _label(context, 'general_textfield_NoICON (with validator)'),
            Form(
              child: general_textfield_NoICON(
                'Required field',
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 24),
            _label(context, 'general_busqueda_textfield'),
            general_busqueda_textfield('Search…', icono: Icons.search),
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
