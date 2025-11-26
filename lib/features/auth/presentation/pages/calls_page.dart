import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/llamadas.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/llamadas_service.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/grupo_service.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/calls_page_enums.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/calls/widgets/calls_scaffold_body.dart';

// -------- PANTALLA DE LLAMADAS --------
// Controlador principal de la vista de llamadas
// Gestiona el estado (filtros, búsqueda, ordenación) y la carga de datos
class LlamadasPage extends ConsumerStatefulWidget {
  const LlamadasPage({super.key});

  @override
  ConsumerState<LlamadasPage> createState() => _LlamadasPageState();
}

class _LlamadasPageState extends ConsumerState<LlamadasPage> {
  // Servicio para peticiones al backend
  late final LlamadasService _llamadasService;
  late final GrupoService _gruposService;

  // Cache del Future para evitar recargas innecesarias al reconstruir el widget
  late Future<List<Llamadas>> _llamadasFuture;

  // Estado local de la interfaz
  late CallsPageFilter filtroSeleccionado;
  String textoFiltro = '';
  CallsPageSort ordenSeleccionado = CallsPageSort.none;
  DateTime? fechaDesde;
  DateTime? fechaHasta;

  @override
  void initState() {
    super.initState();
    filtroSeleccionado = CallsPageFilter.all; // Por defecto mostramos todos
    _llamadasService = LlamadasService(
      baseUrl: 'http://cuidemjunts.zapto.org:3000',
    );
    _gruposService = GrupoService(baseUrl: 'http://cuidemjunts.zapto.org:3000');
    _llamadasFuture = _cargarLlamadasConGrupo(); // Iniciamos la carga
  }

  // Obtiene la lista completa de llamadas del servidor
  Future<List<Llamadas>> _cargarLlamadasConGrupo() async {
    final llamadas = await _llamadasService.getAll();
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

        final nombreGrupo = await _obtenerNombreGrupo(grupoId, cache);
        if (nombreGrupo == null) return llamada;
        return llamada.copyWith(grupoNombre: nombreGrupo);
      }),
    );

    return enriched;
  }

  Future<String?> _obtenerNombreGrupo(
    int grupoId,
    Map<int, String?> cache,
  ) async {
    if (cache.containsKey(grupoId)) {
      return cache[grupoId];
    }

    try {
      final grupo = await _gruposService.getById(grupoId);
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
  void _mostrarDetalleLlamada(BuildContext context, Llamadas llamada) {
    // TODO: Implementar diálogo de detalle de llamada
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
          llamada.estado.toLowerCase() == 'no contestada',
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
      }
    });

    return filtradas;
  }

  // Helper para convertir duración en segundos
  int _parseDuration(String duracion) {
    try {
      final parts = duracion.split(':');
      if (parts.length == 2) {
        final minutes = int.tryParse(parts[0]) ?? 0;
        final seconds = int.tryParse(parts[1]) ?? 0;
        return minutes * 60 + seconds;
      }
    } catch (_) {}
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    // -------- OBTENER NOMBRE DEL USUARIO DESDE RIVERPOD --------
    // Obtenemos el estado de autenticación del provider
    final authState = ref.watch(authProvider);
    String? userName;
    String? userRole;

    if (authState.userData != null) {
      try {
        // Convertimos el JSON a un Map
        final userData =
            jsonDecode(authState.userData!) as Map<String, dynamic>;

        // Intentamos obtener el nombre del usuario
        userName =
            userData['nombre']?.toString() ??
            userData['name']?.toString() ??
            userData['correo']?.toString() ??
            userData['email']?.toString();
        userRole = userData['rol']?.toString();
      } catch (e) {
        // Si hay error al parsear el JSON, simplemente no mostramos nombre
        userName = null;
      }
    }

    //
    return Scaffold(
      // -------- BARRA SUPERIOR --------
      appBar: appMainAppBar(
        onNotifications: () {
          // TODO: Acción al pulsar el icono de notificaciones.
        },
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
      body: CallsScaffoldBody(
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
      ),

      // -------- BOTÓN FLOTANTE --------
      floatingActionButton: general_floatingbutton(
        Icons.add,
        onPressed: () {
          // TODO: IMPLEMENTAR AÑADIR LLAMADA
        },
      ),
    );
  }
}
