// Paquete principal de Flutter
import 'package:flutter/material.dart';

// Clave global del navegador de la app.
//
// En Flutter, para navegar entre pantallas normalmente necesitas tener acceso
// al "contexto" de un widget (BuildContext). Sin embargo, hay situaciones donde
// necesitamos navegar desde fuera del árbol de widgets, por ejemplo:
//   - El interceptor HTTP detecta que el token de sesión ha expirado
//     y necesita redirigir al usuario a la pantalla de login automáticamente.
//   - Un servicio de notificaciones quiere abrir una pantalla concreta.
//
// La GlobalKey nos permite acceder al navegador desde cualquier parte del código
// sin necesidad de tener un BuildContext disponible.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
