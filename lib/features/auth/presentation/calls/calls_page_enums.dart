// Filtros disponibles en la página de llamadas.
// Permiten al supervisor ver solo el subconjunto de llamadas que le interesa.
enum CallsPageFilter {
  // Muestra todas las llamadas sin excepción
  all,
  // Muestra solo las llamadas que ya se han realizado con éxito
  complete,
  // Muestra solo las llamadas que aún no se han realizado
  pending,
  // Muestra solo las llamadas que se intentaron pero no se completaron
  incomplete,
}

// Criterios de ordenación disponibles para la lista de llamadas.
// Permiten al supervisor reorganizar la lista según lo que necesite ver primero.
enum CallsPageSort {
  // Sin ordenación especial: orden por defecto del servidor
  none,
  // Ordenar por fecha: las más recientes primero
  dateLatest,
  // Ordenar por nombre del usuario: de la A a la Z
  nameAZ,
  // Ordenar por nombre del usuario: de la Z a la A
  nameZA,
  // Ordenar por duración de llamada: las más cortas primero
  callDurationShortLong,
  // Ordenar por duración de llamada: las más largas primero
  callDurationLongShort,
  // Ordenar por nivel de dependencia del usuario: mayor dependencia primero
  dependencyHighLow,
  // Ordenar por nivel de dependencia del usuario: menor dependencia primero
  dependencyLowHigh,
}
