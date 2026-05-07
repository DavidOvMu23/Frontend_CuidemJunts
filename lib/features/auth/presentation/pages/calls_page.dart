import 'package:flutter/material.dart';
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
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/grupo_service.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/calls_page_enums.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/widgets/calls_scaffold_body.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/llamadas_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/grupo_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/notificacion_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/widgets/call_detail_dialog.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/trabajador_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/call_create_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/usuario_provider.dart';

// -------- PANTALLA DE LLAMADAS --------
// Controlador principal de la vista de llamadas
// Gestiona el estado (filtros, búsqueda, ordenación) y la carga de datos
class LlamadasPage extends ConsumerStatefulWidget {
  final bool embedded;

  const LlamadasPage({
    super.key,
    this.embedded = false,
  });

  @override
  ConsumerState<LlamadasPage> createState() => _LlamadasPageState();
}



class _LlamadasPageState extends ConsumerState<LlamadasPage> {
  // Cache del Future para evitar recargas innecesarias al reconstruir el widget
  late Future<List<Llamadas>> _llamadasFuture;

  // Estado local de la interfaz
  late CallsPageFilter filtroSeleccionado;
  String textoFiltro = '';
  CallsPageSort ordenSeleccionado = CallsPageSort.none;
  DateTime? fechaDesde;
  DateTime? fechaHasta;
  Llamadas? _llamadaEnEdicion;
  bool _esCreacion = false;

  @override
  void initState() {
    super.initState();
    filtroSeleccionado = CallsPageFilter.all; // Por defecto mostramos todos
    _llamadasFuture = _cargarLlamadasConGrupo(); // Iniciamos la carga
  }

  // Obtiene la lista completa de llamadas del servidor
  Future<List<Llamadas>> _cargarLlamadasConGrupo() async {
    try {
      final llamadasService = ref.read(llamadasServiceProvider);
      final gruposService = ref.read(grupoServiceProvider);

      final llamadas = await llamadasService.getAll();
      final Map<int, String?> cache = {};

      final enriched = await Future.wait(
        llamadas.map((llamada) async {
          // Si el backend ya incluye el nombre del grupo en la comunicación,
          // no necesitamos hacer una petición adicional.
          if (llamada.grupoNombre != null && llamada.grupoNombre!.isNotEmpty) {
            return llamada;
          }

          final grupoId = llamada.grupoId;
          if (grupoId == 0) return llamada;

          final nombreGrupo = await _obtenerNombreGrupo(
            grupoId,
            cache,
            gruposService,
          );
          if (nombreGrupo == null) return llamada;
          return llamada.copyWith(grupoNombre: nombreGrupo);
        }),
      );

      return enriched;
    } catch (e, stack) {
      debugPrint('Error cargando llamadas: $e');
      debugPrint('Stacktrace: $stack');
      rethrow;
    }
  }

  Future<String?> _obtenerNombreGrupo(
    int grupoId,
    Map<int, String?> cache,
    GrupoService gruposService,
  ) async {
    if (cache.containsKey(grupoId)) {
      return cache[grupoId];
    }

    try {
      final grupo = await gruposService.getById(grupoId);
      cache[grupoId] = grupo.nombre;
      return grupo.nombre;
    } catch (_) {
      cache[grupoId] = null;
      return null;
    }
  }

  // --- Métodos para actualizar el estado desde los widgets hijos ---

  // Actualiza el texto de búsqueda
  void _onSearchChanged(String value) {
    setState(() => textoFiltro = value);
  }

  // Actualiza el filtro seleccionado
  void _onFilterChanged(CallsPageFilter value) {
    setState(() => filtroSeleccionado = value);
  }

  // Actualiza el orden seleccionado
  void _onSortChanged(CallsPageSort value) {
    setState(() => ordenSeleccionado = value);
  }

  // Actualiza la fecha desde
  void _onFechaDesdeChanged(DateTime? value) {
    setState(() => fechaDesde = value);
  }

  // Actualiza la fecha hasta
  void _onFechaHastaChanged(DateTime? value) {
    setState(() => fechaHasta = value);
  }

