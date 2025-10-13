import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';

class ContainersDemo extends StatelessWidget {
  const ContainersDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Demo: Containers')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            //botón para mostrar el AlertDialog
            FilledButton(
              onPressed: () {
                // Al presionar el botón, se muestra el AlertDialog
                showDialog<String>(
                  context: context,

                  //el builder define el contenido del AlertDialog
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Título del diálogo'),
                    content: const Text('Descripción o mensaje del diálogo.'),
                    actions: <Widget>[
                      // Acciones del diálogo
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('Aceptar'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Abre el alert dialog'),
            ),

            //card
            const Card(
              margin: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 300,
                height: 100,
                child: Text('Soy una card'),
              ),
            ),

            //Divider
            const Divider(),

            //ListTitle
            const ListTile(
              title: Text('Opción1'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            //Divider
            const Divider(),
            const ListTile(
              title: Text('Opción2'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            //Divider
            const Divider(),
          ],
        ),
      ),
    );
  }
}
