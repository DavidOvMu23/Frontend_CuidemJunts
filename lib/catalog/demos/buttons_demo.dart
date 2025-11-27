import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widgets_buttons_demo.dart';
import 'package:frontend_cuidemjunts/catalog/widgets/widgets_communications_demo.dart';

// -------- DEMO: BUTTONS --------
// Muestra los diferentes tipos de botones disponibles.
class ButtonsDemo extends StatelessWidget {
  const ButtonsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con el título del demo
      appBar: AppBar(title: const Text('Demo: Buttons')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),

        // Columna en la que se van a ir mostrando los widgets
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Alineación vertical
          crossAxisAlignment: CrossAxisAlignment.start, // Alineación horizontal
          children: [
            const SizedBox(height: 10),
            //llamamos a la función widget_filledbutton_demo
            widget_filledbutton_demo(
              'Filled Button',
              onPressed: () {
                widget_snackbar_demo(context, "Click en Filled Button", 2);
              },
            ),
            const SizedBox(height: 24),
            //llamamos a la función widget_textbutton_demo
            widget_textbutton_demo(
              "Text Button",
              onPressed: () {
                widget_snackbar_demo(context, "Click en Text Button", 2);
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.start, // Alineación horizontal
              children: [
                //llamamos a la función widget_iconbutton_demo
                widget_iconbutton_demo(
                  Icons.favorite,
                  context: context,
                  onPressed: () {
                    widget_snackbar_demo(context, "Click en Icon Button", 2);
                  },
                ),
                //llamamos a la función widget_iconbutton_demo
                widget_iconbutton_demo(
                  Icons.delete,
                  context: context,
                  onPressed: () {
                    //llamamos a la función widget_snackbar_demo
                    widget_snackbar_demo(context, "Click en Icon Button", 2);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            //llamamos a la función widget_floatingbutton_demo
            widget_floatingbutton_demo(
              Icons.add,
              onPressed: () {
                //llamamos a la función widget_snackbar_demo
                widget_snackbar_demo(context, "Click en FAB", 2);
              },
            ),
          ],
        ),
      ),
    );
  }
}
