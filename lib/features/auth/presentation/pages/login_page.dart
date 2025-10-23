import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_page.dart';

// Página de inicio de sesión
class LoginPage extends StatelessWidget {
  const LoginPage({super.key, required this.onToggleTheme});

  final void Function(bool) onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Construye la interfaz de usuario
    return Scaffold(
      // Cuerpo centrado con scroll
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),

          // Columna principal
          child: Column(
            //centrado
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,

            // Elementos de la columna
            children: [
              // Logo de la app
              Image.asset('assets/images/Logo_CuidemJunts.png', height: 120),
              const SizedBox(height: 16),

              // Título de bienvenida
              Text(
                'Bienvenido a CuidemJunts',
                style: theme.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Surface del formulario de login
              Material(
                borderRadius: BorderRadius.circular(16),

                child: Padding(
                  padding: const EdgeInsets.all(24.0),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,

                    // Elementos del formulario
                    children: [
                      //Correo electrónico
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Correo Electrónico',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contraseña
                      TextField(
                        obscureText: true, // Oculta el texto
                        decoration: InputDecoration(
                          hintText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Botón de inicio de sesión
                      FilledButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HomePage(onToggleTheme: onToggleTheme),
                            ),
                          );
                        },
                        child: const Text('Iniciar Sesión'),
                      ),

                      const SizedBox(height: 12),

                      // Recuperar contraseña
                      TextButton(
                        onPressed: () {
                          // Cuando pulsamos, se muestra el mensaje
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Habla con un supervisor para recuperar tu contraseña.',
                              ),
                              // El mensaje dura 2 segundos
                              duration: Duration(seconds: 10),
                            ),
                          );
                        },
                        child: const Text('¿Has olvidado tu contraseña?'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
