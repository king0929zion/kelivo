import 'package:flutter/material.dart';

import 'ios_tactile.dart';

/// A translucent tonal wash. Deliberately does not sample or blur content.
class FlatHeaderWash extends StatelessWidget {
  const FlatHeaderWash({super.key});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              surface.withValues(alpha: 0.98),
              surface.withValues(alpha: 0.92),
              surface.withValues(alpha: 0),
            ],
            stops: const [0, 0.72, 1],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class FlatIconButton extends StatelessWidget {
  const FlatIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.onLongPress,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        enabled: onTap != null,
        child: IosCardPress(
          baseColor: cs.surface,
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          onLongPress: onLongPress,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, size: 24, color: cs.onSurface),
          ),
        ),
      ),
    );
  }
}
