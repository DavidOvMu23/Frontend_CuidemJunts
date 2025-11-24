import 'package:flutter_riverpod/flutter_riverpod.dart';

// Guarda si el usuario está logueado o no, y si está logueado,
// también guarda su token, email y otros datos que necesitemos.
class AuthState {
  final bool isAuthenticated; // ¿Está el usuario logueado?
  final bool
  loading; // Indica si se está realizando alguna operación asíncrona (ej. login, registro)
  final String? token; // Token de autenticación del backend
  final String? email; // Email del usuario
  final String? userData; // Datos adicionales del usuario (JSON)

  const AuthState({
    this.isAuthenticated = false,
    this.loading = false,
    this.token,
    this.email,
    this.userData,
  });

  // Crea una copia del estado cambiando solo lo que queramos.
  // Por ejemplo, si solo queremos cambiar loading a true, no tenemos
  // que volver a escribir todos los demás campos.
  AuthState copyWith({
    bool? isAuthenticated,
    bool? loading,
    String? token,
    String? email,
    String? userData,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      loading: loading ?? this.loading,
      token: token ?? this.token,
      email: email ?? this.email,
      userData: userData ?? this.userData,
    );
  }
}

// Este es el método que controla el login y logout.
// La sesión solo se mantiene en memoria mientras la app está abierta.
// Cuando se cierra la app, el usuario tendrá que volver a hacer login.
class AuthNotifier extends Notifier<AuthState> {
  // Se ejecuta automáticamente cuando se crea el provider.
  // Siempre retorna un estado no autenticado al iniciar la app.
  @override
  AuthState build() {
    // No hay sesión guardada, el usuario tendrá que hacer login
    return const AuthState(isAuthenticated: false, loading: false);
  }

  // Guarda la sesión cuando el usuario hace login correctamente.
  // Esto se llama desde la pantalla de login después de que el backend
  // confirme que las credenciales son correctas.
  Future<void> login({
    required String token,
    required String email,
    String? userData,
  }) async {
    // Ponemos loading en true para mostrar un spinner o algo
    state = state.copyWith(loading: true);

    // Actualizamos el estado: ahora el usuario está autenticado
    // NOTA: Solo guardamos en memoria, no en disco
    state = AuthState(
      isAuthenticated: true,
      loading: false,
      token: token,
      email: email,
      userData: userData,
    );
  }

  // Cierra la sesión del usuario.
  // Después de esto, el usuario volverá a la pantalla de login.
  Future<void> logout() async {
    state = state.copyWith(loading: true);

    // Volvemos al estado inicial: no autenticado
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
