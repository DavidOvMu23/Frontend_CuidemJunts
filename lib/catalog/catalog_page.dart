import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/catalog/demos/communication_demo.dart';
import 'demos/buttons_demo.dart';
import 'demos/text_fields_demo.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Creamos una lista de opciones para navegar en las difentes demos
      body: ListView(
        children: [
          ListTile(
            title: const Text('Buttons'),
            trailing: const Icon(Icons.arrow_forward_ios),
            //indicamos que al pulsar en esta opción del menú navege a la demo de botones
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ButtonsDemo()),
              );
            },
          ),
          Divider(height: 1),

          ListTile(
            title: const Text('Text Fields'),
            trailing: const Icon(Icons.arrow_forward_ios),
            //indicamos que al pulsar en esta opción del menú navege a la demo de botones
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TextFieldsDemo()),
              );
            },
          ),
          Divider(height: 1),

          ListTile(
            title: const Text('Communications'),
            trailing: const Icon(Icons.arrow_forward_ios),
            //indicamos que al pulsar en esta opción del menú navege a la demo de botones
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CommunicationsDemo()),
              );
            },
          ),
          Divider(height: 1),
        ],
      ),
    );
  }
}
