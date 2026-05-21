// Librería principal de Flutter para construir la interfaz visual.
import 'package:flutter/material.dart';
// Riverpod permite leer y escribir datos globales de la app (como el usuario logueado).
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Servicio que hace las peticiones de autenticación al servidor (backend).
import 'package:frontend_cuidemjunts/features/auth/data/datasources/api_service.dart';
// Widgets reutilizables de la app (botones, campos de texto, snackbars…).
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
// Sistema de traducciones de la app (español, catalán, inglés).
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
// Provider que recuerda el idioma actualmente seleccionado.
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/locale_provider.dart';
// Provider que guarda el estado del usuario autenticado (token, nombre, rol…).
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';

// -------- PANTALLA DE INICIO DE SESIÓN --------
// Esta es la primera pantalla que ve el usuario al abrir la app.
// Muestra el logo, un campo de correo, uno de contraseña y un botón de entrar.
// Usa Riverpod (ConsumerStatefulWidget) para poder guardar el usuario en el estado global.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

// -------- ESTADO INTERNO DE LA PANTALLA DE LOGIN --------
// Aquí viven los datos que cambian mientras el usuario interactúa con esta pantalla.
class _LoginPageState extends ConsumerState<LoginPage> {
  // Controladores: capturan el texto que escribe el usuario en cada campo.
  final TextEditingController correoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  // Servicio para enviar las credenciales al servidor y obtener el token JWT.
  late AuthService authService;

  // Indica si estamos esperando respuesta del servidor (muestra un indicador de carga).
  bool isLoading = false;

  // -------- INICIALIZACIÓN --------
  // Se ejecuta una sola vez al crear la pantalla.
  // Aquí preparamos el servicio que habla con el backend.
  @override
  void initState() {
    super.initState();
    // Apuntamos al servidor local en el puerto 3000 (donde corre el backend NestJS).
    authService = AuthService(baseUrl: 'http://localhost:3000');
  }

