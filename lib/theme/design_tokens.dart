import 'package:flutter/material.dart';

class AppShadows {
  static const List<BoxShadow> soft = <BoxShadow>[];
}

/// Shared desktop popover wash. Alpha is unchanged from the previous
/// per-popover literals (`surface` @ 0.28 dark / 0.56 light).
class AppOverlayColors {
  static const double desktopPopoverAlphaDark = 0.28;
  static const double desktopPopoverAlphaLight = 0.56;

  static Color desktopPopoverSurface(ColorScheme cs) {
    final isDark = cs.brightness == Brightness.dark;
    return cs.surface.withValues(
      alpha: isDark ? desktopPopoverAlphaDark : desktopPopoverAlphaLight,
    );
  }
}

class AppRadii {
  static const double compact = 18;
  static const double control = 28;
  static const double card = 32;
  static const double sheet = 36;
  static const double capsule = 999;
}

class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
}

