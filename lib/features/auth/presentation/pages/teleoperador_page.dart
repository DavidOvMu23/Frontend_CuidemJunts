import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/supervisor/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/llamadas_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

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
enum UserFilter { all, active, inactive, g1, g2, g3 }

// Modos de ordenación disponibles para la lista de usuarios.
enum UserSort {
  none,
  nameZA,
  dependencyHighLow,
  dependencyLowHigh,
  accountStatusOrder,
}

class _UsersPageState extends State<UsersPage> {
  // Filtro de usuarios seleccionado actualmente.
  late UserFilter filtroSeleccionado;
  late String textoFiltro = '';

  /// Orden actualmente seleccionado para la lista.
  UserSort ordenSeleccionado = UserSort.none;

  @override
  void initState() {
    super.initState();
    filtroSeleccionado = UserFilter.all;
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
                      l10n.telemarketers,
                      style: textTheme.titleMedium?.copyWith(fontSize: 27),
                    ),
                    // Subtítulo
                    Text(l10n.manageWorkers, style: textTheme.bodyMedium),
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
                              l10n.searchUsers,
                              textAlign: TextAlign.left,
                              style: textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // TextField de búsqueda
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

                            //Row del filtro de búsqueda
                            Row(
                              children: [
                                // Ícono que indica si hay filtro activo o no
                                Icon(
                                  // Si el filtro seleccionado no es "Todos", mostramos el icono de filtro activo
                                  filtroSeleccionado != UserFilter.all
                                      ? Icons.filter_alt
                                      : Icons.filter_alt_off,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 16),

                                //Expanded para que el DropdownButtonFormField ocupe todo el espacio restante
                                Expanded(
                                  //Dropdown para seleccionar el filtro de búsqueda
                                  child: DropdownButtonFormField<UserFilter>(
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
                                      DropdownMenuItem<UserFilter>(
                                        //seleccionamos el filtro "Todos"
                                        value: UserFilter.all,
                                        child: Text(l10n.searchAllUsers),
                                      ),
                                    ],
                                    // Al cambiar el valor seleccionado, actualizamos el estado
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
                                            filtroSeleccionado == UserFilter.all
                                        ? l10n.totalUsers +
                                              ': 0' //TODO: cambiar 0 por el total real de la base de datos
                                        : l10n.usersFound +
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
                                  ordenSeleccionado == UserSort.none
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
                                              texto: l10n.noSortedUsers,
                                              onTap: () {
                                                setState(() {
                                                  // usamos el valor `none` para indicar que no hay orden activo
                                                  ordenSeleccionado =
                                                      UserSort.none;
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
                                                // Selecciona un tipo de orden distinto al predeterminado:
                                                // actualizamos el estado para que el icono cambie a filter_list
                                                setState(() {
                                                  // usamos un valor distinto de `all` para indicar que hay orden activo
                                                  ordenSeleccionado =
                                                      UserSort.nameZA;
                                                });
                                                Navigator.pop(context);
                                                setState(() {
                                                  ordenSeleccionado =
                                                      UserSort.nameZA;
                                                });
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
                                              icon: Icons.bar_chart,
                                              texto: l10n.sortDependencyHighLow,
                                              onTap: () {
                                                setState(() {
                                                  ordenSeleccionado = UserSort
                                                      .dependencyHighLow;
                                                });
                                                Navigator.pop(context);
                                                // TODO: ordenar usuarios por nivel de dependencia de alto a bajo
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
                                              texto: l10n.sortDependencyLowHigh,
                                              onTap: () {
                                                setState(() {
                                                  ordenSeleccionado = UserSort
                                                      .dependencyLowHigh;
                                                });
                                                Navigator.pop(context);
                                                // TODO: ordenar usuarios por nivel de dependencia de bajo a alto
                                                general_snackbar(
                                                  context,
                                                  l10n.sortedDependencyLevelLowHigh,
                                                  2,
                                                );
                                              },
                                            ),
                                            general_listtile(
                                              context: context,
                                              icon: Icons.check,
                                              texto: l10n.sortedStatusAccount,
                                              onTap: () {
                                                setState(() {
                                                  ordenSeleccionado = UserSort
                                                      .accountStatusOrder;
                                                });
                                                Navigator.pop(context);
                                                general_snackbar(
                                                  context,
                                                  l10n.sortedStatusAccount,
                                                  2,
                                                );
                                                //TODO: ordenar usuarios (primero activos y luego inactivos)
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
                                      "Aquí irán los usuarios",
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
                  //TODO: IMPLEMENTAR AÑADIR USUARIO, se edita buscandolo
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