  // -------- FUNCIÓN PRINCIPAL: HACER LOGIN --------
  // Se llama cuando el usuario pulsa el botón "Entrar".
  // Valida los campos, llama al backend y, si todo va bien, navega a la app.
  Future<void> hacerLogin() async {
    // Obtenemos los textos de traducción según el idioma activo.
    final l10n = AppLocalizations.of(context)!;

    // Leemos lo que escribió el usuario, quitando espacios al principio y al final.
    final correo = correoController.text.trim();
    final contrasena = contrasenaController.text.trim();

    // Si algún campo está vacío, mostramos un aviso y paramos aquí.
    if (correo.isEmpty || contrasena.isEmpty) {
      general_snackbar(context, l10n.fillAllFields, 2);
      return;
    }

    // Activamos el indicador de carga para que el usuario sepa que estamos procesando.
    setState(() {
      isLoading = true;
    });

    try {
      // -------- LLAMADA AL BACKEND: AUTENTICACIÓN --------
      final loginResponse = await authService.login(correo, contrasena);

      // -------- GUARDAR SESIÓN EN RIVERPOD --------
      // Al cambiar isAuthenticated a true, _AuthGate en app.dart se encarga
      // automáticamente de navegar a SupervisorShellPage. No hace falta
      // llamar a Navigator aquí — hacerlo causaría una doble navegación.
      await ref.read(authProvider.notifier).login(
        token: loginResponse.token,
        id: loginResponse.trabajador.id,
        correo: loginResponse.trabajador.correo,
        nombre: loginResponse.trabajador.nombre,
        rol: loginResponse.trabajador.rol,
        nia: loginResponse.trabajador.nia,
        grupoId: loginResponse.trabajador.grupoId,
      );
      // El widget será reemplazado por _AuthGate; no tocamos isLoading aquí.

    // -------- MANEJO DE ERRORES DE LOGIN --------
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
      if (mounted) setState(() { isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      general_snackbar_error(context, l10n.loginError, 3);
      if (mounted) setState(() { isLoading = false; });
    }
  }

  // -------- CONSTRUCCIÓN DE LA PANTALLA --------
  // Flutter llama a build() cada vez que algo cambia para redibujar la pantalla.
  @override
  Widget build(BuildContext context) {
    // Textos en el idioma actual del usuario.
    final l10n = AppLocalizations.of(context)!;
    // Colores y estilos del tema activo (claro u oscuro).
    final theme = Theme.of(context);
    // Ancho de la pantalla en píxeles, para adaptar el diseño al dispositivo.
    final width = MediaQuery.of(context).size.width;
    // Si la pantalla es muy ancha (escritorio/tablet grande), usamos un layout diferente.
    final isDesktop = width >= 900;

    return Scaffold(
      // -------- FONDO CON DEGRADADO --------
      // El fondo tiene un suave degradado desde el color base hasta el color primario,
      // para dar un aspecto más moderno que un fondo liso.
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.scaffoldBackgroundColor,
              theme.colorScheme.primary.withValues(alpha: 0.06),
            ],
          ),
        ),
        child: Stack(
          children: [
            // -------- CÍRCULO DECORATIVO SUPERIOR IZQUIERDO --------
            // Es solo un adorno visual, no tiene función interactiva.
            // Está parcialmente fuera de la pantalla (-80, -60) para quedar cortado.
            Positioned(
              left: -80,
              top: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // -------- CÍRCULO DECORATIVO INFERIOR DERECHO --------
            // Igual que el anterior, solo decorativo.
            Positioned(
              right: -60,
              bottom: -80,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // -------- BOTÓN DE SELECCIÓN DE IDIOMA --------
            // Aparece en la esquina superior derecha. Al pulsarlo se abre un menú
            // con los tres idiomas disponibles: español, catalán e inglés.
            Positioned(
              top: 30,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.language),
                onPressed: () {
                  // Mostramos un panel emergente desde la parte inferior de la pantalla.
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título del panel de selección de idioma.
                          Text(
                            l10n.selectLanguage,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Opción: Español.
                          ListTile(
                            title: Text(l10n.languageSpanish),
                            onTap: () {
                              Navigator.pop(context); // Cierra el panel.
                              ref.read(localeProvider.notifier).setSpanish();
                            },
                          ),
                          // Opción: Catalán.
                          ListTile(
                            title: Text(l10n.languageCatalan),
                            onTap: () {
                              Navigator.pop(context);
                              ref.read(localeProvider.notifier).setCatalan();
                            },
                          ),
                          // Opción: Inglés.
                          ListTile(
                            title: Text(l10n.languageEnglish),
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

            // -------- CONTENIDO PRINCIPAL CENTRADO --------
            // El formulario de login está centrado en pantalla y se puede desplazar
            // verticalmente por si el teclado lo tapa en móvil.
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  // En escritorio limitamos el ancho para que no se extienda demasiado.
                  constraints: BoxConstraints(maxWidth: isDesktop ? 1100 : 560),
                  // -------- DISEÑO SEGÚN TAMAÑO DE PANTALLA --------
                  // En escritorio: logo grande encima + card de formulario centrada.
                  // En móvil: todo apilado verticalmente.
                  child: isDesktop
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo y nombre de la app centrados encima del formulario.
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Logo de la app cargado desde la carpeta de assets.
                                Image.asset(
                                  'assets/images/Logo_CuidemJunts.png',
                                  height: 140,
                                ),
                                const SizedBox(height: 12),
                                // Texto de bienvenida (traducido según el idioma activo).
                                Text(
                                  l10n.welcome,
                                  style: theme.textTheme.headlineLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),

                            const SizedBox(height: 28),

                            // -------- CARD DEL FORMULARIO (ESCRITORIO) --------
                            // Tarjeta con bordes redondeados y sombra que contiene los campos.
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
                                        // Campo de texto para escribir el correo electrónico.
                                        general_textfield(
                                          'Correo Electrónico',
                                          false, // false = no ocultar el texto (no es contraseña)
                                          icono: Icons.email,
                                          controller: correoController,
                                        ),
                                        const SizedBox(height: 16),
                                        // Campo de texto para escribir la contraseña (texto oculto).
                                        general_textfield(
                                          'Contraseña',
                                          true, // true = ocultar el texto (es contraseña)
                                          icono: Icons.lock,
                                          controller: contrasenaController,
                                        ),
                                        const SizedBox(height: 22),
                                        // Si estamos cargando, mostramos un círculo giratorio.
                                        // Si no, mostramos el botón de "Entrar".
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
                      // -------- DISEÑO MÓVIL --------
                      // Logo, bienvenida y formulario apilados uno encima de otro.
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Logo de la app (más pequeño que en escritorio).
                            Image.asset(
                              'assets/images/Logo_CuidemJunts.png',
                              height: 120,
                            ),
                            const SizedBox(height: 16),
                            // Texto de bienvenida.
                            Text(
                              l10n.welcome,
                              style: theme.textTheme.headlineLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            // -------- CARD DEL FORMULARIO (MÓVIL) --------
                            Material(
                              borderRadius: BorderRadius.circular(30),
                              elevation: 6,
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Campo de correo electrónico.
                                    general_textfield(
                                      'Correo Electrónico',
                                      false,
                                      icono: Icons.email,
                                      controller: correoController,
                                    ),
                                    const SizedBox(height: 16),
                                    // Campo de contraseña (texto oculto).
                                    general_textfield(
                                      'Contraseña',
                                      true,
                                      icono: Icons.lock,
                                      controller: contrasenaController,
                                    ),
                                    const SizedBox(height: 22),
                                    // Círculo de carga o botón de entrar, según el estado.
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

  // -------- LIMPIEZA AL CERRAR LA PANTALLA --------
  // Cuando Flutter destruye esta pantalla, liberamos la memoria de los controladores
  // de texto para evitar fugas de memoria (memory leaks).
  @override
  void dispose() {
    correoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }
}
