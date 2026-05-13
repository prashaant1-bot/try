// Design system for the UPSC essay practice app.
//
// Usage (when you are ready — does not require editing other files first):
//   import 'app_ui_kit.dart';
//   theme: AppTheme.light,
//   body: AppGradientBackground(child: AppGlassCard(child: ...))
//
library;

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Color tokens (aligned with main.dart: blue accent, #F5F7FB scaffold)
// ---------------------------------------------------------------------------

abstract final class AppPalette {
  static const Color scaffold = Color(0xFFF5F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEF2FA);

  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primarySoft = Color(0xFFE8F0FE);

  static const Color ink = Color(0xFF0F172A);
  static const Color inkMuted = Color(0xFF64748B);
  static const Color inkSubtle = Color(0xFF94A3B8);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);

  static const List<Color> brandGradient = [primary, primaryDark];
}

/// Bubble colors for chat-style screens (optional drop-in when you refactor).
abstract final class AppChatPalette {
  static const Color bubbleMe = AppPalette.primary;
  static const Color bubbleOther = Color(0xFFE2E8F0);
  static const Color bubbleMeText = Color(0xFFFFFFFF);
  static const Color bubbleOtherText = AppPalette.ink;
}

// ---------------------------------------------------------------------------
// Spacing, radii, motion
// ---------------------------------------------------------------------------

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

abstract final class AppRadii {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 22;
  static const double pill = 999;
}

abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 260);
  static const Curve curve = Curves.easeOutCubic;
}

// ---------------------------------------------------------------------------
// Elevation & dividers
// ---------------------------------------------------------------------------

abstract final class AppShadows {
  static List<BoxShadow> card(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? Colors.black : AppPalette.ink;
    return [
      BoxShadow(
        color: c.withValues(alpha: 0.06),
        blurRadius: 24,
        offset: const Offset(0, 14),
      ),
      BoxShadow(
        color: c.withValues(alpha: 0.03),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> soft() => [
    BoxShadow(
      color: AppPalette.primary.withValues(alpha: 0.18),
      blurRadius: 28,
      offset: const Offset(0, 16),
    ),
  ];
}

// ---------------------------------------------------------------------------
// Typography
// ---------------------------------------------------------------------------

abstract final class AppTypography {
  static const String? fontFamily =
      null; // use platform default; set if you add fonts

  static TextStyle display(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 1.15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    color: color,
  );

  static TextStyle title(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: color,
  );

  static TextStyle subtitle(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 1.45,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle body(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle label(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: color,
  );

  static TextStyle caption(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: color,
  );
}

// ---------------------------------------------------------------------------
// ThemeData — pass to MaterialApp(theme: ...) when you wire it in
// ---------------------------------------------------------------------------

abstract final class AppTheme {
  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: AppPalette.primary,
      onPrimary: Colors.white,
      secondary: AppPalette.primaryDark,
      onSecondary: Colors.white,
      surface: AppPalette.surface,
      onSurface: AppPalette.ink,
      error: AppPalette.danger,
      onError: Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppPalette.scaffold,
      splashFactory: InkSparkle.splashFactory,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: AppPalette.surface,
        foregroundColor: AppPalette.ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppPalette.ink,
        ),
        iconTheme: IconThemeData(color: AppPalette.ink, size: 22),
      ),
      cardTheme: CardThemeData(
        color: AppPalette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: AppPalette.ink.withValues(alpha: 0.06),
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppPalette.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPalette.primary,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          side: const BorderSide(color: AppPalette.primary, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        hintStyle: AppTypography.body(AppPalette.inkSubtle),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: AppPalette.ink.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: AppPalette.ink.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppPalette.primary, width: 1.6),
        ),
      ),
      textTheme: base.textTheme.copyWith(
        bodyLarge: AppTypography.body(AppPalette.ink),
        bodyMedium: AppTypography.body(AppPalette.ink),
        titleLarge: AppTypography.title(AppPalette.ink),
        titleMedium: AppTypography.subtitle(AppPalette.ink),
        labelLarge: AppTypography.label(AppPalette.ink),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Layout primitives
// ---------------------------------------------------------------------------

/// Soft gradient + faint pattern behind scrollable content.
class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FAFF), AppPalette.scaffold, Color(0xFFF3F6FD)],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );
  }
}

/// Primary surface card: white panel, crisp border, layered shadow.
class AppGlassCard extends StatelessWidget {
  const AppGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.margin,
    this.radius = AppRadii.xl,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppPalette.ink.withValues(alpha: 0.06)),
        boxShadow: AppShadows.card(context),
      ),
      child: child,
    );
  }
}

/// Circular icon badge with brand gradient ring.
class AppHeroIcon extends StatelessWidget {
  const AppHeroIcon({
    super.key,
    required this.icon,
    this.size = 72,
    this.iconSize = 34,
    this.colors = AppPalette.brandGradient,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppShadows.soft(),
      ),
      child: Icon(icon, size: iconSize, color: Colors.white),
    );
  }
}

/// Section title row: optional overline, title, subtitle, trailing widget.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.overline,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? overline;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (overline != null) ...[
                Text(
                  overline!,
                  style: AppTypography.caption(AppPalette.primary),
                ),
                const SizedBox(height: AppSpacing.xxs),
              ],
              Text(title, style: AppTypography.title(AppPalette.ink)),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: AppTypography.subtitle(AppPalette.inkMuted),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Full-width primary CTA with optional leading icon and loading state.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    return AnimatedOpacity(
      duration: AppMotion.fast,
      opacity: disabled ? 0.55 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.md),
          gradient: const LinearGradient(
            colors: AppPalette.brandGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: disabled ? [] : AppShadows.soft(),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadii.md),
            onTap: disabled ? null : onPressed,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (loading) ...[
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ] else if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined secondary action (e.g. “My Dashboard”).
class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppPalette.primary,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: AppPalette.primary, width: 1.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(label),
        ],
      ),
    );
  }
}

/// Compact info pill (scores, tags, “New”).
class AppPill extends StatelessWidget {
  const AppPill({
    super.key,
    required this.label,
    this.icon,
    this.background = AppPalette.primarySoft,
    this.foreground = AppPalette.primary,
  });

  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: foreground.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            label,
            style: AppTypography.caption(
              foreground,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// List row shell for date cards / history tiles — use inside ListView.
class AppListRowShell extends StatelessWidget {
  const AppListRowShell({
    super.key,
    required this.child,
    this.onTap,
    this.margin = const EdgeInsets.only(bottom: AppSpacing.sm),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Material(
        color: AppPalette.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(color: AppPalette.ink.withValues(alpha: 0.06)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}
