import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/preferences_service.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/preferences_provider.dart';

// ----- Provider de AuthState -----

class AuthState {
  final bool isAuthenticated; // ¿Está el usuario logueado?
  final bool loading; // Indica si se está realizando alguna operación asíncrona
  final int? id; // ID del trabajador
  final String? token; // Token JWT del trabajador
  final String? correo; // Correo del trabajador autenticado
  final String? nombre; // Nombre del trabajador
  final String? rol; // Rol del trabajador (supervisor, teleoperador)
  final String? nia;
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

  // Crea una copia del estado cambiando solo lo que queramos.
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

// Este es el método que controla el login y logout.
// Guarda el token JWT en SharedPreferences para mantener la sesión persistente.
class AuthNotifier extends Notifier<AuthState> {
  late PreferencesService _preferencesService;

  @override
  AuthState build() {
    _preferencesService = ref.watch(preferencesServiceProvider);

    // Sesión NO persistente: al iniciar la app, siempre se requiere login
    // Limpiar cualquier sesión guardada anterior
    _preferencesService.clearSession();

    // No hay sesión, usuario debe hacer login
    return const AuthState(isAuthenticated: false, loading: false);
  }

  // Guarda la sesión cuando el trabajador hace login correctamente.
  Future<void> login({
    required String token,
    required int id,
    required String correo,
    String? nombre,
    String? rol,
    String? nia,
    int? grupoId,
  }) async {
    state = state.copyWith(loading: true);

    // Guardar token y correo en SharedPreferences
    await _preferencesService.saveToken(token);
    await _preferencesService.saveUserDni(
      correo,
    ); // Reutilizamos para guardar correo

    // Actualizar estado
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

  // Cierra la sesión del usuario.
  Future<void> logout() async {
    state = state.copyWith(loading: true);

    // Limpiar el token de SharedPreferences
    await _preferencesService.clearSession();

    // Volver al estado inicial
    state = const AuthState(isAuthenticated: false, loading: false);
  }
}

// Provider principal de autenticación.
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

// Atajo para saber si el usuario está logueado o no.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

// Obtener el token JWT
final jwtTokenProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).token;
});

// Obtener el correo del trabajador autenticado
final userEmailProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).correo;
});

// Obtener el rol del trabajador
final userRoleProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).rol;
});
