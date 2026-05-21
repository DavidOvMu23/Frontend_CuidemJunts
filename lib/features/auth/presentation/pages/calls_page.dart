import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/emergency_contacts_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/notifications_page.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/grupos_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/calls_page_enums.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/widgets/calls_scaffold_body.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/llamadas_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/widgets/call_detail_dialog.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/trabajador_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/call_create_page.dart';

// -------- PANTALLA DE LLAMADAS --------
// Controlador principal de la vista de llamadas.
// Gestiona el estado (filtros, búsqueda, ordenación, rango de fechas) y la carga de datos.
class LlamadasPage extends ConsumerStatefulWidget {
  // Si es true, la página se muestra incrustada dentro de otra pantalla.
  final bool embedded;
  // Llamada que se debe abrir directamente en modo edición al entrar.
  // Se usa cuando se navega desde una notificación.
  final Llamadas? llamadaParaEditar;

  const LlamadasPage({
    super.key,
    this.embedded = false,
    this.llamadaParaEditar,
  });

  @override
  ConsumerState<LlamadasPage> createState() => _LlamadasPageState();
}

class _LlamadasPageState extends ConsumerState<LlamadasPage> {
  // Filtro actualmente seleccionado (por defecto todos).
  late CallsPageFilter filtroSeleccionado;

  // Texto que el usuario escribe en el buscador.
  String textoFiltro = '';

  // Orden actualmente seleccionado.
  CallsPageSort ordenSeleccionado = CallsPageSort.none;

  // Fecha de inicio y fin del rango de fechas para filtrar por fecha.
  DateTime? fechaDesde;
  DateTime? fechaHasta;

  // Llamada que se está editando. Si es null, no hay edición activa.
  Llamadas? _llamadaEnEdicion;

  // Controla si se está mostrando el formulario de creación.
  bool _esCreacion = false;

  // Lista de teleoperadores cargada previamente para el selector del formulario.
  // Solo se usa cuando el usuario conectado es supervisor.
  List<TeleoperadorBusqueda>? _teleoperadoresCached;

