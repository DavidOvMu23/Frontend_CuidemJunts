import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widgets_textfields_demo.dart';

// -------- WIDGET PRINCIPAL --------
class TextFieldsDemo extends StatelessWidget {
  const TextFieldsDemo({super.key});

  // -------- CONSTRUCCIÓN DE LA INTERFAZ --------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo: Text Fields')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            widget_textfield_demo(
              "TextField with Icon",
              false,
              icono: Icons.person,
            ),
            const SizedBox(height: 24),
            widget_textfield_NoICON_demo("TextField No Icon"),
            const SizedBox(height: 24),
            widget_textfield_demo("Obscure TextField", true, icono: Icons.lock),
            const SizedBox(height: 24),
            widget_busqueda_textfield_demo(
              "Search TextField",
              icono: Icons.search,
              context: context,
              onChanged: (value) {},
            ),
            const SizedBox(height: 24),
            widget_textfield_demo("Multiline TextField", false, maxLines: 4),
          ],
        ),
      ),
    );
  }
}
