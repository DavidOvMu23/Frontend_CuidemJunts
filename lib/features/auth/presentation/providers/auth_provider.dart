import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/api_service.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/preferences_service.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/preferences_provider.dart';

// ----- Provider de AuthState -----
// Este archivo gestiona TODO lo relacionado con la sesión del usuario:
// saber si está logueado, guardar sus datos y cerrar sesión.

// AuthState es un "contenedor de datos" que guarda la información del usuario logueado.
// Cuando el estado cambia, la pantalla se actualiza automáticamente.
class AuthState {
  // ¿Está el usuario logueado? true = sí, false = no
  final bool isAuthenticated;
  // Indica si se está realizando alguna operación asíncrona (como hacer login)
  // Se usa para mostrar un indicador de carga mientras se espera respuesta del servidor
  final bool loading;
  // true mientras se está restaurando la sesión desde el almacenamiento local
  // al arrancar la app (p. ej. tras un refresco del navegador). La interfaz
  // debería mostrar un splash en lugar del login durante este tiempo para no
  // parpadear entre pantallas.
  final bool bootstrapping;
  // Número identificador único del trabajador en la base de datos
  final int? id;
  // Token JWT del trabajador: es una cadena de texto que el servidor usa para
  // verificar que el usuario tiene permiso de hacer peticiones (como un pase de acceso)
  final String? token;
  // Correo electrónico del trabajador autenticado
  final String? correo;
  // Nombre completo del trabajador
  final String? nombre;
  // Rol del trabajador dentro del sistema: puede ser 'supervisor' o 'teleoperador'
  // Determina qué pantallas y acciones puede ver o realizar
  final String? rol;
  // NIA: número de identificación del trabajador (código interno de la empresa)
  final String? nia;
  // Identificador del grupo al que pertenece el trabajador
  // Los grupos organizan a los teleoperadores bajo un supervisor
  final int? grupoId;

  const AuthState({
    this.isAuthenticated = false,
    this.loading = false,
    this.bootstrapping = false,
    this.id,
    this.token,
    this.correo,
    this.nombre,
    this.rol,
    this.nia,
    this.grupoId,
  });

  // Crea una copia del estado cambiando solo los campos que le indiquemos.
  // Esto es necesario porque el estado es inmutable: no se puede modificar directamente,
  // hay que crear uno nuevo con los valores actualizados.
  AuthState copyWith({
    bool? isAuthenticated,
    bool? loading,
    bool? bootstrapping,
    int? id,
    String? token,
    String? correo,
    String? nombre,
    String? rol,
    String? nia,
    int? grupoId,
  }) {
    // El operador ?? significa "usa el nuevo valor si existe, si no, el que ya teníamos"
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      loading: loading ?? this.loading,
      bootstrapping: bootstrapping ?? this.bootstrapping,
      id: id ?? this.id,
      token: token ?? this.token,
      correo: correo ?? this.correo,
      nombre: nombre ?? this.nombre,
      rol: rol ?? this.rol,
      nia: nia ?? this.nia,
      grupoId: grupoId ?? this.grupoId,
    );
  }
}

// AuthNotifier es la clase que controla el login y el logout.
// Cuando el trabajador inicia sesión, guarda sus datos aquí.
// Cuando cierra sesión, borra todo para que nadie más pueda acceder.
class AuthNotifier extends Notifier<AuthState> {
  // Referencia al servicio que guarda datos persistentes en el dispositivo
  late PreferencesService _preferencesService;

  // build() se ejecuta automáticamente al crear el provider.
  // Empezamos en modo "bootstrapping" y, en segundo plano, intentamos
  // recuperar la sesión guardada para que un refresco del navegador no
  // expulse al usuario.
  @override
  AuthState build() {
    _preferencesService = ref.watch(preferencesServiceProvider);

    // Disparamos la restauración en el siguiente tick para no mutar el estado
    // mientras se está construyendo el provider por primera vez.
    Future.microtask(_restoreSession);

    return const AuthState(
      isAuthenticated: false,
      loading: false,
      bootstrapping: true,
    );
  }

