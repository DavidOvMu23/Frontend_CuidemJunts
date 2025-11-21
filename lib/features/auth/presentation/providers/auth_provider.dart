import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/preferences_provider.dart';

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

// Este es el metodo que controla el login, logout y mantiene
// la sesión del usuario. Cuando la app arranca, automáticamente
// verifica si hay una sesión guardada para no tener que volver a hacer login.
class AuthNotifier extends Notifier<AuthState> {
  // Se ejecuta automáticamente cuando se crea el provider.
  // Aquí comprobamos si el usuario ya había iniciado sesión antes.
  @override
  AuthState build() {
    final prefsService = ref.watch(preferencesServiceProvider);

    // Miramos si hay una sesión guardada en el dispositivo
    final isLoggedIn = prefsService.isLoggedIn();

    if (isLoggedIn) {
      // Hay sesión guardada, recuperamos los datos
      final token = prefsService.getToken();
      final email = prefsService.getUserEmail();
      final userData = prefsService.getUserData();

      return AuthState(
        isAuthenticated: true,
        loading: false,
        token: token,
        email: email,
        userData: userData,
      );
    } else {
      // No hay sesión, el usuario tendrá que hacer login
      return const AuthState(isAuthenticated: false, loading: false);
    }
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

    // Guardamos la sesión en el almacenamiento local del dispositivo
    final prefsService = ref.read(preferencesServiceProvider);
    await prefsService.saveSession(
      token: token,
      email: email,
      userData: userData,
    );

    // Actualizamos el estado: ahora el usuario está autenticado
    state = AuthState(
      isAuthenticated: true,
      loading: false,
      token: token,
      email: email,
      userData: userData,
    );
  }

  // Cierra la sesión del usuario y borra todos sus datos guardados.
  // Después de esto, el usuario volverá a la pantalla de login.
  Future<void> logout() async {
    state = state.copyWith(loading: true);

    // Borramos la sesión del almacenamiento local
    final prefsService = ref.read(preferencesServiceProvider);
    await prefsService.logout();

    // Volvemos al estado inicial: no autenticado
    state = const AuthState(isAuthenticated: false, loading: false);
  }

  // Actualiza solo el token sin tocar el resto de datos.

  // Útil si el backend nos da un token nuevo (refresh token) sin
  // tener que hacer login otra vez. (ESTO ES DEL CHAT GPT)
  Future<void> updateToken(String newToken) async {
    if (!state.isAuthenticated) return; // Solo si ya está logueado

    final prefsService = ref.read(preferencesServiceProvider);
    await prefsService.saveSession(
      token: newToken,
      email: state.email!,
      userData: state.userData,
    );

    state = state.copyWith(token: newToken);
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