  // Muestra el detalle de una llamada
  Future<void> _mostrarDetalleLlamada(BuildContext context, Llamadas llamada) async {
    showDialog(
      context: context,
      builder: (ctx) => CallDetailDialog(
        llamada: llamada,
        onEdit: () {
          setState(() {
            _llamadaEnEdicion = llamada;
            _esCreacion = false;
          });
        },
        onDelete: () {
          // Implementar borrado de llamada
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
              setState(() {
                _llamadasFuture = _cargarLlamadasConGrupo();
              });
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

  Future<void> _guardarLlamada(CallFormData data) async {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.read(authProvider);
    final correo = authState.correo;
    if (correo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noAuthenticatedUser)),
      );
      return;
    }

    final bool isTele = (authState.rol ?? '').toLowerCase() == 'teleoperador';
    int? grupoIdToUse;
    if (isTele) {
      grupoIdToUse = authState.grupoId;
      if (grupoIdToUse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noGroupAssigned)),
        );
        return;
      }
    } else {
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
    final payload = {
      'usuarioId': data.usuarioId,
      'resumen': data.resumen,
      'duracion': data.duracion,
      'estado': data.estado,
      'observaciones': data.observaciones,
      'fecha': data.fecha.toIso8601String(),
      'hora': data.hora,
      'grupoId': grupoIdToUse,
    };

    try {
      final wasCreating = _esCreacion;
      if (_esCreacion) {
        await llamadasService.create(payload);
      } else if (_llamadaEnEdicion != null) {
        await llamadasService.update(_llamadaEnEdicion!.id, payload);
      }
      setState(() {
        _llamadaEnEdicion = null;
        _esCreacion = false;
        _llamadasFuture = _cargarLlamadasConGrupo();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(wasCreating ? l10n.callCreatedSuccessfully : l10n.callUpdatedSuccessfully)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorSavingCall(e.toString()))),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
                            // debug prints removed (were inserted erroneously)
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Filtra y ordena la lista de llamadas según el estado actual
  // Se ejecuta en el cliente sobre los datos ya cargados
  List<Llamadas> _aplicarFiltros(List<Llamadas> llamadas) {
    final query = textoFiltro.trim().toLowerCase();

    // 1. Filtrado
    final filtradas = llamadas.where((llamada) {
      // Coincidencia de texto (resumen o grupo)
      final coincideTexto =
          query.isEmpty ||
          llamada.resumen.toLowerCase().contains(query) ||
          (llamada.grupoNombre?.toLowerCase().contains(query) ?? false);

      // Coincidencia de filtro de estado/grupo
      final coincideFiltro = switch (filtroSeleccionado) {
        CallsPageFilter.all => true,
        CallsPageFilter.complete =>
          llamada.estado.toLowerCase() == 'completada',
        CallsPageFilter.pending => llamada.estado.toLowerCase() == 'pendiente',
        CallsPageFilter.incomplete =>
          llamada.estado.toLowerCase().contains('no contestada') ||
              llamada.estado.toLowerCase().contains('no contestó') ||
              llamada.estado.toLowerCase().contains('no_contesto'),
      };

      // Coincidencia de filtro de fecha
      bool coincideFecha = true;
      if (fechaDesde != null) {
        coincideFecha =
            coincideFecha &&
            (llamada.fecha.isAfter(fechaDesde!) ||
                llamada.fecha.isAtSameMomentAs(fechaDesde!));
      }
      if (fechaHasta != null) {
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

    // 2. Ordenación
    filtradas.sort((a, b) {
      switch (ordenSeleccionado) {
        case CallsPageSort.none:
          return 0;
        case CallsPageSort.dateLatest:
          return b.fecha.compareTo(a.fecha);
        case CallsPageSort.nameAZ:
          return a.resumen.compareTo(b.resumen);
        case CallsPageSort.nameZA:
          return b.resumen.compareTo(a.resumen);
        case CallsPageSort.callDurationShortLong:
          return _parseDuration(
            a.duracion,
          ).compareTo(_parseDuration(b.duracion));
        case CallsPageSort.callDurationLongShort:
          return _parseDuration(
            b.duracion,
          ).compareTo(_parseDuration(a.duracion));
        case CallsPageSort.dependencyHighLow:
          return b.grupoId.compareTo(a.grupoId);
        case CallsPageSort.dependencyLowHigh:
          return a.grupoId.compareTo(b.grupoId);
      }
    });

    return filtradas;
  }

  // Helper para convertir duración en segundos
  int _parseDuration(String duracion) {
    try {
      final clean = duracion.trim().toLowerCase().replaceAll('min', '').replaceAll(' ', '');
      if (clean.isEmpty) return 0;
      if (clean.contains(':')) {
        final parts = clean.split(':');
        if (parts.length == 2) {
          final minutes = int.tryParse(parts[0]) ?? 0;
          final seconds = int.tryParse(parts[1]) ?? 0;
          return minutes * 60 + seconds;
        }
      } else {
        // Si solo es un número, interpretarlo como minutos
        final minutes = int.tryParse(clean) ?? 0;
        return minutes * 60;
      }
    } catch (_) {}
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // -------- OBTENER NOMBRE DEL USUARIO DESDE RIVERPOD --------
    // Obtenemos el estado de autenticación del provider
    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
                        // debug print removed (was inserted erroneously)
    final userRole = authState.rol;
    final notificacionesSinLeerAsync = ref.watch(notificacionesSinLeerProvider);

    // Si no hay usuario logueado, mostrar un mensaje
    if (userName == null) {
      return Scaffold(
        body: Center(child: Text(l10n.noAuthenticatedUser)),
      );
    }

    final pageBody = _llamadaEnEdicion != null || _esCreacion
        ? CallFormPage(
            llamadaInicial: _llamadaEnEdicion,
            isEdit: _llamadaEnEdicion != null,
            buscarUsuarios: _buscarUsuarios,
            onSubmit: _guardarLlamada,
            onCancel: () {
              setState(() {
                _llamadaEnEdicion = null;
                _esCreacion = false;
              });
            },
          )
        : CallsScaffoldBody(
            llamadasFuture: _llamadasFuture,
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

    final fab = general_floatingbutton(
      Icons.add,
      onPressed: () {
        setState(() {
          _llamadaEnEdicion = null;
          _esCreacion = true;
        });
      },
    );

    if (widget.embedded) {
      return Stack(
        children: [
          Positioned.fill(child: pageBody),
          if (_llamadaEnEdicion == null && !_esCreacion)
            Positioned(right: 18, bottom: 18, child: fab),
        ],
      );
    }

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
      floatingActionButton: (_esCreacion || _llamadaEnEdicion != null) ? null : fab,
    );
  }

  Future<List<UsuarioBusqueda>> _buscarUsuarios(String query) async {
    final usuarioService = ref.read(usuarioServiceProvider);
    final usuarios = await usuarioService.getAll();
    final lower = query.trim().toLowerCase();
    return usuarios
        .where((u) =>
            u.nombre.toLowerCase().contains(lower) ||
            u.apellidos.toLowerCase().contains(lower) ||
            u.telefono.toLowerCase().contains(lower) ||
            u.dni.toLowerCase().contains(lower))
        .map((u) => UsuarioBusqueda(
              id: u.dni,
              nombreCompleto: '${u.nombre} ${u.apellidos}'.trim(),
            ))
        .toList();
  }
}