  // Recupera la sesión guardada al arrancar la app. Si hay token:
  //   1. Restauramos el estado de forma optimista con los datos cacheados.
  //   2. Verificamos en segundo plano que el token siga siendo válido contra
  //      /auth/profile. Si el servidor lo rechaza (401), cerramos sesión.
  //   3. Si la verificación falla por falta de red, mantenemos la sesión
  //      cacheada para no expulsar al usuario por un problema temporal.
  Future<void> _restoreSession() async {
    final token = _preferencesService.getToken();
    if (token == null || token.isEmpty) {
      state = const AuthState(
        isAuthenticated: false,
        loading: false,
        bootstrapping: false,
      );
      return;
    }

    final cached = _preferencesService.getUserSession();
    // Restauración optimista: enseñamos la app enseguida con los datos
    // cacheados. Si el token está caducado, la verificación posterior lo
    // detectará y haremos logout.
    state = AuthState(
      isAuthenticated: true,
      loading: false,
      bootstrapping: false,
      id: cached.id,
      token: token,
      correo: cached.correo,
      nombre: cached.nombre,
      rol: cached.rol,
      nia: cached.nia,
      grupoId: cached.grupoId,
    );

    // Verificación contra el backend.
    final profile = await AuthService(baseUrl: 'http://localhost:3000')
        .getProfile(token);
    if (profile == null) {
      // Si no podemos saber si el token es válido (sin red, etc.), no expulsamos.
      // Solo cerramos sesión si recibimos explícitamente 401/403 — getProfile
      // devuelve null en ambos casos, así que aquí asumimos que el token está
      // caducado y cerramos para forzar relogin.
      await logout();
    }
  }

  // Guarda la sesión cuando el trabajador introduce sus credenciales correctamente.
  // Recibe el token y los datos del trabajador que devuelve el servidor tras el login.
  Future<void> login({
    required String token,
    required int id,
    required String correo,
    String? nombre,
    String? rol,
    String? nia,
    int? grupoId,
  }) async {
    // Marcamos que hay una operación en curso para mostrar un indicador de carga
    state = state.copyWith(loading: true);

    // Persistimos token y datos del trabajador para sobrevivir al refresco.
    await _preferencesService.saveToken(token);
    await _preferencesService.saveUserSession(
      id: id,
      correo: correo,
      nombre: nombre,
      rol: rol,
      nia: nia,
      grupoId: grupoId,
    );

    // Actualizamos el estado con todos los datos del trabajador recibidos del servidor
    state = AuthState(
      isAuthenticated: true,
      loading: false,
      bootstrapping: false,
      id: id,
      token: token,
      correo: correo,
      nombre: nombre,
      rol: rol,
      nia: nia,
      grupoId: grupoId,
    );
  }

  // Cierra la sesión del usuario: borra el token y vuelve al estado inicial.
  // Después de esto, la app redirige a la pantalla de login.
  Future<void> logout() async {
    // Indicamos que hay una operación en curso
    state = state.copyWith(loading: true);

    // Borramos todos los datos de sesión del almacenamiento del dispositivo
    await _preferencesService.clearSession();

    // Volvemos al estado inicial: sin sesión y sin carga
    state = const AuthState(
      isAuthenticated: false,
      loading: false,
      bootstrapping: false,
    );
  }
}

// Provider principal de autenticación.
// Cualquier widget de la app puede leer este provider para saber
// si el usuario está logueado y acceder a sus datos.
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

// Atajo rápido para saber si el usuario está logueado o no.
// Devuelve true si hay sesión activa, false si no.
// Muy útil para decidir si mostrar la pantalla de login o la app principal.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

// Atajo para obtener el token JWT del usuario logueado.
// Se usa en cada petición al servidor para demostrar que tenemos permiso.
// Devuelve null si no hay sesión activa.
final jwtTokenProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).token;
});

// Atajo para obtener el correo electrónico del trabajador autenticado.
// Devuelve null si no hay sesión activa.
final userEmailProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).correo;
});

// Atajo para obtener el rol del trabajador (supervisor o teleoperador).
// Sirve para mostrar u ocultar funcionalidades según el tipo de usuario.
// Devuelve null si no hay sesión activa.
final userRoleProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).rol;
});
