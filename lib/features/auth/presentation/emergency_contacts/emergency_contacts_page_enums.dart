// Filtros disponibles en la página de contactos de emergencia.
// Permiten ver todos los contactos o solo un tipo concreto.
enum ContactoEmergenciaFilter {
  // Muestra todos los contactos de emergencia sin excepción
  all,
  // Muestra solo los contactos que pertenecen al sistema (servicios oficiales
  // como bomberos, policía, ambulancias, etc.)
  sistema,
  // Muestra solo los contactos externos (familiares, vecinos u otras personas
  // de confianza del usuario dependiente que no son servicios oficiales)
  externo,
}

// Criterios de ordenación disponibles para la lista de contactos de emergencia.
// Permiten reorganizar la lista para encontrar un contacto más fácilmente.
enum ContactoEmergenciaSort {
  // Ordenar alfabéticamente por nombre: de la A a la Z
  nameAZ,
  // Ordenar alfabéticamente por nombre: de la Z a la A
  nameZA,
  // Ordenar poniendo primero los contactos del sistema (servicios oficiales)
  sistemaPrimero,
  // Ordenar poniendo primero los contactos externos (personas de confianza)
  externoPrimero,
}
