import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/api_service.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/supervisor_shell_page.dart';
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
      final loginResponse = await authService.login(correo, contrasena);

      // Guardar sesión con provider
      await ref
          .read(authProvider.notifier)
          .login(
            token: loginResponse.token,
            id: loginResponse.trabajador.id,
            correo: loginResponse.trabajador.correo,
            nombre: loginResponse.trabajador.nombre,
            rol: loginResponse.trabajador.rol,
            nia: loginResponse.trabajador.nia,
            grupoId: loginResponse.trabajador.grupoId,
          );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SupervisorShellPage()),
      );
    } on LoginException catch (e) {
      if (!mounted) return;
      final message = switch (e.type) {
        LoginErrorType.unauthorized => l10n.loginError,
        LoginErrorType.forbidden    => l10n.loginForbidden,
        LoginErrorType.serverError  => l10n.serverUnavailable,
        LoginErrorType.noConnection => l10n.loginNoConnection,
        LoginErrorType.timeout      => l10n.loginTimeout,
        LoginErrorType.unknown      => l10n.loginError,
      };
      general_snackbar_error(context, message, 5);
    } catch (e) {
      if (!mounted) return;
      general_snackbar_error(context, l10n.loginError, 3);
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.background,
              theme.colorScheme.primary.withOpacity(0.06),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              left: -80,
              top: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -60,
              bottom: -80,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Language button
            Positioned(
              top: 30,
              right: 0,
              child: login_iconbutton(
                Icons.language,
                onPressed: () {
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

            // Main content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isDesktop ? 1100 : 560),
                  child: isDesktop
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo y nombre centrados encima de la card
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/Logo_CuidemJunts.png',
                                  height: 140,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.welcome,
                                  style: theme.textTheme.headlineLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),

                            const SizedBox(height: 28),

                            // Card centrada en pantalla
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 480,
                                ),
                                child: Material(
                                  borderRadius: BorderRadius.circular(24),
                                  elevation: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.all(28.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        general_textfield(
                                          'Correo Electrónico',
                                          false,
                                          icono: Icons.email,
                                          controller: correoController,
                                        ),
                                        const SizedBox(height: 16),
                                        general_textfield(
                                          'Contraseña',
                                          true,
                                          icono: Icons.lock,
                                          controller: contrasenaController,
                                        ),
                                        const SizedBox(height: 22),
                                        isLoading
                                            ? const SizedBox(
                                                width: 48,
                                                height: 48,
                                                child:
                                                    CircularProgressIndicator(),
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
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/Logo_CuidemJunts.png',
                              height: 120,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.welcome,
                              style: theme.textTheme.headlineLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            Material(
                              borderRadius: BorderRadius.circular(30),
                              elevation: 6,
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    general_textfield(
                                      'Correo Electrónico',
                                      false,
                                      icono: Icons.email,
                                      controller: correoController,
                                    ),
                                    const SizedBox(height: 16),
                                    general_textfield(
                                      'Contraseña',
                                      true,
                                      icono: Icons.lock,
                                      controller: contrasenaController,
                                    ),
                                    const SizedBox(height: 22),
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
            ),
          ],
        ),
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
