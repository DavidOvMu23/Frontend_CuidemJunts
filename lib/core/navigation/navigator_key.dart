import 'package:flutter/material.dart';

// Clave global del navegador de la app. Se usa para navegar desde fuera del árbol
// de widgets (ej: interceptor HTTP que detecta token expirado).
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
