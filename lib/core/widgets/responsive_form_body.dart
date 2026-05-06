import 'package:flutter/material.dart';

class ResponsiveFormBody extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget form; // inner Form widget (may contain its own scroll)

  const ResponsiveFormBody({super.key, required this.title, this.subtitle, required this.form});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final horizontalPadding = isDesktop ? 16.0 : 12.0;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 27)),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 20),
            Expanded(
              child: Material(
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: form,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
