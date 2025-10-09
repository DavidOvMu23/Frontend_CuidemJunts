import 'package:flutter/material.dart';

class ButtonsDemo extends StatelessWidget {
  const ButtonsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo: Botones')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton(onPressed: () {}, child: const Text('Filled Button')),
            FilledButton.tonal(
              onPressed: () {},
              child: const Text('Filled Tonal'),
            ),
            TextButton(onPressed: () {}, child: const Text('Text Button')),
            IconButton(onPressed: () {}, icon: const Icon(Icons.favorite)),
            FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
