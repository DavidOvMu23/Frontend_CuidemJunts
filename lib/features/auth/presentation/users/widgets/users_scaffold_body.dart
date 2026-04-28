import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:intl/intl.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/users_page_enums.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/widgets/search_and_filter_section.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/widgets/users_future_list.dart';

// Cuerpo principal de la pantalla de usuarios.
class UsersScaffoldBody extends StatelessWidget {
  final Future<List<Usuario>> usuariosFuture;
  final UsersPageFilter filtroSeleccionado;
  final UsersPageSort ordenSeleccionado;
  final String textoFiltro;

  // Funciones para aplicar filtros y ordenar
  final List<Usuario> Function(List<Usuario>) aplicarFiltros;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<UsersPageFilter> onFilterChanged;
  final ValueChanged<UsersPageSort> onSortChanged;

  // Función para mostrar el detalle de un usuario
  final void Function(BuildContext, Usuario, DateFormat) onUsuarioTap;

  final void Function(BuildContext, Usuario) onUsuarioEdit;

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
    required this.onUsuarioEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final horizontalPadding = isDesktop ? 20.0 : 12.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Contenedor principal con fondo de tarjeta
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Material(
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 22 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Sección de búsqueda y filtros
                      SearchAndFilterSection(
                        filtroSeleccionado: filtroSeleccionado,
                        onSearchChanged: onSearchChanged,
                        onFilterChanged: onFilterChanged,
                        isDesktop: isDesktop,
                      ),
                      const SizedBox(height: 10),
                      Divider(
                        height: 8,
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),

                      // 2. Lista de usuarios (ocupa el resto del espacio)
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
                          onUsuarioEdit: onUsuarioEdit,
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
