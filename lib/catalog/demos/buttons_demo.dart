import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widgets_buttons_demo.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widgets_communications_demo.dart';

// -------- WIDGET PRINCIPAL --------
class ButtonsDemo extends StatelessWidget {
  const ButtonsDemo({super.key});

  // -------- CONSTRUCCIÓN DE LA INTERFAZ --------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo: Buttons')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            widget_filledbutton_demo(
              'Filled Button',
              onPressed: () {
                widget_snackbar_demo(context, "Click en Filled Button", 2);
              },
            ),
            const SizedBox(height: 24),
            widget_textbutton_demo(
              "Text Button",
              onPressed: () {
                widget_snackbar_demo(context, "Click en Text Button", 2);
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                widget_iconbutton_demo(
                  Icons.favorite,
                  context: context,
                  onPressed: () {
                    widget_snackbar_demo(context, "Click en Icon Button", 2);
                  },
                ),
                widget_iconbutton_demo(
                  Icons.delete,
                  context: context,
                  onPressed: () {
                    widget_snackbar_demo(context, "Click en Icon Button", 2);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            widget_floatingbutton_demo(
              Icons.add,
              onPressed: () {
                widget_snackbar_demo(context, "Click en FAB", 2);
              },
            ),
          ],
        ),
      ),
    );
  }
}
