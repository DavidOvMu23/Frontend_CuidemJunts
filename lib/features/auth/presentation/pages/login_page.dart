import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/api_service.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/login_widgets.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/locale_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';

// -------- PANTALLA DE INICIO DE SESIÓN CON JWT --------
// Aquí pedimos correo y contraseña para autenticación con JWT.
// Usa Riverpod para acceder al estado global.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  late AuthService authService;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    authService = AuthService(baseUrl: 'http://localhost:3000');
  }

  Future<void> hacerLogin() async {
    final l10n = AppLocalizations.of(context)!;
    final correo = correoController.text.trim();
    final contrasena = contrasenaController.text.trim();

    if (correo.isEmpty || contrasena.isEmpty) {
      general_snackbar(context, l10n.fillAllFields, 2);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // -------- HACER LOGIN EN EL BACKEND --------
      // Enviamos correo y contraseña al servidor y esperamos el token JWT.
      final loginResponse = await authService.login(correo, contrasena);

      // -------- GUARDAR LA SESIÓN CON RIVERPOD Y PREFERENCES --------
      // Guardamos el token y los datos usando el provider de autenticación.
      await ref.read(authProvider.notifier).login(
        token: loginResponse.token,
        correo: loginResponse.trabajador.correo,
        nombre: loginResponse.trabajador.nombre,
        rol: loginResponse.trabajador.rol,
        nia: loginResponse.trabajador.nia,
        grupoId: loginResponse.trabajador.grupoId,
      );

      // Evitar usar BuildContext si el State fue desmontado durante el await
      if (!mounted) return;

      // -------- NAVEGAR A LA PANTALLA PRINCIPAL --------
      // Como el login fue exitoso, llevamos al usuario a su pantalla principal.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeSupervisorPage()),
      );
    } catch (e) {
      if (!mounted) return;

      // Manejo de errores
      String message = l10n.loginError;
      if (e.toString().contains('503')) {
        message = l10n.serverUnavailable;
      } else if (e.toString().contains('Connection refused')) {
        message = l10n.connectionRefused;
      } else if (e.toString().contains('404') ||
          e.toString().contains('no encontrado')) {
        message = 'Correo o contraseña incorrectos';
      }

      general_snackbar_error(context, message, 3);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
                            ref.read(localeProvider.notifier).setSpanish();
                          },
                        ),
                        login_listile_demo(
                          texto: l10n.languageCatalan,
                          onTap: () {
                            Navigator.pop(context);
                            ref.read(localeProvider.notifier).setCatalan();
                          },
                        ),
                        login_listile_demo(
                          texto: l10n.languageEnglish,
                          onTap: () {
                            Navigator.pop(context);
                            ref.read(localeProvider.notifier).setEnglish();
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
                  Image.asset(
                    'assets/images/Logo_CuidemJunts.png',
                    height: 120,
                  ),
                  const SizedBox(height: 16),

                  // -------- BIENVENIDA --------
                  Text(
                    l10n.welcome,
                    style: theme.textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // -------- TARJETA DEL FORMULARIO --------
                  Material(
                    borderRadius: BorderRadius.circular(30),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // -------- CAMPO: CORREO ELECTRÓNICO --------
                          general_textfield(
                            'Correo Electrónico',
                            false,
                            icono: Icons.email,
                            controller: correoController,
                          ),
                          const SizedBox(height: 16),

                          // -------- CAMPO: CONTRASEÑA --------
                          general_textfield(
                            'Contraseña',
                            true,
                            icono: Icons.lock,
                            controller: contrasenaController,
                          ),
                          const SizedBox(height: 22),

                          // -------- BOTÓN DE ENTRAR --------
                          isLoading
                              ? const SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: CircularProgressIndicator(),
                                )
                              : general_filledbutton(
                                  l10n.loginButton,
                                  onPressed: () {
                                    hacerLogin();
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

  @override
  void dispose() {
    correoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }
}
