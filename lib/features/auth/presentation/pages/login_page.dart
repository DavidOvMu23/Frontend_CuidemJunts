import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/data/service/api_service.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/supervisor/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/login_widgets.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

// -------- PANTALLA DE INICIO DE SESIÓN --------
// Aquí pedimos email + contraseña y dejamos escoger idioma/tema.
class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.onToggleTheme,
    required this.onChangeLocale,
  });

  // Callback que cambia el tema de la app.
  // Si es true, activa modo oscuro; si es false, modo claro.
  // Se utiliza para que el cambio de tema afect  e a toda la app.
  final void Function(bool) onToggleTheme;

  // Callback que cambia el idioma de la app.
  // Se utiliza para que el cambio de idioma afecte a toda la app.
  final void Function(Locale) onChangeLocale;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  late AuthService authService;

  @override
  void initState() {
    super.initState();
    authService = AuthService(baseUrl: 'http://localhost:3000');
  }

  Future<void> hacerLogin() async {
    final correo = correoController.text.trim();
    final contrasena = contrasenaController.text.trim();

    if (correo.isEmpty || contrasena.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rellena todos los campos')));
      return;
    }

    try {
      await authService.login(correo, contrasena);
      // TODO: guardar token
      // ejemplo:
      // await storage.write(key: 'token', value: token);

      // navegar:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeSupervisorPage(
            onToggleTheme: widget.onToggleTheme,
            onChangeLocale: widget.onChangeLocale,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Me guardo los textos traducidos y el tema actual.
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // -------- ESTRUCTURA PRINCIPAL --------
    return Scaffold(
      // -------- LAYOUT GENERAL --------
      // Stack para colocar el botón de idioma encima del contenido.
      body: Stack(
        children: [
          // -------- BOTÓN DEL IDIOMA (ESQUINA SUPERIOR) --------
          Positioned(
            top: 30,
            right: 0,
            child: login_iconbutton(
              Icons.language,
              onPressed: () {
                // Abro un panel desde abajo con todos los idiomas.
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.selectLanguage,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Cada opción cambia el idioma y cierro el panel.
                        login_listile_demo(
                          texto: l10n.languageSpanish,
                          onTap: () {
                            Navigator.pop(context);
                            widget.onChangeLocale(const Locale('es'));
                          },
                        ),
                        login_listile_demo(
                          texto: l10n.languageCatalan,
                          onTap: () {
                            Navigator.pop(context);
                            widget.onChangeLocale(const Locale('ca'));
                          },
                        ),
                        login_listile_demo(
                          texto: l10n.languageEnglish,
                          onTap: () {
                            Navigator.pop(context);
                            widget.onChangeLocale(const Locale('en'));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // -------- CUERPO CON EL FORMULARIO --------
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // -------- LOGO --------
                  // Imagen principal de la app alineada al centro.
                  Image.asset(
                    'assets/images/Logo_CuidemJunts.png',
                    height: 120,
                  ),
                  const SizedBox(height: 16),
                  // -------- BIENVENIDA --------
                  // Texto que se traduce solo usando l10n.
                  Text(
                    l10n.welcome,
                    style: theme.textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // -------- TARJETA DEL FORMULARIO --------
                  // Material con borde redondeado que contiene los campos.
                  Material(
                    borderRadius: BorderRadius.circular(30),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // -------- CAMPO: EMAIL --------
                          general_textfield(
                            l10n.email,
                            false,
                            icono: Icons.person,
                            controller: correoController,
                          ),
                          const SizedBox(height: 16),
                          // -------- CAMPO: CONTRASEÑA --------
                          general_textfield(
                            l10n.password,
                            true,
                            icono: Icons.lock,
                            controller: contrasenaController,
                          ),
                          const SizedBox(height: 22),
                          // -------- BOTÓN DE ENTRAR --------
                          general_filledbutton(
                            l10n.loginButton,
                            onPressed: () {
                              hacerLogin();
                            },
                          ),
                          const SizedBox(height: 12),
                          // -------- OLVIDÉ CONTRASEÑA --------
                          // Botón plano que solo lanza un SnackBar por ahora.
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
