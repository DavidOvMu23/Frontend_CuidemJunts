import 'package:flutter/material.dart';

class ContainersDemo extends StatelessWidget {
  const ContainersDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // La parte de arriba de la app (barra con el título)
      appBar: AppBar(title: const Text('Demo: Containers')),

      // El cuerpo principal de la pantalla
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        // Usamos material como surface(el fondo azul)
        child: Material(
          borderRadius: BorderRadius.circular(16), //Bordes redondeados

          child: Padding(
            padding: const EdgeInsets.all(16.0),

            //Column coloca los elementos uno debajo de otro
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // que se ajuste al contenido
              children: [
                const Text(
                  'Soy una Surface (panel principal).', //así enseñamos y diferencuamos mejor el surface
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Una Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0, //quitar sombra predeterminada
                  // Aquí van los parametros de la Card
                  child: const SizedBox(
                    width: double.infinity, // ocupa todo el ancho disponible
                    height: 100, // altura fija (solo para el ejemplo)
                    child: Center(
                      child: Text(
                        'Soy una Card (más oscura que la Surface).',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                // Espacio entre la card y el siguiente elemento
                const SizedBox(height: 20),

                // Botón que abre un diálogo sencillo
                FilledButton(
                  child: const Text('Abrir AlertDialog'),

                  //al pulsar el botón mostramos un AlertDialog
                  onPressed: () {
                    showDialog(
                      //parametros del diálogo
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Título del diálogo'),
                        content: const Text(
                          'Descripción o mensaje del diálogo.',
                        ),
                        //creamos dos botones de acción dentro del diálogo
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Aceptar'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // lista simple
                const ListTile(
                  title: Text('ListTile1'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                const Divider(),
                const ListTile(
                  title: Text('ListTile2'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
