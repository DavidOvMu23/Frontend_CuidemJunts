import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_cuidemjunts/features/auth/data/models/usuario.dart';
import 'package:frontend_cuidemjunts/features/auth/data/datasources/contacto_emergencia_service.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/login_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/preferences_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/home_supervisor_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/calls_page.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/users_page.dart';
import 'package:frontend_cuidemjunts/core/widgets/general_widgets.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/widgets/supervisor_drawer.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/pages/trabajador_page.dart';
import 'package:intl/intl.dart';
import 'package:frontend_cuidemjunts/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend_cuidemjunts/core/l10n/app_localizations.dart';

// -------- PANTALLA DE CONTACTOS DE EMERGENCIA --------
// Controlador principal de la vista de contactos de emergencia
// Gestiona el estado (búsqueda, ordenación) y la carga de datos
class EmergencyContactsPage extends ConsumerStatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  ConsumerState<EmergencyContactsPage> createState() =>
      _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends ConsumerState<EmergencyContactsPage> {
  // Servicio para peticiones al backend
  late final ContactoEmergenciaService _contactoService;

  // Cache del Future para evitar recargas innecesarias al reconstruir el widget
  late Future<List<ContactoEmergencia>> _contactosFuture;

  // Estado local de la interfaz
  String textoFiltro = '';

  @override
  void initState() {
    super.initState();
    _contactoService = ContactoEmergenciaService(
      baseUrl: 'http://localhost:3000',
    );
    _contactosFuture = _cargarContactos(); // Iniciamos la carga
  }

  // Obtiene la lista completa de contactos de emergencia del servidor
  Future<List<ContactoEmergencia>> _cargarContactos() async {
    final contactos = await _contactoService.getAll();
    return contactos;
  }

  // --- Métodos para actualizar el estado desde los widgets hijos ---

  // Actualiza el texto de búsqueda
  void _onSearchChanged(String value) {
    setState(() => textoFiltro = value);
  }

  // Muestra el detalle de un contacto
  void _mostrarDetalleContacto(
    BuildContext context,
    ContactoEmergencia contacto,
    DateFormat dateFormatter,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${contacto.nombre} ${contacto.apellidos}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(l10n.phone, contacto.telefono),
            _buildInfoRow(l10n.relation, contacto.relacion),
            if (contacto.dniUsuarioRef != null)
              _buildInfoRow(l10n.refersToUser, contacto.dniUsuarioRef!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Filtra y ordena la lista de contactos según el estado actual
  List<ContactoEmergencia> _aplicarFiltros(List<ContactoEmergencia> contactos) {
    final query = textoFiltro.trim().toLowerCase();

    // Filtrado por texto (nombre completo o teléfono)
    final filtrados = contactos.where((contacto) {
      final nombreCompleto = '${contacto.nombre} ${contacto.apellidos}'
          .toLowerCase();
      return query.isEmpty ||
          nombreCompleto.contains(query) ||
          contacto.telefono.contains(query) ||
          contacto.relacion.toLowerCase().contains(query);
    }).toList();

    // Ordenación alfabética por nombre
    filtrados.sort((a, b) => a.nombre.compareTo(b.nombre));

    return filtrados;
  }

  @override
  Widget build(BuildContext context) {
    // -------- OBTENER NOMBRE DEL USUARIO DESDE RIVERPOD --------
    final authState = ref.watch(authProvider);
    final userName = authState.nombre;
    final userRole = authState.rol;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final l10n = AppLocalizations.of(context)!;

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
        selected: DrawerItem.emergencyContacts,
        onTapHome: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeSupervisorPage()),
          );
        },
        onTapCalls: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LlamadasPage()),
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
        onTapEmergencyContacts: () {
          Navigator.pop(
            context,
          ); // Solo cerramos el drawer porque ya estamos aquí
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la sección
            Text(
              l10n.emergencyContacts,
              style: textTheme.titleMedium?.copyWith(fontSize: 27),
            ),
            Text(l10n.searchEmergencyContacts, style: textTheme.bodyMedium),
            const SizedBox(height: 7),

            // Contenedor principal con fondo blanco/tarjeta
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
                          l10n.searchEmergencyContacts,
                          style: textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 5),

                        // Barra de búsqueda
                        general_busqueda_textfield(
                          l10n.searchEmergencyContacts,
                          icono: Icons.search,
                          onChanged: _onSearchChanged,
                        ),
                        const SizedBox(height: 8),
                        Divider(
                          height: 8,
                          color: colorScheme.primary.withValues(alpha: 0.3),
                        ),

                        // Lista de contactos
                        Expanded(
                          child: FutureBuilder<List<ContactoEmergencia>>(
                            future: _contactosFuture,
                            builder: (context, snapshot) {
                              // 1. Estado de carga
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              // 2. Estado de error
                              if (snapshot.hasError) {
                                return Center(
                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    color: colorScheme.error.withValues(
                                      alpha: 0.2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        '${l10n.error}: ${snapshot.error}',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.error,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final contactos = snapshot.data ?? [];

                              // 3. Estado vacío
                              if (contactos.isEmpty) {
                                return Center(
                                  child: Text(
                                    l10n.noEmergencyContactsFound,
                                    style: textTheme.bodyMedium,
                                  ),
                                );
                              }

                              // Aplicamos los filtros
                              final contactosFiltrados = _aplicarFiltros(
                                contactos,
                              );
                              final totalText = textoFiltro.isEmpty
                                  ? 'Total: ${contactos.length}'
                                  : '${l10n.noResultsFound}: ${contactosFiltrados.length}';

                              return Column(
                                children: [
                                  // Cabecera: contador
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          totalText,
                                          style: textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Lista de tarjetas
                                  Expanded(
                                    child: contactosFiltrados.isEmpty
                                        ? Center(
                                            child: Text(
                                              l10n.noResultsFound,
                                              style: textTheme.bodyMedium,
                                            ),
                                          )
                                        : ListView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount:
                                                contactosFiltrados.length,
                                            itemBuilder: (context, index) {
                                              final contacto =
                                                  contactosFiltrados[index];
                                              return Card(
                                                margin: const EdgeInsets.only(
                                                  bottom: 12,
                                                ),
                                                child: ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundColor: colorScheme
                                                        .primaryContainer,
                                                    child: Icon(
                                                      Icons.contact_emergency,
                                                      color: colorScheme
                                                          .onPrimaryContainer,
                                                    ),
                                                  ),
                                                  title: Text(
                                                    '${contacto.nombre} ${contacto.apellidos}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${l10n.phone}: ${contacto.telefono}',
                                                      ),
                                                      Text(
                                                        '${l10n.relation}: ${contacto.relacion}',
                                                      ),
                                                      if (contacto
                                                              .dniUsuarioRef !=
                                                          null)
                                                        Text(
                                                          '${l10n.refersToUser}: ${contacto.dniUsuarioRef}',
                                                        ),
                                                    ],
                                                  ),
                                                  isThreeLine: true,
                                                  onTap: () =>
                                                      _mostrarDetalleContacto(
                                                        context,
                                                        contacto,
                                                        dateFormatter,
                                                      ),
                                                ),
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
            ),
          ],
        ),
      ),
    );
  }
}
