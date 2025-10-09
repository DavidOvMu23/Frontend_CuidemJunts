import 'package:flutter/material.dart';
import 'demos/text_fields_demo.dart';
import 'demos/buttons_demo.dart';
import 'demos/communication_demo.dart';
import 'demos/containers_demo.dart';

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
            title: Text('Text Fields'),
            trailing: Icon(Icons.arrow_forward_ios),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TextFieldsDemo()),
              );
            },
          ),
          Divider(height: 1),
          ListTile(
            title: Text('Communication'),
            trailing: Icon(Icons.arrow_forward_ios),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CommunicationDemo()),
              );
            },
          ),
          Divider(height: 1),
          ListTile(
            title: Text('Containers'),
            trailing: Icon(Icons.arrow_forward_ios),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContainersDemo()),
              );
            },
          ),
        ],
      ),
    );
  }
}
