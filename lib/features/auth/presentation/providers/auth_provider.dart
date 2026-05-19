import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  // Aquí definimos el estado inicial: siempre empieza sin sesión activa.
  @override
  AuthState build() {
    _preferencesService = ref.watch(preferencesServiceProvider);

    // Sesión NO persistente: al iniciar la app, siempre se requiere login.
    // Borramos cualquier sesión guardada de una ejecución anterior para
    // obligar al usuario a identificarse cada vez que abre la app.
    _preferencesService.clearSession();

    // Estado inicial: sin sesión y sin carga
    return const AuthState(isAuthenticated: false, loading: false);
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

    // Guardamos el token y el correo en el almacenamiento del dispositivo
    // para que estén disponibles mientras dure la sesión
    await _preferencesService.saveToken(token);
    // Reutilizamos el campo "dni" para guardar el correo del trabajador
    await _preferencesService.saveUserDni(correo);

    // Actualizamos el estado con todos los datos del trabajador recibidos del servidor
    state = AuthState(
      isAuthenticated: true,
      loading: false,
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

    // Borramos el token del almacenamiento del dispositivo
    // para que no quede ningún rastro de la sesión
    await _preferencesService.clearSession();

    // Volvemos al estado inicial: sin sesión y sin carga
    state = const AuthState(isAuthenticated: false, loading: false);
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
