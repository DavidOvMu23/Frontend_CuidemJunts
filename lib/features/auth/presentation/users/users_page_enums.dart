// Filtros disponibles en la página de usuarios (personas dependientes).
// Permiten ver todos los usuarios o solo los de un nivel de dependencia concreto.
// El nivel de dependencia indica cuánta ayuda necesita la persona en su día a día.
enum UsersPageFilter {
  // Muestra todos los usuarios sin excepción
  all,
  // Muestra solo los usuarios sin ningún grado de dependencia reconocido
  ningunaDep,
  // Muestra solo los usuarios con dependencia LEVE (necesitan poca ayuda)
  leve,
  // Muestra solo los usuarios con dependencia MODERADA (necesitan ayuda regular)
  medio,
  // Muestra solo los usuarios con dependencia SEVERA (necesitan mucha ayuda)
  severo,
}

// Criterios de ordenación disponibles para la lista de usuarios.
// Permiten al supervisor reorganizar la lista según lo que necesite ver primero.
enum UsersPageSort {
  // Sin ordenación especial: orden por defecto (alfabético A-Z)
  noneAZ,
  // Ordenar por nombre: de la Z a la A
  nameZA,
  // Ordenar por fecha de nacimiento: los más mayores primero
  dateBirthOldest,
  // Ordenar por fecha de nacimiento: los más jóvenes primero
  dateBirthNewest,
  // Ordenar por nivel de dependencia: mayor dependencia primero
  // Útil para que el supervisor atienda primero a quienes más lo necesitan
  dependencyHighLow,
  // Ordenar por nivel de dependencia: menor dependencia primero
  dependencyLowHigh,
}
