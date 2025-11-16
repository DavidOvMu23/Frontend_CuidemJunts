import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/app/theme/app_palette.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:frontend_cuidemjunts/features/auth/data/service/contacto_emergencia_service.dart';
import 'package:frontend_cuidemjunts/features/auth/data/service/usuario_service.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/supervisor/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/llamadas_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/crearUser_page.dart';
import 'package:intl/intl.dart';

// -------- PANTALLA DE USUARIOS --------
// Guía rápida (noob-friendly):
// 1) initState: crea servicios y lanza _cargarUsuariosConContactos() (trae usuarios + contactos).
// 2) _aplicarFiltros: se queda con la lista ya cargada y aplica búsqueda, filtro y orden.
// 3) build: dibuja AppBar, Drawer, buscador, filtros, FutureBuilder y el botón flotante de crear usuario.
// 4) FutureBuilder: muestra loader/error o la lista; cada usuario se pinta con _UserCard.
// 5) _UserCard: muestra nombre, fecha, teléfono, dirección opcional, nivel de dependencia y contactos si hay.
// Flujo completo: carga -> filtra/ordena -> pinta pantalla -> pinta tarjetas.
// Aquí el supervisor consulta, busca y ordena usuarios llegados del backend.
class UsersPage extends StatefulWidget {
  // Callback que cambia el tema de la app.
  // Si es true, activa modo oscuro; si es false, modo claro.
  // Se utiliza para que el cambio de tema afecte a toda la app.
  final void Function(bool) onToggleTheme;

  // Callback que cambia el idioma de la app.
  // Se utiliza para que el cambio de idioma afecte a toda la app.
  final void Function(Locale) onChangeLocale;

  const UsersPage({
    super.key,
    required this.onToggleTheme,
    required this.onChangeLocale,
  });

  @override
  State<UsersPage> createState() => _UsersPageState();
}

// Filtros disponibles de la busqueda de usuarios.
enum UserFilter { all, ningunaDep, leve, medio, severo }

// Modos de ordenación disponibles para la lista de usuarios.
enum UserSort {
  noneAZ,
  nameZA,
  dateBirthOldest,
  dateBirthNewest,
  dependencyHighLow,
  dependencyLowHigh,
}

class _UsersPageState extends State<UsersPage> {
  // Servicio que trae los usuarios desde el backend.
  late final UsuarioService _usuarioService;
  late final ContactoEmergenciaService _contactoEmergenciaService;
  // Future cacheado para no lanzar la petición en cada build.
  late Future<List<Usuario>> _usuariosFuture;
  // Estado del filtro seleccionado y del texto del buscador.
  late UserFilter filtroSeleccionado;
  late String textoFiltro = '';
  late
  /// Orden actualmente seleccionado para la lista.
  UserSort
  ordenSeleccionado = UserSort.noneAZ;

  @override
  void initState() {
    super.initState();
    filtroSeleccionado = UserFilter.all; // De inicio mostramos todos.
    _usuarioService = UsuarioService(baseUrl: 'http://localhost:3000');
    _contactoEmergenciaService = ContactoEmergenciaService(
      baseUrl: 'http://localhost:3000',
    );
    _usuariosFuture = _cargarUsuariosConContactos(); // Carga inicial.
  }

  /// Llama a backend, trae usuarios y añade sus contactos de emergencia.
  Future<List<Usuario>> _cargarUsuariosConContactos() async {
    final usuarios = await _usuarioService.getAll();
    final enriched = await Future.wait(
      usuarios.map((usuario) async {
        try {
          // Para cada usuario llamamos a su endpoint de contactos y los añadimos.
          final contactos = await _contactoEmergenciaService.getByUsuarioDni(
            usuario.dni,
          );
          return usuario.copyWith(contactosEmergencia: contactos);
        } catch (_) {
          return usuario; // Si falla, devolvemos al usuario sin contactos (no rompe la lista).
        }
      }),
    );
    return enriched;
  }

