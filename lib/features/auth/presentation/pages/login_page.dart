import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/api_service.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/login_widgets.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/locale_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';

// -------- PANTALLA DE INICIO DE SESIÓN --------
// Aquí pedimos email + contraseña y dejamos escoger idioma/tema.
// Ahora usa Riverpod para acceder al estado global sin necesidad de callbacks.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  late AuthService authService;

  @override
  void initState() {
    super.initState();
    authService = AuthService(baseUrl: 'http://cuidemjunts.zapto.org:3000');
  }

  Future<void> hacerLogin() async {
    final correo = correoController.text.trim();
    final contrasena = contrasenaController.text.trim();

    if (correo.isEmpty || contrasena.isEmpty) {
      general_snackbar(context, 'Rellena todos los campos', 2);
      return;
    }

    try {
      // -------- HACER LOGIN EN EL BACKEND --------
      // Enviamos las credenciales al servidor y esperamos la respuesta.
      final response = await authService.login(correo, contrasena);

      // -------- GUARDAR LA SESIÓN CON RIVERPOD --------
      // Extraemos el token de la respuesta del backend
      final token = response['token'] ?? '';

      // Convertimos los datos del usuario a JSON para guardarlos
      final userDataJson = jsonEncode(response);

      // Guardamos la sesión usando el provider de autenticación
      await ref
          .read(authProvider.notifier)
          .login(token: token, email: correo, userData: userDataJson);

      // Evitar usar BuildContext si el State fue desmontado durante el await
      if (!mounted) return;

      // -------- NAVEGAR A LA PANTALLA PRINCIPAL --------
      // Como el login fue exitoso, llevamos al usuario a su pantalla principal.
      // Ya no necesitamos pasar callbacks ni servicios, Riverpod se encarga.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeSupervisorPage()),
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;

      // Si el error contiene 503, es fallo del servidor
      String message = l10n.loginError;
      if (e.toString().contains('503')) {
        message = 'Servidor no disponible (503). Inténtalo más tarde.';
      } else if (e.toString().contains('Connection refused')) {
        message = 'No se pudo conectar con el servidor.';
      }

      general_snackbar_error(context, message, 3);
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

                          // -------- BOTÓN DE CONTRASEÑA OLVIDADA --------
                          general_textbutton(
                            l10n.forgotPassword,
                            onPressed: () {
                              general_snackbar(
                                context,
                                l10n.forgotPasswordSnackbar,
                                2,
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
