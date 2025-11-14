import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/supervisor/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

class LlamadasPage extends StatefulWidget {
  // Callback que cambia el tema de la app.
  // Si es true, activa modo oscuro; si es false, modo claro.
  // Se utiliza para que el cambio de tema afecte a toda la app.
  final void Function(bool) onToggleTheme;

  // Callback que cambia el idioma de la app.
  // Se utiliza para que el cambio de idioma afecte a toda la app.
  final void Function(Locale) onChangeLocale;

  const LlamadasPage({
    super.key,
    required this.onToggleTheme,
    required this.onChangeLocale,
  });

  @override
  State<LlamadasPage> createState() => _LlamadasPageState();
}

// Filtros disponibles de la busqueda de usuarios.
enum CallFilter { all, complete, pending, incomplete, g1, g2, g3 }

// Modos de ordenación disponibles para la lista de usuarios.
enum CallSort {
  none,
  dateLatest,
  nameAZ,
  nameZA,
  callDurationShortLong,
  callDurationLongShort,
  dependencyHighLow,
  dependencyLowHigh,
}

class _LlamadasPageState extends State<LlamadasPage> {
  // Filtro de usuarios seleccionado actualmente.
  late CallFilter filtroSeleccionado;
  late String textoFiltro = '';

  /// Orden actualmente seleccionado para la lista.
  CallSort ordenSeleccionado = CallSort.none;

