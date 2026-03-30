import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color yellow = Color(0xFFFFD600);
  static const Color yellowLight = Color(0xFFFFF9C4);
  static const Color grey900 = Color(0xFF1A1A1A);
  static const Color grey800 = Color(0xFF2D2D2D);
  static const Color grey700 = Color(0xFF3D3D3D);
  static const Color grey600 = Color(0xFF4F4F4F);
  static const Color grey400 = Color(0xFF9E9E9E);
  static const Color grey300 = Color(0xFFBDBDBD);
  static const Color grey200 = Color(0xFFE0E0E0);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color red = Color(0xFFE53935);
  static const Color green = Color(0xFF43A047);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF252525);
}

// ---------------------------------------------------------------------------
// Custom ThemeExtension for Hemisphere-specific semantic colors
// ---------------------------------------------------------------------------
@immutable
class HemisphereColors extends ThemeExtension<HemisphereColors> {
  const HemisphereColors({
    required this.card,
    required this.surface,
    required this.background,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textCaption,
    required this.iconSubtle,
    required this.inputFill,
    required this.navBackground,
    required this.divider,
    required this.menuIconBg,
    required this.cardShadow,
    required this.navInactive,
  });

  final Color card;
  final Color surface;
  final Color background;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textCaption;
  final Color iconSubtle;
  final Color inputFill;
  final Color navBackground;
  final Color divider;
  final Color menuIconBg;
  final Color cardShadow;
  final Color navInactive;

  static const dark = HemisphereColors(
    card: AppColors.cardDark,
    surface: AppColors.surfaceDark,
    background: AppColors.backgroundDark,
    textPrimary: AppColors.white,
    textSecondary: AppColors.grey300,
    textTertiary: AppColors.grey200,
    textCaption: AppColors.grey400,
    iconSubtle: AppColors.grey400,
    inputFill: AppColors.grey800,
    navBackground: AppColors.black,
    divider: AppColors.grey700,
    menuIconBg: AppColors.grey800,
    cardShadow: Color(0x80000000),
    navInactive: AppColors.grey600,
  );

  static const light = HemisphereColors(
    card: AppColors.white,
    surface: Color(0xFFF5F5F5),
    background: Color(0xFFFAFAFA),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF616161),
    textTertiary: Color(0xFF424242),
    textCaption: Color(0xFF9E9E9E),
    iconSubtle: Color(0xFF757575),
    inputFill: Color(0xFFF0F0F0),
    navBackground: AppColors.white,
    divider: Color(0xFFE0E0E0),
    menuIconBg: Color(0xFFF0F0F0),
    cardShadow: Color(0x1A000000),
    navInactive: Color(0xFF9E9E9E),
  );

  @override
  HemisphereColors copyWith({
    Color? card,
    Color? surface,
    Color? background,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textCaption,
    Color? iconSubtle,
    Color? inputFill,
    Color? navBackground,
    Color? divider,
    Color? menuIconBg,
    Color? cardShadow,
    Color? navInactive,
  }) {
    return HemisphereColors(
      card: card ?? this.card,
      surface: surface ?? this.surface,
      background: background ?? this.background,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textCaption: textCaption ?? this.textCaption,
      iconSubtle: iconSubtle ?? this.iconSubtle,
      inputFill: inputFill ?? this.inputFill,
      navBackground: navBackground ?? this.navBackground,
      divider: divider ?? this.divider,
      menuIconBg: menuIconBg ?? this.menuIconBg,
      cardShadow: cardShadow ?? this.cardShadow,
      navInactive: navInactive ?? this.navInactive,
    );
  }

  @override
  HemisphereColors lerp(covariant HemisphereColors? other, double t) {
    if (other == null) return this;
    return HemisphereColors(
      card: Color.lerp(card, other.card, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      background: Color.lerp(background, other.background, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textCaption: Color.lerp(textCaption, other.textCaption, t)!,
      iconSubtle: Color.lerp(iconSubtle, other.iconSubtle, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      navBackground: Color.lerp(navBackground, other.navBackground, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      menuIconBg: Color.lerp(menuIconBg, other.menuIconBg, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
      navInactive: Color.lerp(navInactive, other.navInactive, t)!,
    );
  }
}

/// Convenience extension for quick access to [HemisphereColors].
extension HemisphereContext on BuildContext {
  HemisphereColors get h => Theme.of(this).extension<HemisphereColors>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _baseStyle => GoogleFonts.montserrat();

  // Display
  static TextStyle displayLarge = _baseStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    letterSpacing: -0.5,
  );

  static TextStyle displayMedium = _baseStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  // Headlines
  static TextStyle headlineLarge = _baseStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static TextStyle headlineMedium = _baseStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static TextStyle headlineSmall = _baseStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  // Body
  static TextStyle bodyLarge = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  static TextStyle bodyMedium = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.grey300,
  );

  static TextStyle bodySmall = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.grey400,
  );

  // Labels
  static TextStyle labelLarge = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.5,
  );

  static TextStyle labelMedium = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.grey300,
  );

  // Button
  static TextStyle buttonLarge = _baseStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    letterSpacing: 0.5,
  );

  static TextStyle buttonMedium = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  // Caption
  static TextStyle caption = _baseStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.grey400,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    primaryColor: AppColors.yellow,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.yellow,
      secondary: AppColors.yellow,
      surface: AppColors.surfaceDark,
      onPrimary: AppColors.black,
      onSecondary: AppColors.black,
      onSurface: AppColors.white,
      error: AppColors.red,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headlineMedium,
      iconTheme: const IconThemeData(color: AppColors.white),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.black,
      selectedItemColor: AppColors.yellow,
      unselectedItemColor: AppColors.grey600,
      type: BottomNavigationBarType.fixed,
      elevation: 16,
      showUnselectedLabels: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.yellow,
        foregroundColor: AppColors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: AppTextStyles.buttonMedium,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.white,
        side: const BorderSide(color: AppColors.grey700),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: AppTextStyles.buttonMedium.copyWith(color: AppColors.white),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grey800,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.yellow, width: 1.5),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.grey800,
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.grey800,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    extensions: const [HemisphereColors.dark],
  );

  // -------------------------------------------------------------------------
  // LIGHT THEME
  // -------------------------------------------------------------------------
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFAFAFA),
    primaryColor: AppColors.yellow,
    colorScheme: const ColorScheme.light(
      primary: AppColors.yellow,
      secondary: AppColors.yellow,
      surface: Color(0xFFF5F5F5),
      onPrimary: AppColors.black,
      onSecondary: AppColors.black,
      onSurface: Color(0xFF1A1A1A),
      error: AppColors.red,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFFAFAFA),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headlineMedium.copyWith(color: const Color(0xFF1A1A1A)),
      iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.yellow,
      unselectedItemColor: Color(0xFF9E9E9E),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      showUnselectedLabels: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 2,
      shadowColor: const Color(0x1A000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.yellow,
        foregroundColor: AppColors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: AppTextStyles.buttonMedium,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1A1A1A),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: AppTextStyles.buttonMedium.copyWith(color: const Color(0xFF1A1A1A)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF0F0F0),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF9E9E9E)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.yellow, width: 1.5),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0E0E0),
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF323232),
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    extensions: const [HemisphereColors.light],
  );
}
