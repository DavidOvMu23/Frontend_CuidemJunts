import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widgets_textfields_demo.dart';

// -------- DEMO: SELECCIONES --------
class TextFieldsDemo extends StatelessWidget {
  const TextFieldsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: AppBar(title: const Text('Demo: Text Fields')),

      // Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),

        // Columna en la que mostraremos todos los textfields
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Alineación vertical
          crossAxisAlignment: CrossAxisAlignment.start, // Alineación horizontal
          children: [
            const SizedBox(height: 10),
            // TextField con icono
            widget_textfield_demo(
              "TextField with Icon",
              false,
              icono: Icons.person,
            ),
            const SizedBox(height: 24),
            // TextField sin icono
            widget_textfield_NoICON_demo("TextField No Icon"),
            const SizedBox(height: 24),
            // TextField con icono y obscure
            widget_textfield_demo("Obscure TextField", true, icono: Icons.lock),
            const SizedBox(height: 24),
            // TextField de búsqueda
            widget_busqueda_textfield_demo(
              "Search TextField",
              icono: Icons.search,
              context: context,
              onChanged: (value) {},
            ),
            const SizedBox(height: 24),
            // TextField multiline
            widget_textfield_demo("Multiline TextField", false, maxLines: 4),
          ],
        ),
      ),
    );
  }
}
