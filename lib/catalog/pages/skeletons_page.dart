import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/widgets/loading_skeleton.dart';

class CatalogSkeletonsPage extends StatelessWidget {
  const CatalogSkeletonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skeletons')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(context, 'AppSkeletonBox'),
            const AppSkeletonBox(height: 20, width: 180),
            const SizedBox(height: 8),
            const AppSkeletonBox(height: 14, width: 120),
            const SizedBox(height: 24),
            _label(context, 'AppSkeletonCard'),
            const AppSkeletonCard(),
            const SizedBox(height: 24),
            _label(context, 'AppSkeletonList (3 items)'),
            const SizedBox(
              height: 450,
              child: AppSkeletonList(count: 3),
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
