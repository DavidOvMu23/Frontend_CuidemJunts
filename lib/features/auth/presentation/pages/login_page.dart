import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/login_widgets.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

// Página de inicio de sesión
class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
    required this.onToggleTheme,
    required this.onChangeLocale,
  });

  // Callback para cambiar el tema
  final void Function(bool) onToggleTheme;
  final void Function(Locale) onChangeLocale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            child: general_iconbutton(
              Icons.language,

              onPressed: () {
                // Mostramos un bottom sheet simple al pulsar el idioma(esto lo hemos sacado de tu repo de GitHub de internacionalizacion)
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
                        Text(
                          l10n.selectLanguage,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),

                        //-------- LISTA DE IDIOMAS --------
                        login_listile_demo(
                          texto: l10n.languageSpanish,
                          onTap: () {
                            Navigator.pop(context);
                            onChangeLocale(const Locale('es'));
                          },
                        ),
                        login_listile_demo(
                          texto: l10n.languageCatalan,
                          onTap: () {
                            Navigator.pop(context);
                            onChangeLocale(const Locale('ca'));
                          },
                        ),
                        login_listile_demo(
                          texto: l10n.languageEnglish,
                          onTap: () {
                            Navigator.pop(context);
                            onChangeLocale(const Locale('en'));
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
                    l10n.welcome,
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
                          general_textfield(
                            l10n.email,
                            false,
                            icono: Icons.person,
                          ),
                          const SizedBox(height: 16),

                          // Contraseña
                          general_textfield(
                            l10n.password,
                            true,
                            icono: Icons.lock,
                          ),
                          const SizedBox(height: 22),

                          // Botón de inicio de sesión
                          general_filledbutton(
                            l10n.loginButton,
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomePage(
                                    onToggleTheme: onToggleTheme,
                                    onChangeLocale: onChangeLocale,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),

                          // Recuperar contraseña
                          general_textbutton(
                            l10n.forgotPassword,
                            onPressed: () {
                              general_snackbar(
                                context,
                                l10n.forgotPasswordSnackbar,
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
