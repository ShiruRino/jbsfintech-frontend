import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _primary = Color(0xFF000613);
  static const _primaryContainer = Color(0xFF001F3F);
  static const _secondary = Color(0xFF006C49);
  static const _success = Color(0xFF006C49);
  static const _danger = Color(0xFFBA1A1A);
  static const _surfaceTint = Color(0xFFF7F9FC);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _primary,
      primary: _primary,
      secondary: _secondary,
      primaryContainer: _primaryContainer,
      brightness: Brightness.light,
      surface: Colors.white,
      error: _danger,
    );

    return _baseTheme(scheme, Brightness.light);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _primary,
      primary: const Color(0xFFD4E3FF),
      secondary: const Color(0xFF4EDEA3),
      brightness: Brightness.dark,
      surface: const Color(0xFF111827),
      error: const Color(0xFFFF8B74),
    );

    return _baseTheme(scheme, Brightness.dark);
  }

  static ThemeData _baseTheme(ColorScheme scheme, Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF7F9FC)
          : const Color(0xFF07111F),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brightness == Brightness.light
            ? const Color(0xFF102A43)
            : const Color(0xFFE5EEF8),
        contentTextStyle: TextStyle(
          color: brightness == Brightness.light
              ? Colors.white
              : const Color(0xFF102A43),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF172033),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF64748B)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF64748B)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF172033),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        shadowColor: const Color(0xFF0F3558).withValues(alpha: 0.08),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        side: BorderSide.none,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        shape: StadiumBorder(),
      ),
    );
    final jakartaTextTheme = GoogleFonts.plusJakartaSansTextTheme(
      base.textTheme,
    );

    return base.copyWith(
      textTheme: jakartaTextTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppPalette(
          success: _success,
          danger: _danger,
          surfaceTint: _surfaceTint,
        ),
      ],
    );
  }
}

class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.success,
    required this.danger,
    required this.surfaceTint,
  });

  final Color success;
  final Color danger;
  final Color surfaceTint;

  @override
  ThemeExtension<AppPalette> copyWith({
    Color? success,
    Color? danger,
    Color? surfaceTint,
  }) {
    return AppPalette(
      success: success ?? this.success,
      danger: danger ?? this.danger,
      surfaceTint: surfaceTint ?? this.surfaceTint,
    );
  }

  @override
  ThemeExtension<AppPalette> lerp(
    covariant ThemeExtension<AppPalette>? other,
    double t,
  ) {
    if (other is! AppPalette) {
      return this;
    }

    return AppPalette(
      success: Color.lerp(success, other.success, t) ?? success,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
      surfaceTint: Color.lerp(surfaceTint, other.surfaceTint, t) ?? surfaceTint,
    );
  }
}
