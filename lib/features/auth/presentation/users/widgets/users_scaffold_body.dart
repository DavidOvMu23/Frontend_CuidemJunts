import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/constants/app_constants.dart';

import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:intl/intl.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/users_page_enums.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/widgets/search_and_filter_section.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/widgets/users_future_list.dart';

// Cuerpo principal de la pantalla de usuarios — organiza el buscador, los filtros
// y la lista de usuarios dentro del área principal de la pantalla.
class UsersScaffoldBody extends StatelessWidget {
  // Estado actual de la lista de usuarios procedente del provider con polling.
  final AsyncValue<List<Usuario>> usuariosAsync;
  // Estado actual de los filtros y la ordenación
  final UsersPageFilter filtroSeleccionado;
  final UsersPageSort ordenSeleccionado;
  final String textoFiltro;

  // Funciones para aplicar filtros y ordenar
  final List<Usuario> Function(List<Usuario>) aplicarFiltros;
  // Se llaman cuando el usuario cambia cualquiera de los controles de búsqueda/filtro
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<UsersPageFilter> onFilterChanged;
  final ValueChanged<UsersPageSort> onSortChanged;

  // Función para mostrar el detalle de un usuario cuando el usuario pulsa su tarjeta
  final void Function(BuildContext, Usuario, DateFormat) onUsuarioTap;

  // Función para abrir el formulario de edición de un usuario
  final void Function(BuildContext, Usuario) onUsuarioEdit;

  const UsersScaffoldBody({
    super.key,
    required this.usuariosAsync,
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
    // Formato de fecha que usarán todas las tarjetas de usuario de esta pantalla
    final dateFormatter = DateFormat('dd/MM/yyyy');
    // Detectamos si estamos en escritorio para adaptar el diseño
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppBreakpoints.desktop;
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
                          usuariosAsync: usuariosAsync,
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