  // Inicializa el estado y precarga teleoperadores al abrir la página.
  // La lista de llamadas viene del provider con polling.
  @override
  void initState() {
    super.initState();
    filtroSeleccionado = CallsPageFilter.all;

    // Si venimos con una llamada para editar (desde notificación), la activamos.
    if (widget.llamadaParaEditar != null) {
      _llamadaEnEdicion = widget.llamadaParaEditar;
      _esCreacion = false;
      // Limpiamos el provider de edición pendiente para no volver a entrar en este modo.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(pendingCallEditProvider.notifier).set(null);
      });
    }

    // Precargamos los teleoperadores si el usuario es supervisor
    // para que el selector del formulario esté listo cuando se abra.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rol = ref.read(authProvider).rol ?? '';
      if (rol.toLowerCase() == AppRoles.supervisor) _cargarTeleoperadores();
    });
  }

  // Obtiene todos los teleoperadores activos del servidor y los guarda en caché.
  Future<void> _cargarTeleoperadores() async {
    try {
      final service = ref.read(trabajadorServiceProvider);
      final todos = await service.getAll();
      if (!mounted) return;
      setState(() {
        // Solo nos quedamos con los teleoperadores que están activos.
        _teleoperadoresCached = todos
            .where((t) => t.rol.toLowerCase() == AppRoles.teleoperador && t.activo)
            .map((t) => TeleoperadorBusqueda(id: t.id, nombreCompleto: '${t.nombre} ${t.apellidos}'))
            .toList();
      });
    } catch (_) {}
  }

  // --- Métodos que actualizan el estado cuando los widgets hijos cambian algo ---

  // Actualiza el texto de búsqueda y refiltra la lista.
  void _onSearchChanged(String value) {
    setState(() => textoFiltro = value);
  }

  // Actualiza el filtro de estado de llamada.
  void _onFilterChanged(CallsPageFilter value) {
    setState(() => filtroSeleccionado = value);
  }

  // Actualiza el orden de la lista.
  void _onSortChanged(CallsPageSort value) {
    setState(() => ordenSeleccionado = value);
  }

  // Actualiza la fecha de inicio del rango de filtrado por fecha.
  void _onFechaDesdeChanged(DateTime? value) {
    setState(() => fechaDesde = value);
  }

  // Actualiza la fecha de fin del rango de filtrado por fecha.
  void _onFechaHastaChanged(DateTime? value) {
    setState(() => fechaHasta = value);
  }

  // Abre el diálogo de detalle de una llamada.
  // Desde ahí se puede editar o eliminar la llamada.
  Future<void> _mostrarDetalleLlamada(BuildContext context, Llamadas llamada) async {
    showDialog(
      context: context,
      builder: (ctx) => CallDetailDialog(
        llamada: llamada,
        // Al pulsar editar, cerramos el diálogo y abrimos el formulario de edición.
        onEdit: () {
          setState(() {
            _llamadaEnEdicion = llamada;
            _esCreacion = false;
          });
        },
        onDelete: () {
          // Borrado de llamada mediante función asíncrona inmediatamente invocada.
          final l10n = AppLocalizations.of(context)!;
          () async {
            final llamadasService = ref.read(llamadasServiceProvider);
            try {
              await llamadasService.delete(llamada.id);
              if (!context.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.callDeletedSuccessfully)),
              );
              // Forzamos un refresco inmediato del provider para reflejar el borrado.
              ref.invalidate(llamadasProvider);
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.errorDeletingCall(e.toString()))),
              );
            }
          }();
        },
      ),
    );
  }

  // Guarda una llamada nueva o los cambios de una existente.
  // Determina el grupo correcto según si el usuario es teleoperador o supervisor.
  Future<void> _guardarLlamada(CallFormData data) async {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.read(authProvider);
    final correo = authState.correo;

    // Si no hay usuario conectado, no podemos continuar.
    if (correo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noAuthenticatedUser)),
      );
      return;
    }

    final bool isTele = (authState.rol ?? '').toLowerCase() == AppRoles.teleoperador;
    int? grupoIdToUse;

    if (isTele) {
      // Los teleoperadores usan el grupo que tienen asignado en su perfil.
      grupoIdToUse = authState.grupoId;
      if (grupoIdToUse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noGroupAssigned)),
        );
        return;
      }
    } else {
      // Los supervisores buscan el grupo del trabajador que coincide con su correo.
      final trabajadorService = ref.read(trabajadorServiceProvider);
      final trabajadores = await trabajadorService.getAll();
      final trabajador = trabajadores.firstWhere(
        (t) => t.correo == correo,
        orElse: () => throw Exception('Trabajador no encontrado'),
      );
      if (trabajador.grupoId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noGroupAssigned)),
        );
        return;
      }
      grupoIdToUse = trabajador.grupoId;
    }

    final llamadasService = ref.read(llamadasServiceProvider);

    // El ID del teleoperador: si es teleoperador usa el suyo propio;
    // si es supervisor, usa el que eligió en el formulario.
    final int? teleoperadorId = isTele ? authState.id : data.teleoperadorId;

    // Construimos el objeto con los datos de la llamada.
    final payload = {
      'usuarioId': data.usuarioId,
      'resumen': data.resumen,
      'duracion': data.duracion,
      'estado': data.estado,
      'observaciones': data.observaciones,
      'fecha': data.fecha.toIso8601String(),
      'hora': data.hora,
      'grupoId': grupoIdToUse,
      // Solo añadimos el ID del teleoperador si existe.
      if (teleoperadorId != null) 'teleoperadorId': teleoperadorId,
    };

    try {
      final wasCreating = _esCreacion;

      if (_esCreacion) {
        // Modo creación: creamos una llamada nueva.
        await llamadasService.create(payload);
      } else if (_llamadaEnEdicion != null) {
        // Modo edición: actualizamos la llamada existente.
        await llamadasService.update(_llamadaEnEdicion!.id, payload);
      }

      // Volvemos a la lista y forzamos refresco inmediato.
      setState(() {
        _llamadaEnEdicion = null;
        _esCreacion = false;
      });
      ref.invalidate(llamadasProvider);

      // Mostramos un mensaje diferente según si creamos o editamos.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(wasCreating ? l10n.callCreatedSuccessfully : l10n.callUpdatedSuccessfully)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorSavingCall(e.toString()))),
      );
    }
  }

  // Filtra y ordena la lista de llamadas en el dispositivo.
  // Se ejecuta cuando cambia el texto de búsqueda, el filtro, el orden o el rango de fechas.
  List<Llamadas> _aplicarFiltros(List<Llamadas> llamadas) {
    final query = textoFiltro.trim().toLowerCase();

    // Paso 1: Filtrado por texto, estado y rango de fechas.
    final filtradas = llamadas.where((llamada) {
      // La llamada coincide si el texto aparece en el resumen o en el nombre del grupo.
      final coincideTexto =
          query.isEmpty ||
          llamada.resumen.toLowerCase().contains(query) ||
          (llamada.grupoNombre?.toLowerCase().contains(query) ?? false);

      // Filtramos por el estado de la llamada (completada, pendiente, no contestada).
      final coincideFiltro = switch (filtroSeleccionado) {
        CallsPageFilter.all => true,
        CallsPageFilter.complete =>
          llamada.estado.toLowerCase() == CallStatus.completada,
        CallsPageFilter.pending => llamada.estado.toLowerCase() == CallStatus.pendiente,
        // El estado "no contestada" puede venir con distintos textos del servidor.
        CallsPageFilter.incomplete =>
          llamada.estado.toLowerCase().contains('no contestada') ||
              llamada.estado.toLowerCase().contains('no contestó') ||
              llamada.estado.toLowerCase().contains(CallStatus.noContesto),
      };

      // Filtramos por rango de fechas si el usuario ha seleccionado alguno.
      bool coincideFecha = true;
      if (fechaDesde != null) {
        // La llamada debe ser el mismo día o posterior a la fecha de inicio.
        coincideFecha =
            coincideFecha &&
            (llamada.fecha.isAfter(fechaDesde!) ||
                llamada.fecha.isAtSameMomentAs(fechaDesde!));
      }
      if (fechaHasta != null) {
        // La llamada debe ser antes del final del día de la fecha límite.
        final fechaHastaFin = DateTime(
          fechaHasta!.year,
          fechaHasta!.month,
          fechaHasta!.day,
          23,
          59,
          59,
        );
        coincideFecha =
            coincideFecha &&
            (llamada.fecha.isBefore(fechaHastaFin) ||
                llamada.fecha.isAtSameMomentAs(fechaHastaFin));
      }

      return coincideTexto && coincideFiltro && coincideFecha;
    }).toList();

    // Paso 2: Ordenamos la lista filtrada.
    filtradas.sort((a, b) {
      switch (ordenSeleccionado) {
        case CallsPageSort.none:
          // Sin orden especial: mantenemos el orden del servidor.
          return 0;
        case CallsPageSort.dateLatest:
          // Las más recientes primero.
          return b.fecha.compareTo(a.fecha);
        case CallsPageSort.nameAZ:
          return a.resumen.compareTo(b.resumen);
        case CallsPageSort.nameZA:
          return b.resumen.compareTo(a.resumen);
        // Las de menor duración primero.
        case CallsPageSort.callDurationShortLong:
          return _parseDuration(a.duracion).compareTo(_parseDuration(b.duracion));
        // Las de mayor duración primero.
        case CallsPageSort.callDurationLongShort:
          return _parseDuration(b.duracion).compareTo(_parseDuration(a.duracion));
        case CallsPageSort.dependencyHighLow:
          return b.grupoId.compareTo(a.grupoId);
        case CallsPageSort.dependencyLowHigh:
          return a.grupoId.compareTo(b.grupoId);
      }
    });

    return filtradas;
  }

  // Convierte una cadena de duración a segundos para poder comparar y ordenar.
  // Acepta formatos "mm:ss" o solo un número de minutos.
  int _parseDuration(String duracion) {
    try {
      final clean = duracion.trim().toLowerCase().replaceAll('min', '').replaceAll(' ', '');
      if (clean.isEmpty) return 0;

      if (clean.contains(':')) {
        // Formato "minutos:segundos"
        final parts = clean.split(':');
        if (parts.length == 2) {
          final minutes = int.tryParse(parts[0]) ?? 0;
          final seconds = int.tryParse(parts[1]) ?? 0;
          return minutes * 60 + seconds;
        }
      } else {
        // Si solo es un número, lo interpretamos como minutos.
        final minutes = int.tryParse(clean) ?? 0;
        return minutes * 60;
      }
    } catch (_) {}
    return 0;
  }

  // Construye toda la interfaz visual de la pantalla de llamadas.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Escuchamos si llega una solicitud de edición desde otra parte de la app
    // (por ejemplo, desde una notificación cuando la pantalla ya está abierta).
    ref.listen<Llamadas?>(pendingCallEditProvider, (_, next) {
      if (next != null && widget.embedded) {
        setState(() {
          _llamadaEnEdicion = next;
          _esCreacion = false;
        });
        ref.read(pendingCallEditProvider.notifier).set(null);
      }
    });

    // Leemos los datos del usuario conectado.
    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final userRole = authState.rol;
    final esTeleoperador = (userRole ?? '').toLowerCase() == AppRoles.teleoperador;

    // Lista de llamadas enriquecida con nombres de grupo, en tiempo real.
    // Para teleoperadores filtramos a solo las llamadas de su grupo; los
    // supervisores ven todas.
    final todasLasLlamadasAsync = ref.watch(llamadasConGrupoProvider);
    final llamadasAsync = esTeleoperador
        ? todasLasLlamadasAsync.whenData((calls) {
            final grupoId = authState.grupoId;
            if (grupoId == null || grupoId == 0) return <Llamadas>[];
            return calls.where((c) => c.grupoId == grupoId).toList();
          })
        : todasLasLlamadasAsync;
    // Número de notificaciones para la barra superior.
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);

    // Si no hay usuario conectado, mostramos un mensaje de error.
    if (userName == null) {
      return Scaffold(
        body: Center(child: Text(l10n.noAuthenticatedUser)),
      );
    }

    // Decidimos si mostrar el formulario (creación/edición) o la lista de llamadas.
    final pageBody = _llamadaEnEdicion != null || _esCreacion
        ? CallFormPage(
            llamadaInicial: _llamadaEnEdicion,
            isEdit: _llamadaEnEdicion != null,
            onSubmit: _guardarLlamada,
            teleoperadores: _teleoperadoresCached,
            // Al cancelar, volvemos a la lista.
            onCancel: () {
              setState(() {
                _llamadaEnEdicion = null;
                _esCreacion = false;
              });
            },
          )
        : CallsScaffoldBody(
            llamadasAsync: llamadasAsync,
            filtroSeleccionado: filtroSeleccionado,
            ordenSeleccionado: ordenSeleccionado,
            textoFiltro: textoFiltro,
            fechaDesde: fechaDesde,
            fechaHasta: fechaHasta,
            aplicarFiltros: _aplicarFiltros,
            onSearchChanged: _onSearchChanged,
            onFilterChanged: _onFilterChanged,
            onSortChanged: _onSortChanged,
            onFechaDesdeChanged: _onFechaDesdeChanged,
            onFechaHastaChanged: _onFechaHastaChanged,
            onLlamadaTap: _mostrarDetalleLlamada,
          );

    // Botón flotante para crear una nueva llamada.
    final fab = general_floatingbutton(
      Icons.add,
      onPressed: () {
        setState(() {
          _llamadaEnEdicion = null;
          _esCreacion = true;
        });
      },
    );

    // Si está incrustada en otra pantalla, usamos Stack para el botón flotante.
    if (widget.embedded) {
      return Stack(
        children: [
          Positioned.fill(child: pageBody),
          // El botón flotante solo aparece cuando no hay formulario abierto.
          if (_llamadaEnEdicion == null && !_esCreacion)
            Positioned(right: 18, bottom: 18, child: fab),
        ],
      );
    }

    // Versión de pantalla completa con barra superior, menú lateral y botón flotante.
    return Scaffold(
      // -------- BARRA SUPERIOR --------
      appBar: appMainAppBar(
        numeroNotificaciones: notificacionesSinLeerAsync.when(
          data: (count) => count,
          loading: () => 0,
          error: (_, __) => 0,
        ),
        onNotifications: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsPage()),
          );
        },
        context: context,
      ),

      // -------- MENÚ LATERAL --------
      drawer: appDrawer(
        userName: userName,
        userRole: userRole,
        context: context,
        selected: DrawerItem.calls,
        onTapHome: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeSupervisorPage()),
          );
        },
        onTapUsers: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UsersPage()),
          );
        },
        onTapEmergencyContacts: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmergencyContactsPage(),
            ),
          );
        },
        onTapTelemarketers: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WorkersPage()),
          );
        },
        onTapGroups: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GruposPage()),
          );
        },
        onTapPreferences: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PreferencesPage()),
          );
        },
        onTapNotifications: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsPage()),
          );
        },
        onLogoutConfirmed: () async {
          await ref.read(authProvider.notifier).logout();
          if (!context.mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
      ),

      // -------- CONTENIDO PRINCIPAL --------
      body: pageBody,

      // -------- BOTÓN FLOTANTE --------
      // Se oculta cuando hay un formulario abierto.
      floatingActionButton: (_esCreacion || _llamadaEnEdicion != null) ? null : fab,
    );
  }

}
