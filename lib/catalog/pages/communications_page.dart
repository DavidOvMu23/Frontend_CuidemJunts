import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';

class CatalogCommunicationsPage extends StatelessWidget {
  const CatalogCommunicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Communications')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(context, 'general_snackbar'),
            general_filledbutton(
              'Show Snackbar',
              onPressed: () => general_snackbar(context, 'Operation successful', 3),
            ),
            const SizedBox(height: 24),
            _label(context, 'general_snackbar_error'),
            general_filledbutton(
              'Show Error Snackbar',
              onPressed: () =>
                  general_snackbar_error(context, 'Something went wrong', 3),
            ),
            const SizedBox(height: 24),
            _label(context, 'showConfirmDialog'),
            general_filledbutton(
              'Show Confirm Dialog',
              onPressed: () => showConfirmDialog(
                context,
                title: 'Confirm action',
                content: 'Are you sure you want to proceed?',
                confirmText: 'Confirm',
                cancelText: 'Cancel',
                onConfirm: () =>
                    general_snackbar(context, 'Confirmed!', 2),
              ),
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
