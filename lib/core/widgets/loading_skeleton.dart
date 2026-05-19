// Paquete principal de Flutter
import 'package:flutter/material.dart';

// -------- WIDGETS DE CARGA (SKELETON) --------
// Un "skeleton" es un marcador de posición animado que imita la forma del contenido
// mientras los datos se están cargando desde el servidor.
// Es mejor experiencia que mostrar una pantalla en blanco o un círculo girando,
// porque el usuario ya sabe dónde van a aparecer los elementos.

// ── Bloque base animado ───────────────────────────────────────────────────────

// Rectángulo animado con efecto de parpadeo suave (oscila entre dos tonos de color).
// Es el componente más pequeño: los demás skeletons se construyen combinando varios de estos.
// StatefulWidget porque necesita controlar la animación en el tiempo.
class AppSkeletonBox extends StatefulWidget {
  // Anchura del bloque; null = ocupa todo el ancho disponible
  final double? width;
  // Altura del bloque (obligatoria para que el widget tenga tamaño definido)
  final double height;
  // Cuánto se redondean las esquinas del rectángulo
  final BorderRadius borderRadius;
  // Espacio exterior opcional alrededor del bloque
  final EdgeInsetsGeometry? margin;

  const AppSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.margin,
  });

  @override
  State<AppSkeletonBox> createState() => _AppSkeletonBoxState();
}

// Estado interno del AppSkeletonBox que gestiona la animación de parpadeo
// SingleTickerProviderStateMixin es necesario para que el AnimationController funcione
class _AppSkeletonBoxState extends State<AppSkeletonBox>
    with SingleTickerProviderStateMixin {
  // Controlador de animación: hace que el color oscile de claro a oscuro y viceversa
  // repeat(reverse: true) = va de 0 a 1 y luego de 1 a 0, en bucle infinito
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100), // Ciclo completo de parpadeo
  )..repeat(reverse: true);

  @override
  // Liberamos el controlador de animación cuando el widget desaparece
  // para evitar fugas de memoria (el widget seguiría consumiendo recursos en segundo plano)
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Color base del skeleton: muy transparente (casi invisible) sobre el fondo
    final base = Theme.of(context).colorScheme.primary.withValues(alpha: 0.08);
    // Color de destaque: un poco más visible, para crear el efecto de brillo
    final highlight =
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.18);

    // AnimatedBuilder se reconstruye en cada fotograma de la animación
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Aplicamos una curva suave (easeInOut) para que el parpadeo no sea brusco
        final t = Curves.easeInOut.transform(_controller.value);
        // Interpolamos el color entre base y highlight según el progreso de la animación
        final color = Color.lerp(base, highlight, t) ?? base;

        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: color,
            borderRadius: widget.borderRadius,
          ),
        );
      },
    );
  }
}

// ── Tarjeta skeleton ──────────────────────────────────────────────────────────

// Imita el aspecto de una tarjeta de la lista mientras los datos cargan.
// Muestra varios bloques de distinto tamaño que simulan un título, dos líneas de
// texto y una etiqueta de estado, igual que las tarjetas reales.
class AppSkeletonCard extends StatelessWidget {
  // Altura total de la tarjeta; debe coincidir con la altura de las tarjetas reales
  final double height;

  const AppSkeletonCard({super.key, this.height = 132});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // Usamos el color de tarjeta del tema para que sea igual a la tarjeta real
        color: Theme.of(context).cardColor,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bloque ancho que simula el título de la tarjeta
          AppSkeletonBox(width: 210, height: 20),
          SizedBox(height: 10),
          // Bloque mediano que simula la primera línea de información
          AppSkeletonBox(width: 180, height: 14),
          SizedBox(height: 8),
          // Bloque más corto que simula la segunda línea de información
          AppSkeletonBox(width: 130, height: 14),
          // Spacer empuja el último bloque al fondo de la tarjeta
          Spacer(),
          // Bloque pequeño al fondo que simula la etiqueta de estado
          AppSkeletonBox(width: 92, height: 24),
        ],
      ),
    );
  }
}

// ── Lista skeleton ────────────────────────────────────────────────────────────

// Muestra una lista de tarjetas skeleton, una debajo de la otra.
// Se usa para llenar toda la pantalla mientras se espera la respuesta del servidor.
class AppSkeletonList extends StatelessWidget {
  // Cuántas tarjetas falsas mostrar mientras carga (por defecto 4)
  final int count;
  // Altura de cada tarjeta; debe coincidir con AppSkeletonCard
  final double itemHeight;

  const AppSkeletonList({
    super.key,
    this.count = 4,
    this.itemHeight = 132,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: count,
      // NeverScrollableScrollPhysics: desactivamos el scroll propio de esta lista
      // porque ya hay un scroll exterior en la pantalla que lo gestiona
      physics: const NeverScrollableScrollPhysics(),
      // Separador de 10px entre tarjetas
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      // Cada elemento de la lista es una tarjeta skeleton
      itemBuilder: (_, __) => AppSkeletonCard(height: itemHeight),
    );
  }
}