  // Aplica búsqueda + filtro + ordenación sobre la lista original.
  List<Usuario> _aplicarFiltros(List<Usuario> usuarios) {
    final query = textoFiltro.trim().toLowerCase();
    final filtrados = usuarios.where((usuario) {
      // 1) Coincidencia de texto (nombre completo o DNI).
      final nombreCompleto = '${usuario.nombre} ${usuario.apellidos}'
          .toLowerCase();
      final coincideTexto =
          query.isEmpty ||
          nombreCompleto.contains(query) ||
          usuario.dni.toLowerCase().contains(query);

      // 2) Coincidencia de filtro de dependencia.
      final coincideFiltro = switch (filtroSeleccionado) {
        UserFilter.all => true,
        UserFilter.ningunaDep => usuario.nivelDependencia.isEmpty,
        UserFilter.leve => usuario.nivelDependencia.toUpperCase() == 'G1',
        UserFilter.medio => usuario.nivelDependencia.toUpperCase() == 'G2',
        UserFilter.severo => usuario.nivelDependencia.toUpperCase() == 'G3',
      };

      return coincideTexto && coincideFiltro; // Debe pasar ambas condiciones.
    }).toList();

    // 3) Ordenamos según la opción seleccionada en el botón de filtro/orden.
    filtrados.sort((a, b) {
      switch (ordenSeleccionado) {
        case UserSort.nameZA:
          return b.nombre.compareTo(a.nombre);
        case UserSort.noneAZ:
          return a.nombre.compareTo(b.nombre);
        case UserSort.dateBirthOldest:
          return a.f_nac.compareTo(b.f_nac);
        case UserSort.dateBirthNewest:
          return b.f_nac.compareTo(a.f_nac);
        case UserSort.dependencyHighLow:
          return _dependencyRank(b.nivelDependencia) -
              _dependencyRank(a.nivelDependencia);
        case UserSort.dependencyLowHigh:
          return _dependencyRank(a.nivelDependencia) -
              _dependencyRank(b.nivelDependencia);
        case UserSort.noneAZ:
          return 0;
      }
    });

    return filtrados;
  }

  // Convierte los grados de dependencia en una prioridad numérica para ordenar.
  int _dependencyRank(String nivel) {
    switch (nivel.toUpperCase()) {
      case 'G3':
        return 3;
      case 'G2':
        return 2;
      case 'G1':
        return 1;
      default:
        return 0;
    }
  }

  // Primero los activos, después el resto.
  int _estadoCuentaRank(String estado) {
    return estado.toLowerCase() == 'activo' ? 0 : 1;
  }

