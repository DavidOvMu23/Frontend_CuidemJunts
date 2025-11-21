// -------- ENUMS PARA LA PÁGINA DE USUARIOS --------
// Filtros disponibles de la búsqueda de usuarios.
enum UsersPageFilter { all, ningunaDep, leve, medio, severo }

// Modos de ordenación disponibles para la lista de usuarios.
enum UsersPageSort {
  noneAZ,
  nameZA,
  dateBirthOldest,
  dateBirthNewest,
  dependencyHighLow,
  dependencyLowHigh,
}
