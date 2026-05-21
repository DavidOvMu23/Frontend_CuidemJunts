import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/notificacion.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';

// ----- Provider del banner flotante de notificaciones -----
// Este archivo gestiona las notificaciones que aparecen brevemente en pantalla
// como un banner emergente (overlay) cuando llega una notificación nueva.
// Se alimenta del stream global de notificaciones (notificacionesProvider) y muestra
// cada notificación nueva durante _displayDuration antes de retirarla.

// Cuánto tiempo permanece visible cada banner en pantalla.
const Duration _displayDuration = Duration(seconds: 5);

// Clase que agrupa una notificación con la hora a la que se empezó a mostrar.
// Se usa para saber cuándo fue visible y poder calcular cuándo ocultarla.
class DisplayNotification {
  // La notificación con todos sus datos (mensaje, tipo, etc.)
  final Notificacion notificacion;
  // Momento exacto en que se empezó a mostrar la notificación en pantalla
  final DateTime showTime;

  DisplayNotification({required this.notificacion, required this.showTime});
}

// Notifier que mantiene la lista de banners visibles.
// Escucha el stream de notificaciones del usuario logueado y, cuando aparece
// una notificación sin leer que no se ha mostrado antes, la añade a la lista
// y programa un temporizador para retirarla pasado _displayDuration.
class _OverlayNotifier extends Notifier<List<DisplayNotification>> {
  // IDs de notificaciones que ya hemos mostrado (para no repetir el banner
  // aunque vuelva a aparecer en sucesivos pollings).
  final Set<int> _seen = <int>{};
  // Timers programados para retirar cada banner cuando vence su duración.
  final Map<int, Timer> _expiryTimers = <int, Timer>{};
  // En la primera emisión del stream solo marcamos como "vistas" las
  // notificaciones que YA existían al cargar la app, para no inundar al
  // usuario con popups de avisos antiguos tras un F5 o login.
  bool _primeraEmision = true;

  @override
  List<DisplayNotification> build() {
    // Solo trabajamos si hay sesión iniciada.
    final authState = ref.watch(authProvider);
    if (authState.id == null || authState.id == 0) {
      _reset();
      return const [];
    }

    // Escuchamos el stream principal de notificaciones; cada emisión nos da la
    // lista completa actual y de ahí filtramos las "sin_leer" para procesarlas.
    ref.listen<AsyncValue<List<Notificacion>>>(
      notificacionesProvider,
      (prev, next) {
        next.whenData((list) {
          final sinLeer = list.where((n) => n.estado == 'sin_leer').toList();
          if (_primeraEmision) {
            // Snapshot inicial: marcamos los IDs ya existentes como vistos
            // SIN mostrar popups. Solo dispararemos banners para las que
            // lleguen en pollings posteriores (genuinamente nuevas).
            _primeraEmision = false;
            for (final n in sinLeer) {
              _seen.add(n.id);
            }
            return;
          }
          _process(sinLeer);
        });
      },
      fireImmediately: true,
    );

    // Al destruirse el Notifier (cierre de sesión, hot-reload), cancelamos los timers.
    ref.onDispose(_reset);

    return const [];
  }

  void _process(List<Notificacion> sinLeer) {
    final nuevos = <DisplayNotification>[];
    final ahora = DateTime.now();

    for (final notif in sinLeer) {
      if (_seen.contains(notif.id)) continue;
      _seen.add(notif.id);
      nuevos.add(DisplayNotification(notificacion: notif, showTime: ahora));

      // Programamos la retirada del banner cuando vence su duración.
      _expiryTimers[notif.id] = Timer(_displayDuration, () {
        _expiryTimers.remove(notif.id);
        // El Notifier puede haber sido reconstruido; protegemos con try/catch
        // implícito via ref.mounted-equivalent: simplemente ignoramos si state
        // ya no existe (Riverpod lanza si se asigna tras dispose).
        try {
          state = state.where((d) => d.notificacion.id != notif.id).toList();
        } catch (_) {
          // El notifier fue dispuesto; nada que hacer.
        }
      });
    }

    if (nuevos.isNotEmpty) {
      state = [...state, ...nuevos];
    }
  }

  // Cierra un banner manualmente (cuando el usuario pulsa la "X"). También
  // cancela el temporizador que estaba programado para retirarlo solo.
  void dismiss(int notificacionId) {
    final timer = _expiryTimers.remove(notificacionId);
    timer?.cancel();
    try {
      state = state
          .where((d) => d.notificacion.id != notificacionId)
          .toList();
    } catch (_) {
      // Notifier fue dispuesto durante la animación: ignoramos.
    }
  }

  void _reset() {
    for (final t in _expiryTimers.values) {
      t.cancel();
    }
    _expiryTimers.clear();
    _seen.clear();
    // Tras cerrar sesión, la próxima carga vuelve a considerar la primera
    // emisión como "snapshot" para que el nuevo usuario no reciba popups
    // de notificaciones que ya tenía sin leer en su cuenta.
    _primeraEmision = true;
  }
}

// Provider expuesto al widget. Se redibuja cada vez que el notifier emite un
// nuevo estado (al añadir o retirar un banner).
final notificationOverlayProvider =
    NotifierProvider<_OverlayNotifier, List<DisplayNotification>>(
  _OverlayNotifier.new,
);
