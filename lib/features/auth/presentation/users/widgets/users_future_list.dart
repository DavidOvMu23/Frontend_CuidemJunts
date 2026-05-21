import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/core/widgets/loading_skeleton.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';

import 'package:intl/intl.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/users_page_enums.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/widgets/user_card.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/widgets/users_sort_bottom_sheet.dart';

// Lista de usuarios que se reconstruye automáticamente cuando cambia el
// AsyncValue<List<Usuario>> recibido. La fuente del AsyncValue es el
// StreamProvider con polling, así que la lista se refresca sola en tiempo real.
class UsersFutureList extends StatelessWidget {
  // Estado actual de la lista de usuarios (cargando / error / datos).
  final AsyncValue<List<Usuario>> usuariosAsync;
  // Función que aplica los filtros y el orden activos sobre la lista completa
  final List<Usuario> Function(List<Usuario>) aplicarFiltros;
  // Texto que el usuario ha escrito en el buscador
  final String textoFiltro;
  // Filtro de dependencia activo
  final UsersPageFilter filtroSeleccionado;
  // Criterio de ordenación activo
  final UsersPageSort ordenSeleccionado;
  // Se llama cuando el usuario elige un nuevo criterio de orden
  final ValueChanged<UsersPageSort> onSortChanged;
  // Formato de fecha para mostrar la fecha de nacimiento en las tarjetas
  final DateFormat dateFormatter;
  // Se llama cuando el usuario pulsa una tarjeta para ver el detalle
  final void Function(BuildContext, Usuario, DateFormat) onUsuarioTap;
  // Se llama cuando el usuario quiere editar un usuario
  final void Function(BuildContext, Usuario) onUsuarioEdit;

  const UsersFutureList({
    super.key,
    required this.usuariosAsync,
    required this.aplicarFiltros,
    required this.textoFiltro,
    required this.filtroSeleccionado,
    required this.ordenSeleccionado,
    required this.onSortChanged,
    required this.dateFormatter,
    required this.onUsuarioTap,
    required this.onUsuarioEdit,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return usuariosAsync.when(
      // 1. Estado de carga inicial: solo se muestra el esqueleto cuando aún no
      // tenemos datos previos; tras la primera carga, las actualizaciones del
      // polling no provocan flicker porque el AsyncValue conserva el valor.
      loading: () => const AppSkeletonList(count: 4),
      // 2. Estado de error
      error: (_, __) => Center(
        child: Card(
          margin: EdgeInsets.zero,
          color: colorScheme.error.withValues(alpha: 0.2),
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
      ),
      data: (usuarios) {
        // 3. Estado vacío (sin usuarios en la BD)
        if (usuarios.isEmpty) {
          return Center(
            child: Text(
              l10n.noUsersFounds,
              style: textTheme.bodyMedium,
            ),
          );
        }

        // Aplicamos los filtros y ordenación sobre los datos recibidos
        final usuariosFiltrados = aplicarFiltros(usuarios);
        final totalText =
            textoFiltro.isEmpty && filtroSeleccionado == UsersPageFilter.all
            ? '${l10n.totalUsers}: ${usuarios.length}'
            : '${l10n.usersFound} ${usuariosFiltrados.length}';

        return Column(
          children: [
            // Cabecera de la lista: contador y botón de ordenar
            Row(
              children: [
                Expanded(
                  child: Text(
                    totalText,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    ordenSeleccionado == UsersPageSort.noneAZ
                        ? Icons.filter_list_off
                        : Icons.filter_list,
                    color: colorScheme.primary,
                  ),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) =>
                          UsersSortBottomSheet(onSortSelected: onSortChanged),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 4. Lista filtrada vacía (no hay coincidencias)
            if (usuariosFiltrados.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(l10n.noUsersFounds, style: textTheme.bodyMedium),
              )
            else
              // 5. Lista de usuarios
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: usuariosFiltrados.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final usuario = usuariosFiltrados[index];
                    return UserCard(
                      usuario: usuario,
                      textTheme: textTheme,
                      colorScheme: colorScheme,
                      dateFormatter: dateFormatter,
                      onTap: () =>
                          onUsuarioTap(context, usuario, dateFormatter),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
