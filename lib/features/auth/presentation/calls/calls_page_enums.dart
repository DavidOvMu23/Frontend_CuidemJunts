// Filtros disponibles de la búsqueda de llamadas.
enum CallsPageFilter { all, complete, pending, incomplete }

// Modos de ordenación disponibles para la lista de llamadas.
enum CallsPageSort {
  none,
  dateLatest,
  nameAZ,
  nameZA,
  callDurationShortLong,
  callDurationLongShort,
  dependencyHighLow,
  dependencyLowHigh,
}
