# CuidemJunts — Frontend

Panel de administración y seguimiento de llamadas desarrollado con **Flutter**.  
Pensado para ejecutarse en navegador web o escritorio (macOS / Windows / Linux).

---

## Tecnologías

| Paquete | Versión | Para qué se usa |
|---|---|---|
| Flutter | SDK | Framework de UI multiplataforma |
| flutter_riverpod | ^3.0.0 | Gestión de estado global |
| dio | ^5.9.0 | Peticiones HTTP al backend |
| go_router | ^14.0.0 | Navegación entre pantallas |
| shared_preferences | ^2.2.3 | Guardar preferencias locales (tema, idioma) |
| flutter_secure_storage | ^9.2.4 | Guardar el token JWT de forma segura |
| intl + flutter_localizations | ^0.20.2 | Soporte multiidioma (es / ca / en) |

---

## Requisitos previos

- Flutter SDK **3.x** o superior
- Dart **3.x** o superior
- El [backend](../Backend_CuidemJunts/README.md) en marcha y accesible en `http://localhost:3000`

---

## Instalación y ejecución

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Ejecutar en navegador (recomendado)
flutter run -d chrome

# 3. O en escritorio
flutter run -d macos    # macOS
flutter run -d windows  # Windows
flutter run -d linux    # Linux
```

> Si quieres cambiar la URL del backend edita `baseUrl` en `lib/features/auth/data/datasources/dio_client.dart`.

---

## Estructura del proyecto

```
lib/
├── main.dart                    # Punto de entrada de la app
├── app/
│   ├── app.dart                 # Widget raíz (MaterialApp, tema, idioma)
│   └── theme/
│       ├── app_palette.dart     # Todos los colores (claro y oscuro)
│       └── app_theme.dart       # ThemeData global (AppBar, botones, inputs…)
├── core/
│   ├── constants/
│   │   └── app_constants.dart   # Constantes globales (roles, estados, breakpoints)
│   ├── l10n/                    # Textos traducidos (ARB) — generado automáticamente
│   ├── navigation/
│   │   └── navigator_key.dart   # Clave global para navegar desde interceptores
│   └── widgets/
│       ├── general_widgets.dart # Biblioteca de widgets reutilizables
│       ├── loading_skeleton.dart# Animaciones de carga tipo "esqueleto"
│       └── responsive_form_body.dart # Formulario adaptable a pantalla ancha/estrecha
└── features/
    └── auth/
        ├── data/
        │   ├── datasources/     # Servicios HTTP (DioClient, JwtInterceptor, servicios por entidad)
        │   └── models/          # Modelos de datos (Trabajador, Usuario, Grupo, Llamadas…)
        └── presentation/
            ├── pages/           # Pantallas completas (login, home, trabajadores, grupos…)
            ├── providers/       # Providers de Riverpod (auth, llamadas, notificaciones…)
            ├── calls/           # Widgets y enums de la sección de llamadas
            ├── emergency_contacts/ # Widgets de contactos de emergencia
            ├── home/            # Widgets del panel principal (tarjetas, calendario…)
            ├── users/           # Widgets de la sección de usuarios/pacientes
            └── workers/         # Widgets de la sección de trabajadores
```

---

## Arquitectura

La app sigue los principios de **Clean Architecture** de forma práctica:

- **Capa de datos** (`data/`): modelos y servicios HTTP. Los servicios hablan con el backend usando Dio.
- **Capa de estado** (`providers/`): Riverpod gestiona el estado global. Cada dominio tiene su propio provider.
- **Capa de presentación** (`pages/` + `widgets/`): pantallas y widgets que leen el estado y desencadenan acciones.

El token JWT se añade automáticamente a cada petición mediante `JwtInterceptor`. Si el servidor responde con 401, se cierra la sesión y se redirige al login.

---

## Multiidioma

La app soporta tres idiomas: español (`es`), catalán (`ca`) e inglés (`en`).  
Los textos se gestionan con archivos ARB en `lib/core/l10n/`:

```
app_es.arb   # Español (idioma por defecto)
app_ca.arb   # Catalán
app_en.arb   # Inglés
```

Para añadir un nuevo texto: agrégalo en los tres archivos ARB y ejecuta `flutter gen-l10n` (o simplemente `flutter run`).

---

## Roles de usuario

| Rol | Acceso |
|---|---|
| **Supervisor** | Gestión completa: trabajadores, grupos, usuarios, llamadas, contactos |
| **Teleoperador** | Vista de sus llamadas del día y notificaciones propias |

---

## Temas

La app soporta tema **claro** y **oscuro**. El usuario puede cambiarlo desde la pantalla de Preferencias. La preferencia se guarda localmente y persiste entre sesiones.
