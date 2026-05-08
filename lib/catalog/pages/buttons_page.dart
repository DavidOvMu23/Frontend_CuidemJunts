import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';

class CatalogButtonsPage extends StatelessWidget {
  const CatalogButtonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buttons')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(context, 'general_filledbutton'),
            general_filledbutton(
              'Filled Button',
              onPressed: () => general_snackbar(context, 'Filled Button pressed', 2),
            ),
            const SizedBox(height: 24),
            _label(context, 'general_deletebutton'),
            general_deletebutton(
              context,
              'Delete Button',
              onPressed: () => general_snackbar(context, 'Delete pressed', 2),
            ),
            const SizedBox(height: 24),
            _label(context, 'general_floatingbutton'),
            general_floatingbutton(
              Icons.add,
              onPressed: () => general_snackbar(context, 'FAB pressed', 2),
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
