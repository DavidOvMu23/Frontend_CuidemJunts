# CuidemJunts - Frontend

Aplicación móvil de administración y seguimiento de llamadas y usuarios de CuidemJunts desarrollada en Flutter para la gestión y coordinación de cuidados de personas mayores y en situación de dependencia. Este proyecto sigue una arquitectura limpia (Clean Architecture) y utiliza un sistema de diseño propio para garantizar la coherencia visual y la reutilización de código.

## 🎨 Design System & Catálogo de Componentes

Hemos implementado un **Design System** personalizado para centralizar la apariencia de la aplicación. Todos los componentes visuales se encuentran en `lib/core/widgets/general_widgets.dart` y utilizan los estilos definidos en el `Theme` de la aplicación, evitando valores "hardcodeados" y facilitando el mantenimiento.

### Filosofía

- **Reutilización**: Evitamos duplicar código encapsulando elementos comunes.
- **Coherencia**: Todos los widgets heredan colores y tipografías del `ThemeData` (archivo `app_theme.dart`).
- **Flexibilidad**: Los componentes exponen propiedades (props) claras para adaptarse a diferentes contextos (iconos opcionales, callbacks, textos).

### 🧩 Widgets Personalizados

A continuación se describen los principales componentes desarrollados:

#### 1. Botones (Buttons)

Estandarizamos las interacciones principales de la app.

- **`general_filledbutton`**: Botón sólido para acciones primarias (ej. "Iniciar Sesión", "Guardar").
  - _Props_: `texto`, `onPressed`.
- **`general_textbutton`**: Botón sin fondo para acciones secundarias o enlaces (ej. "Cancelar").
  - _Props_: `texto`, `onPressed`.
- **`general_iconbutton`**: Botón que consiste solo en un icono, utilizando el color corporativo azul.
  - _Props_: `icono`, `onPressed`.
- **`general_floatingbutton`**: Botón flotante (FAB) para acciones destacadas en pantalla.
  - _Props_: `icono`, `onPressed`.

#### 2. Campos de Texto (Inputs)

Inputs estilizados con bordes redondeados y gestión de estados.

- **`general_textfield`**: Campo de texto versátil con soporte para iconos, texto oculto (password) y múltiples líneas.
  - _Props_: `texto` (hint), `obscureText`, `icono` (opcional), `controller`, `maxLines`.
- **`general_textfield_NoICON`**: Variante simplificada sin espacio para icono, optimizada para formularios densos.
  - _Props_: `texto`, `controller`, `borderRadius`.
- **`general_busqueda_textfield`**: Campo especializado para barras de búsqueda, con un radio de borde mayor (50.0) para diferenciarlo visualmente.
  - _Props_: `texto`, `onChanged`, `controller`.

#### 3. Feedback y Diálogos

Componentes para comunicar el resultado de acciones al usuario.

- **`general_snackbar`**: Notificación efímera en la parte inferior de la pantalla.
  - _Uso_: Mensajes informativos o de éxito.
- **`general_snackbar_error`**: Variante de snackbar con estilos de error (rojo) obtenidos del `Theme.colorScheme.error`.
  - _Uso_: Avisos de fallos de conexión o validación.
- **`showConfirmDialog`**: Diálogo modal asíncrono para confirmar acciones críticas.
  - _Props_: `title`, `content`, `confirmText`, `cancelText`, `onConfirm`.

#### 4. Navegación y Estructura

- **`appMainAppBar`**: Barra superior estándar con el logo/título centrado y botón de notificaciones integrado con badge.
- **`general_badge`**: Indicador numérico para notificaciones, reutilizable sobre cualquier icono.
- **`general_listtile`**: Elemento de lista para el menú lateral (Drawer) con estado de selección visual (cambio de color de fondo y texto).
  - _Props_: `icon`, `texto`, `selected`, `onTap`.

---

## 📂 Estructura del Proyecto

El proyecto sigue los principios de **Clean Architecture**:

```
lib/
├── app/                # Configuración global (Theme, Rutas)
├── core/               # Componentes compartidos (Widgets, Utils, L10n)
│   └── widgets/        # -> AQUÍ ESTÁ EL DESIGN SYSTEM
├── features/           # Módulos funcionales (Auth, Usuarios, etc.)
│   └── [feature]/
│       ├── data/       # Fuentes de datos y modelos
│       ├── domain/     # Entidades y lógica de negocio
│       └── presentation/ # Pantallas y widgets específicos
└── main.dart           # Punto de entrada
```
