import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/login_widgets.dart';

// Página de inicio de sesión
class LoginPage extends StatelessWidget {
  const LoginPage({super.key, required this.onToggleTheme});

  // Callback para cambiar el tema
  final void Function(bool) onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Construye la interfaz de usuario
    return Scaffold(
      // Usamos un Stack para poder posicionar elementos libremente (como el icono arriba a la derecha)
      body: Stack(
        children: [
          // Icono de idioma
          Positioned(
            top: 0, // separación desde arriba
            right: 0, // separación desde la derecha)
            //-------- BOTÓN DE SELECCIÓN DE IDIOMAS --------
            child: login_iconbutton(
              Icons.language,

              onPressed: () {
                // Mostramos un bottom sheet simple al pulsar el idioma
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(16.0),

                    //almacenamos los idiomas en una columna
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //-------- TEXTO DE SELECCIÓN DE IDIOMA --------
                        const Text(
                          'Selecciona un idioma:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),

                        //-------- LISTA DE IDIOMAS --------
                        login_listile_demo(
                          texto: "Español",
                          onTap: () {
                            Navigator.pop(context);
                            // Aquí iría la lógica para cambiar el idioma a catalán
                          },
                        ),
                        login_listile_demo(
                          texto: "Català",
                          onTap: () {
                            Navigator.pop(context);
                            // Aquí iría la lógica para cambiar el idioma a catalán
                          },
                        ),
                        login_listile_demo(
                          texto: "English",
                          onTap: () {
                            Navigator.pop(context);
                            // Aquí iría la lógica para cambiar el idioma a catalán
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Cuerpo centrado con scroll
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),

              // Columna principal
              child: Column(
                // Centramos los elementos en el eje principal
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,

                // Elementos de la columna
                children: [
                  // Logo de la app
                  Image.asset(
                    'assets/images/Logo_CuidemJunts.png',
                    height: 120,
                  ),
                  const SizedBox(height: 16),

                  // Título de bienvenida
                  Text(
                    "Bienvenidos a CuidemJunts",
                    style: theme.textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Surface del formulario de login
                  Material(
                    borderRadius: BorderRadius.circular(16),

                    child: Padding(
                      padding: const EdgeInsets.all(24.0),

                      // Columna con los campos de formulario
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,

                        // Elementos del formulario
                        children: [
                          //Correo electrónico
                          login_textfield(
                            "Correo electrónico",
                            false,
                            icono: Icons.person,
                          ),
                          const SizedBox(height: 16),

                          // Contraseña
                          login_textfield(
                            "Contraseña",
                            true,
                            icono: Icons.lock,
                          ),
                          const SizedBox(height: 22),

                          // Botón de inicio de sesión
                          login_filledbutton(
                            "Iniciar Sesión",
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HomePage(onToggleTheme: onToggleTheme),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),

                          // Recuperar contraseña
                          login_textbutton(
                            "¿Has olvidado tu contraseña?",
                            onPressed: () {
                              login_snackbar(
                                context,
                                "Habla con un supervisor para recuperar tu contraseña.",
                                10,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
