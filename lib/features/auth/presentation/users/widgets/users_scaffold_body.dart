import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:intl/intl.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/users_page_enums.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/widgets/search_and_filter_section.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/widgets/users_future_list.dart';

// -------- CUERPO PRINCIPAL DEL SCAFFOLD DE USUARIOS --------
// Widget que contiene toda la estructura del body de la página de usuarios.
// Incluye el título, la sección de búsqueda/filtros y la lista de usuarios.
class UsersScaffoldBody extends StatelessWidget {
  final Future<List<Usuario>> usuariosFuture;
  final UsersPageFilter filtroSeleccionado;
  final UsersPageSort ordenSeleccionado;
  final String textoFiltro;

  final List<Usuario> Function(List<Usuario>) aplicarFiltros;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<UsersPageFilter> onFilterChanged;
  final ValueChanged<UsersPageSort> onSortChanged;
  final void Function(BuildContext, Usuario, DateFormat) onUsuarioTap;

  const UsersScaffoldBody({
    super.key,
    required this.usuariosFuture,
    required this.filtroSeleccionado,
    required this.ordenSeleccionado,
    required this.textoFiltro,
    required this.aplicarFiltros,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.onUsuarioTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final l10n = AppLocalizations.of(context)!;

    return Padding(
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
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Material(
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.searchUsers,
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sección de búsqueda y filtros.
                      SearchAndFilterSection(
                        filtroSeleccionado: filtroSeleccionado,
                        onSearchChanged: onSearchChanged,
                        onFilterChanged: onFilterChanged,
                      ),
                      const SizedBox(height: 20),
                      Divider(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 10),

                      // -------- LISTA DE USUARIOS --------
                      // Solo esta sección es scrolleable.
                      Expanded(
                        child: UsersFutureList(
                          usuariosFuture: usuariosFuture,
                          aplicarFiltros: aplicarFiltros,
                          textoFiltro: textoFiltro,
                          filtroSeleccionado: filtroSeleccionado,
                          ordenSeleccionado: ordenSeleccionado,
                          onSortChanged: onSortChanged,
                          dateFormatter: dateFormatter,
                          onUsuarioTap: onUsuarioTap,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
