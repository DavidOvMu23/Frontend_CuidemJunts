import 'package:flutter/material.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:intl/intl.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/users_page_enums.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/widgets/user_card.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/users/widgets/users_sort_bottom_sheet.dart';

// Lista de usuarios que gestiona los estados de carga (FutureBuilder).
class UsersFutureList extends StatelessWidget {
  final Future<List<Usuario>> usuariosFuture;
  final List<Usuario> Function(List<Usuario>) aplicarFiltros;
  final String textoFiltro;
  final UsersPageFilter filtroSeleccionado;
  final UsersPageSort ordenSeleccionado;
  final ValueChanged<UsersPageSort> onSortChanged;
  final DateFormat dateFormatter;
  final void Function(BuildContext, Usuario, DateFormat) onUsuarioTap;

  const UsersFutureList({
    super.key,
    required this.usuariosFuture,
    required this.aplicarFiltros,
    required this.textoFiltro,
    required this.filtroSeleccionado,
    required this.ordenSeleccionado,
    required this.onSortChanged,
    required this.dateFormatter,
    required this.onUsuarioTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // FutureBuilder que gestiona los estados de carga, error y vacío.
    // Lo que hacemos es que, según el estado de la FutureBuilder, mostramos un widget u otro.
    return FutureBuilder<List<Usuario>>(
      future: usuariosFuture,
      builder: (context, snapshot) {
        // 1. Estado de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Estado de error
        if (snapshot.hasError) {
          return Center(
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
          );
        }

        final usuarios = snapshot.data ?? [];

        // 3. Estado vacío (sin usuarios en la BD)
        if (usuarios.isEmpty) {
          return Center(
            child: Text(
              'No se encontraron usuarios',
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
                general_iconbutton(
                  ordenSeleccionado == UsersPageSort.noneAZ
                      ? Icons.filter_list_off
                      : Icons.filter_list,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) =>
                          UsersSortBottomSheet(onSortSelected: onSortChanged),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 2),

            // Mensaje informativo
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: colorScheme.primary),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    l10n.usersPreliminarView,
                    style: textTheme.bodySmall,
                  ),
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
