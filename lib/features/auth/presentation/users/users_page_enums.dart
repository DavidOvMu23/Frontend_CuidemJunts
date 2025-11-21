// Definición de los filtros disponibles para la búsqueda de usuarios
enum UsersPageFilter { all, ningunaDep, leve, medio, severo }

// Criterios de ordenación para la lista
enum UsersPageSort {
  noneAZ,
  nameZA,
  dateBirthOldest,
  dateBirthNewest,
  dependencyHighLow,
  dependencyLowHigh,
}