  @override
  Widget build(BuildContext context) {
    // Me guardo tipografías y paleta para reutilizarlas.
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormatter = DateFormat('dd/MM/yyyy');

    // Textos traducidos según el idioma actual.
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // -------- BARRA SUPERIOR --------
      // AppBar con botón de notificaciones (pendiente de implementar).
      appBar: appMainAppBar(
        onNotifications: () {
          // TODO: Acción al pulsar el icono de notificaciones.
        },
      ),

      // -------- MENÚ LATERAL --------
      // Drawer con las secciones principales del supervisor.
      drawer: appDrawer(
        context: context,
        selected: DrawerItem.users,
        onTapHome: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeSupervisorPage(
                onToggleTheme: widget.onToggleTheme,
                onChangeLocale: widget.onChangeLocale,
              ),
            ),
          );
        },
        onTapCalls: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LlamadasPage(
                onToggleTheme: widget.onToggleTheme,
                onChangeLocale: widget.onChangeLocale,
              ),
            ),
          );
        },
        onTapTelemarketers: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkersPage(
                onToggleTheme: widget.onToggleTheme,
                onChangeLocale: widget.onChangeLocale,
              ),
            ),
          );
        },
        onTapPreferences: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreferencesPage(
                onToggleTheme: widget.onToggleTheme,
                onChangeLocale: widget.onChangeLocale,
              ),
            ),
          );
        },
        onLogoutConfirmed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(
                onToggleTheme: widget.onToggleTheme,
                onChangeLocale: widget.onChangeLocale,
              ),
            ),
          );
        },
      ),

      // -------- CONTENIDO PRINCIPAL --------
      // Stack para superponer el botón flotante.
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -------- TITULAR --------
                // Cabecera fija de la pantalla.
                Text(
                  l10n.users,
                  style: textTheme.titleMedium?.copyWith(fontSize: 27),
                ),
                Text(l10n.manageUsers, style: textTheme.bodyMedium),
                const SizedBox(height: 20),

                // -------- TARJETA PRINCIPAL --------
                // Todo el contenido está dentro y el scroll solo afecta a la lista.
                Expanded(
                  child: Material(
                    borderRadius: BorderRadius.circular(30),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.searchUsers,
                            textAlign: TextAlign.left,
                      style: textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),

                          // Buscador de texto.
                          general_busqueda_textfield(
                            l10n.searchUser,
                            icono: Icons.search,
                            onChanged: (value) {
                              setState(() {
                                textoFiltro = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          // Filtro por dependencia con dropdown.
                          Row(
                            children: [
                              Icon(
                                filtroSeleccionado != UserFilter.all
                                    ? Icons.filter_alt
                                    : Icons.filter_alt_off,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<UserFilter>(
                                  initialValue: filtroSeleccionado,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  borderRadius: BorderRadius.circular(12),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  items: [
                                    DropdownMenuItem<UserFilter>(
                                      value: UserFilter.all,
                                      child: Text(l10n.searchAllUsers),
                                    ),
                                    DropdownMenuItem<UserFilter>(
                                      value: UserFilter.ningunaDep,
                                      child: Text(l10n.searchNoDependency),
                                    ),
                                    DropdownMenuItem<UserFilter>(
                                      value: UserFilter.leve,
                                      child: Text(
                                        l10n.searchModerateDependency,
                                      ),
                                    ),
                                    DropdownMenuItem<UserFilter>(
                                      value: UserFilter.medio,
                                      child: Text(l10n.searchSevereDependency),
                                    ),
                                    DropdownMenuItem<UserFilter>(
                                      value: UserFilter.severo,
                                      child: Text(l10n.searchHighDependency),
                                    ),
                                  ],
                                  onChanged: (UserFilter? newValue) {
                                    setState(() {
                                      filtroSeleccionado =
                                          newValue ?? UserFilter.all;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 10),

                          // -------- LISTA DE USUARIOS --------
                          // Solo esta sección es scrolleable.
                          Expanded(
                            child: FutureBuilder<List<Usuario>>(
                              future: _usuariosFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Card(
                                      margin: EdgeInsets.zero,
                                      color: colorScheme.error.withOpacity(0.2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          l10n.errorUsersLoading,
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.error,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final usuarios = snapshot.data ?? [];
                                final usuariosFiltrados = _aplicarFiltros(
                                  usuarios,
                                );
                                final totalText =
                                    textoFiltro.isEmpty &&
                                        filtroSeleccionado == UserFilter.all
                                    ? '${l10n.totalUsers}: ${usuarios.length}'
                                    : '${l10n.usersFound} ${usuariosFiltrados.length}';

                                if (usuarios.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'No se encontraron usuarios',
                                      style: textTheme.bodyMedium,
                                    ),
                                  );
                                }

                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            totalText,
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                          ),
                                        ),
                                        general_iconbutton(
                                          ordenSeleccionado == UserSort.noneAZ
                                              ? Icons.filter_list_off
                                              : Icons.filter_list,
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (context) => Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      l10n.sortType,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    general_listtile(
                                                      context: context,
                                                      icon:
                                                          Icons.filter_list_off,
                                                      texto: l10n.noSortedUsers,
                                                      onTap: () {
                                                        setState(() {
                                                          ordenSeleccionado =
                                                              UserSort.noneAZ;
                                                        });
                                                        general_snackbar(
                                                          context,
                                                          l10n.noSortedUsers,
                                                          2,
                                                        );
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                    general_listtile(
                                                      context: context,
                                                      icon: Icons.sort_by_alpha,
                                                      texto: l10n.sortNameZA,
                                                      onTap: () {
                                                        setState(() {
                                                          ordenSeleccionado =
                                                              UserSort.nameZA;
                                                        });
                                                        Navigator.pop(context);
                                                        general_snackbar(
                                                          context,
                                                          l10n.sortedZASnackbar,
                                                          2,
                                                        );
                                                      },
                                                    ),
                                                    general_listtile(
                                                      context: context,
                                                      icon: Icons.sort_by_alpha,
                                                      texto: l10n.sortNameAZ,
                                                      onTap: () {
                                                        setState(() {
                                                          ordenSeleccionado =
                                                              UserSort.noneAZ;
                                                        });
                                                        Navigator.pop(context);
                                                        general_snackbar(
                                                          context,
                                                          l10n.sortedAZSnackbar,
                                                          2,
                                                        );
                                                      },
                                                    ),
                                                    general_listtile(
                                                      context: context,
                                                      icon: Icons.date_range,
                                                      texto: l10n
                                                          .sortDateBirthNewest,
                                                      onTap: () {
                                                        setState(() {
                                                          ordenSeleccionado =
                                                              UserSort
                                                                  .dateBirthNewest;
                                                        });
                                                        Navigator.pop(context);
                                                        general_snackbar(
                                                          context,
                                                          l10n.sortedDateBirthNewest,
                                                          2,
                                                        );
                                                      },
                                                    ),
                                                    general_listtile(
                                                      context: context,
                                                      icon: Icons.date_range,
                                                      texto: l10n
                                                          .sortDateBirthOldest,
                                                      onTap: () {
                                                        setState(() {
                                                          ordenSeleccionado =
                                                              UserSort
                                                                  .dateBirthOldest;
                                                        });
                                                        Navigator.pop(context);
                                                        general_snackbar(
                                                          context,
                                                          l10n.sortedDateBirthOldest,
                                                          2,
                                                        );
                                                      },
                                                    ),
                                                    general_listtile(
                                                      context: context,
                                                      icon: Icons.bar_chart,
                                                      texto: l10n
                                                          .sortDependencyHighLow,
                                                      onTap: () {
                                                        setState(() {
                                                          ordenSeleccionado =
                                                              UserSort
                                                                  .dependencyHighLow;
                                                        });
                                                        Navigator.pop(context);
                                                        general_snackbar(
                                                          context,
                                                          l10n.sortedDependencyLevelHighLow,
                                                          2,
                                                        );
                                                      },
                                                    ),
                                                    general_listtile(
                                                      context: context,
                                                      icon: Icons.bar_chart,
                                                      texto: l10n
                                                          .sortDependencyLowHigh,
                                                      onTap: () {
                                                        setState(() {
                                                          ordenSeleccionado =
                                                              UserSort
                                                                  .dependencyLowHigh;
                                                        });
                                                        Navigator.pop(context);
                                                        general_snackbar(
                                                          context,
                                                          l10n.sortedDependencyLevelLowHigh,
                                                          2,
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    if (usuariosFiltrados.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          'No se encontraron usuarios',
                                          style: textTheme.bodyMedium,
                                        ),
                                      )
                                    else
                                      Expanded(
                                        child: ListView.separated(
                                          itemCount: usuariosFiltrados.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 10),
                                          itemBuilder: (context, index) {
                                            final usuario =
                                                usuariosFiltrados[index];
                                            return _UserCard(
                                              usuario: usuario,
                                              textTheme: textTheme,
                                              colorScheme: colorScheme,
                                              dateFormatter: dateFormatter,
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                );
                              },
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

          // -------- BOTÓN FLOTANTE --------
          Positioned(
            right: 25,
            bottom: 32,
            child: SafeArea(
              child: general_floatingbutton(
                Icons.add,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CrearUserPage(
                        onToggleTheme: widget.onToggleTheme,
                        onChangeLocale: widget.onChangeLocale,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Tarjeta de usuario estilo simple, con color de fondo y datos básicos.
class _UserCard extends StatelessWidget {
  final Usuario usuario;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final DateFormat dateFormatter;

  const _UserCard({
    required this.usuario,
    required this.textTheme,
    required this.colorScheme,
    required this.dateFormatter,
  });

  String get _dependenciaTexto {
    final raw = usuario.nivelDependencia.trim();
    if (raw.isEmpty) return 'Sin especificar';
    final upper = raw.toUpperCase();
    switch (upper) {
      case 'G1':
      case 'LEVE':
        return 'Leve';
      case 'G2':
      case 'MODERADA':
      case 'MODERADO':
        return 'Moderada';
      case 'G3':
      case 'SEVERA':
      case 'SEVERO':
        return 'Severa';
      default:
        return raw; // si viene otro valor, mostramos tal cual.
    }
  }

  Color _dependenciaBg(BuildContext context) {
    final raw = usuario.nivelDependencia.trim().toUpperCase();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (raw) {
      case 'G1':
      case 'LEVE':
        return isDark ? AppPalette.successDark : AppPalette.successLight;
      case 'G2':
      case 'MODERADA':
      case 'MODERADO':
        return isDark ? AppPalette.warningDark : AppPalette.warningLight;
      case 'G3':
      case 'SEVERA':
      case 'SEVERO':
        return isDark ? AppPalette.errorDark : AppPalette.errorLight;
      default:
        return colorScheme.surface;
    }
  }

  Color _dependenciaText(BuildContext context) {
    final raw = usuario.nivelDependencia.trim().toUpperCase();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (raw) {
      case 'G1':
      case 'LEVE':
        return isDark
            ? AppPalette.successFontDark
            : AppPalette.successFontLight;
      case 'G2':
      case 'MODERADA':
      case 'MODERADO':
        return isDark
            ? AppPalette.warningFontDark
            : AppPalette.warningFontLight;
      case 'G3':
      case 'SEVERA':
      case 'SEVERO':
        return isDark ? AppPalette.errorFontDark : AppPalette.errorFontLight;
      default:
        return colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fechaNacimiento = dateFormatter.format(usuario.f_nac);
    final direccion = usuario.direccion.trim();
    final depBg = _dependenciaBg(context);
    final depText = _dependenciaText(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${usuario.nombre} ${usuario.apellidos}',
                    style: textTheme.headlineLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                general_iconbutton(
                  Icons.edit,
                  onPressed: () {
                    //TODO: Implementar edición de usuario
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.cake, size: 18),
                const SizedBox(width: 6),
                Text(fechaNacimiento, style: textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.phone, size: 18),
                const SizedBox(width: 6),
                Text(usuario.telefono, style: textTheme.bodyMedium),
              ],
            ),
            if (direccion.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 18),
                  const SizedBox(width: 6),
                  Expanded(child: Text(direccion, style: textTheme.bodyMedium)),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: depBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _dependenciaTexto,
                style: textTheme.bodySmall?.copyWith(
                  color: depText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (usuario.contactosEmergencia.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Contactos de emergencia',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              ...usuario.contactosEmergencia.map(
                (contacto) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${contacto.nombre} ${contacto.apellidos}',
                          style: textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        contacto.telefono,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
