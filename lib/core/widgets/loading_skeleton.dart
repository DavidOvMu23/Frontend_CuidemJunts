import 'package:flutter/material.dart';

// Skeleton animado para estados de carga en tarjetas/listas.
class AppSkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;
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

class _AppSkeletonBoxState extends State<AppSkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.primary.withValues(alpha: 0.08);
    final highlight =
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.18);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
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

class AppSkeletonCard extends StatelessWidget {
  final double height;

  const AppSkeletonCard({super.key, this.height = 132});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeletonBox(width: 210, height: 20),
          SizedBox(height: 10),
          AppSkeletonBox(width: 180, height: 14),
          SizedBox(height: 8),
          AppSkeletonBox(width: 130, height: 14),
          Spacer(),
          AppSkeletonBox(width: 92, height: 24),
        ],
      ),
    );
  }
}

class AppSkeletonList extends StatelessWidget {
  final int count;
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
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => AppSkeletonCard(height: itemHeight),
    );
  }
}