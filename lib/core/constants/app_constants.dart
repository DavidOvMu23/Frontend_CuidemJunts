// -------- CONSTANTES GLOBALES DE LA APP --------
// Aquí guardamos valores fijos que se usan en varios sitios del código.
// Centralizar las constantes evita errores por escribir mal una cadena de texto
// y facilita cambiarlas en el futuro desde un único sitio.

// Roles de usuario que puede tener una persona en el sistema
// Se comparan con el rol que devuelve el servidor al hacer login
abstract final class AppRoles {
  // El supervisor gestiona llamadas, trabajadores y grupos desde el panel web
  static const String supervisor = 'supervisor';
  // El teleoperador realiza las llamadas de seguimiento a los usuarios
  static const String teleoperador = 'teleoperador';
}

// Estados posibles de una llamada en el sistema
// Estos valores deben coincidir exactamente con los que usa el backend (NestJS)
abstract final class CallStatus {
  // La llamada se realizó y el usuario respondió
  static const String completada = 'completada';
  // La llamada está programada pero aún no se ha realizado
  static const String pendiente = 'pendiente';
  // Se intentó llamar pero el usuario no respondió
  static const String noContesto = 'no_contesto';
  // La llamada fue cancelada antes de realizarse
  static const String cancelada = 'cancelada';
}

// Puntos de corte de ancho de pantalla para adaptar el diseño al dispositivo
// Por debajo de cada valor se usa un diseño más compacto (móvil/tablet)
// Por encima se usa el diseño de escritorio con más espacio
abstract final class AppBreakpoints {
  // A partir de este ancho (px) se usa el layout de escritorio con más padding y columnas anchas
  static const double desktop = 1100.0;

  // A partir de este ancho la barra lateral (sidebar) se muestra fija y siempre visible
  static const double shell = 1080.0;

  // A partir de este ancho los formularios se muestran en dos columnas en lugar de una
  static const double formWide = 700.0;
}