  @override
  void initState() {
    super.initState();
    filtroSeleccionado = CallFilter.all;
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos tipografías y paleta del tema actual para mantener
    // estilos consistentes en toda la app.
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Textos traducidos (según el idioma seleccionado en la app).
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // -------- BARRA SUPERIOR --------
      // AppBar: barra superior con título centrado e iconos de acción a la derecha.
      appBar: appMainAppBar(
        onNotifications: () {
          // TODO: Acción al pulsar el icono de notificaciones.
        },
      ),

      // -------- MENÚ LATERAL (DRAWER) --------
      // Drawer: menú que se abre desde el lateral con opciones de navegación.
      drawer: appDrawer(
        context: context,
        selected: DrawerItem.calls,
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
        onTapUsers: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UsersPage(
                onToggleTheme: widget.onToggleTheme,
                onChangeLocale: widget.onChangeLocale,
              ),
            ),
          );
        },
        onTapTelemarketers: () {},
        onTapNotifications: () {},
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
      // Usamos un Stack para poder colocar el botón flotante encima del contenido scrolleable.
      body: Stack(
        children: [
          //El posicined fill hace que el SingleChildScrollView ocupe todo el espacio disponible
          Positioned.fill(
            child: SingleChildScrollView(
              // SingleChildScrollView permite que toda la columna sea scrolleable
              padding: const EdgeInsets.symmetric(horizontal: 16.0),

              // ConstrainedBox sirve para que la columna ocupe todo el ancho disponible
              child: ConstrainedBox(
                // Hacemos que la columna ocupe todo el ancho disponible.

                // Esto es necesario para que los elementos dentro de la columna
                // (como las "tarjetas" de Material) ocupen todo el ancho posible.
                constraints: const BoxConstraints(minWidth: double.infinity),

                // Columna principal con todo el contenido de la página.
                child: Column(
                  // Alineamos todo a la izquierda.
                  crossAxisAlignment: CrossAxisAlignment.start,

                  // Elementos de la columna
                  children: [
                    // Título principal
                    Text(
                      l10n.calls,
                      style: textTheme.titleMedium?.copyWith(fontSize: 27),
                    ),
                    // Subtítulo
                    Text(l10n.superviseCalls, style: textTheme.bodyMedium),
                    const SizedBox(height: 20),

                    // Tarjeta principal con filtros y lista de usuarios
                    Material(
                      borderRadius: BorderRadius.circular(30),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),

                        //Columna en la que van los filtros y la lista de usuarios
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título de la sección de búsqueda
                            Text(
                              l10n.allCalls,
                              textAlign: TextAlign.left,
                              style: textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // TextField de búsqueda
                            general_busqueda_textfield(
                              l10n.searchCalls,
                              icono: Icons.search,
                              onChanged: (value) {
                                setState(() {
                                  textoFiltro = value;
                                });
                              },
                            ),
                            const SizedBox(height: 20),

                            //Row del filtro de búsqueda
                            Row(
                              children: [
                                // Ícono que indica si hay filtro activo o no
                                Icon(
                                  // Si el filtro seleccionado no es "Todos", mostramos el icono de filtro activo
                                  filtroSeleccionado != CallFilter.all
                                      ? Icons.filter_alt
                                      : Icons.filter_alt_off,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 16),

                                //Expanded para que el DropdownButtonFormField ocupe todo el espacio restante
                                Expanded(
                                  //Dropdown para seleccionar el filtro de búsqueda
                                  child: DropdownButtonFormField<CallFilter>(
                                    value: filtroSeleccionado,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    borderRadius: BorderRadius.circular(12),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),

                                    //Elementos del dropdown
                                    items: [
                                      DropdownMenuItem<CallFilter>(
                                        //seleccionamos el filtro "Todos"
                                        value: CallFilter.all,
                                        child: Text(l10n.allCalls),
                                      ),
                                      DropdownMenuItem<CallFilter>(
                                        value: CallFilter.complete,
                                        child: Text(l10n.callCompleted),
                                      ),
                                      DropdownMenuItem<CallFilter>(
                                        value: CallFilter.pending,
                                        child: Text(l10n.callPending),
                                      ),
                                      DropdownMenuItem<CallFilter>(
                                        value: CallFilter.incomplete,
                                        child: Text(l10n.callNoAnswer),
                                      ),
                                      DropdownMenuItem<CallFilter>(
                                        value: CallFilter.g1,
                                        child: Text(
                                          l10n.searchModerateDependency,
                                        ),
                                      ),
                                      DropdownMenuItem<CallFilter>(
                                        value: CallFilter.g2,
                                        child: Text(l10n.searchHighDependency),
                                      ),
                                      DropdownMenuItem<CallFilter>(
                                        value: CallFilter.g3,
                                        child: Text(
                                          l10n.searchSevereDependency,
                                        ),
                                      ),
                                    ],
                                    // Al cambiar el valor seleccionado, actualizamos el estado
                                    onChanged: (CallFilter? newValue) {
                                      setState(() {
                                        filtroSeleccionado =
                                            newValue ?? CallFilter.all;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Divider(
                              color: colorScheme.primary.withOpacity(0.3),
                            ),

                            // Texto que muestra el total de usuarios o usuarios encontrados
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    //Si no hay nada escrito en el textfield de búsqueda si no hay filtro, mostramos el total de usuarios del programa
                                    textoFiltro.isEmpty &&
                                            filtroSeleccionado == CallFilter.all
                                        ? l10n.totalCalls +
                                              ': 0' //TODO: cambiar 0 por el total real de la base de datos
                                        : l10n.callsFound +
                                              ': 0', //TODO: cambiar 0 por el total real de usuarios encontrados
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),

                                //Listar usuarios según el filtro y el texto de búsqueda
                                general_iconbutton(
                                  // Si hay algún tipo de orden aplicado, mostramos el icono de filtro activo si no, el de filtro inactivo
                                  ordenSeleccionado == CallSort.none
                                      ? Icons.filter_list_off
                                      : Icons.filter_list,

                                  // Acción al pulsar el botón de ordenación
                                  onPressed: () {
                                    //abrimos un modal bottom sheet para seleccionar el tipo de orden
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) => Padding(
                                        padding: const EdgeInsets.all(16.0),

                                        // Columna con las opciones de ordenación
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              l10n.sortType,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 12),

                                            // Opciones de ordenación
                                            general_listtile(
                                              context: context,
                                              icon: Icons.filter_list_off,
                                              texto: l10n.noSortedCalls,
                                              onTap: () {
                                                setState(() {
                                                  // usamos el valor `none` para indicar que no hay orden activo
                                                  ordenSeleccionado =
                                                      CallSort.none;
                                                });
                                                general_snackbar(
                                                  context,
                                                  l10n.noSortedUsers,
                                                  2,
                                                );
                                                Navigator.pop(context);
                                                general_snackbar(
                                                  context,
                                                  l10n.noSortedUsers,
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
                                                      CallSort.nameAZ;
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
                                              icon: Icons.sort_by_alpha,
                                              texto: l10n.sortNameZA,
                                              onTap: () {
                                                setState(() {
                                                  // usamos un valor distinto de `all` para indicar que hay orden activo
                                                  ordenSeleccionado =
                                                      CallSort.dateLatest;
                                                });
                                                Navigator.pop(context);
                                                // TODO: aplicar orden real de A a Z sobre la lista de usuarios
                                                general_snackbar(
                                                  context,
                                                  l10n.sortedZASnackbar,
                                                  2,
                                                );
                                              },
                                            ),

                                            general_listtile(
                                              context: context,
                                              icon: Icons.access_time,
                                              texto: l10n
                                                  .sortCallDurationLongShort,
                                              onTap: () {
                                                setState(() {
                                                  ordenSeleccionado = CallSort
                                                      .callDurationLongShort;
                                                });
                                                Navigator.pop(context);
                                                general_snackbar(
                                                  context,
                                                  l10n.sortCallDurationLongShort,
                                                  2,
                                                );
                                              },
                                            ),
                                            general_listtile(
                                              context: context,
                                              icon: Icons.access_time,
                                              texto: l10n
                                                  .sortCallDurationShortLong,
                                              onTap: () {
                                                setState(() {
                                                  ordenSeleccionado = CallSort
                                                      .callDurationShortLong;
                                                });
                                                Navigator.pop(context);
                                                general_snackbar(
                                                  context,
                                                  l10n.sortCallDurationShortLong,
                                                  2,
                                                );
                                              },
                                            ),
                                            general_listtile(
                                              context: context,
                                              icon: Icons.bar_chart,
                                              texto: l10n.sortDependencyHighLow,
                                              onTap: () {
                                                setState(() {
                                                  ordenSeleccionado = CallSort
                                                      .dependencyHighLow;
                                                });
                                                Navigator.pop(context);
                                                general_snackbar(
                                                  context,
                                                  l10n.sortDependencyHighLow,
                                                  2,
                                                );
                                              },
                                            ),
                                            general_listtile(
                                              context: context,
                                              icon: Icons.bar_chart,
                                              texto: l10n.sortDependencyLowHigh,
                                              onTap: () {
                                                setState(() {
                                                  ordenSeleccionado = CallSort
                                                      .dependencyLowHigh;
                                                });
                                                Navigator.pop(context);
                                                general_snackbar(
                                                  context,
                                                  l10n.sortDependencyLowHigh,
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

                            //TODO: Implementar la lista de usuarios
                            //Aquí irá la lista de usuarios filtrados y ordenados por el momento hay una card
                            const SizedBox(height: 10),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Aquí irán todas las llamadas",
                                      style: textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Botón flotante
          Positioned(
            right: 24,
            bottom: 32,
            child: SafeArea(
              child: general_floatingbutton(
                Icons.add,
                onPressed: () {
                  //TODO: IMPLEMENTAR AÑADIR LLAMADA, se edita buscandola
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
