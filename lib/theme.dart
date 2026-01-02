import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const full = 999.0;
}

extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;
}

extension TextStyleExtensions on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get normal => copyWith(fontWeight: FontWeight.w400);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withSize(double size) => copyWith(fontSize: size);
}

class LightModeColors {
  // Brand Colors (Telegram/Twitter Lite inspired)
  static const primary = Color(0xFF00AAFF); // Vivid Blue, friendly and modern
  static const onPrimary = Colors.white;
  static const primaryContainer = Color(0xFFE1F5FE);
  static const onPrimaryContainer = Color(0xFF003355);

  static const secondary = Color(0xFF1DA1F2);
  static const onSecondary = Colors.white;

  static const tertiary = Color(0xFF657786); // Slate grey for subtitles
  static const onTertiary = Colors.white;

  static const error = Color(0xFFE0245E);
  static const onError = Colors.white;

  // Modern Backgrounds
  static const surface = Color(0xFFFFFFFF); // Pure white cards
  static const background =
      Color(0xFFF5F8FA); // Very light grey blue background
  static const onSurface = Color(0xFF14171A); // Deep black-blue text
  static const onBackground = Color(0xFF14171A);

  static const surfaceVariant = Color(0xFFE1E8ED); // Borders/Dividers
  static const onSurfaceVariant = Color(0xFF657786); // Secondary text

  static const outline = Color(0xFFAAB8C2);

  // Chat Specific
  static const chatBubbleSent = Color(0xFFE1F5FE); // Very light blue
  static const chatBubbleReceived = Color(0xFFF5F8FA); // Light Grey
}

class DarkModeColors {
  // Brand Colors
  static const primary = Color(0xFF1DA1F2); // Lighter Blue for Dark Mode
  static const onPrimary = Colors.white;
  static const primaryContainer = Color(0xFF004D73);
  static const onPrimaryContainer = Color(0xFFB3E5FC);

  static const secondary = Color(0xFF192734);
  static const onSecondary = Colors.white;

  static const tertiary = Color(0xFF8899A6);
  static const onTertiary = Color(0xFF15202B);

  static const error = Color(0xFFF4212E);
  static const onError = Colors.white;

  // Modern Dark Backgrounds (Twitter Dark / Telegram Night)
  static const surface = Color(0xFF192734); // Dark Blue-Grey
  static const background = Color(0xFF15202B); // Deep Navy
  static const onSurface = Color(0xFFFFFFFF);
  static const onBackground = Color(0xFFFFFFFF);

  static const surfaceVariant =
      Color(0xFF253341); // Slightly lighter for inputs/cards
  static const onSurfaceVariant = Color(0xFF8899A6);

  static const outline = Color(0xFF38444D);

  // Chat Specific
  static const chatBubbleSent = Color(0xFF1DA1F2);
  static const chatBubbleReceived = Color(0xFF253341);
}

class FontSizes {
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;
  static const double titleLarge = 22.0;
  static const double titleMedium =
      18.0; // Slightly larger for better readability
  static const double titleSmall = 15.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: LightModeColors.primary,
        onPrimary: LightModeColors.onPrimary,
        primaryContainer: LightModeColors.primaryContainer,
        onPrimaryContainer: LightModeColors.onPrimaryContainer,
        secondary: LightModeColors.secondary,
        onSecondary: LightModeColors.onSecondary,
        secondaryContainer: LightModeColors.surfaceVariant,
        tertiary: LightModeColors.tertiary,
        onTertiary: LightModeColors.onTertiary,
        error: LightModeColors.error,
        onError: LightModeColors.onError,
        surface: LightModeColors.surface,
        onSurface: LightModeColors.onSurface,
        surfaceContainerHighest: LightModeColors.surfaceVariant,
        onSurfaceVariant: LightModeColors.onSurfaceVariant,
        outline: LightModeColors.outline,
        surfaceTint: Colors.transparent, // Remove surface tint
      ),
      scaffoldBackgroundColor: LightModeColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: LightModeColors.surface,
        foregroundColor: LightModeColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: LightModeColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side:
              const BorderSide(color: LightModeColors.surfaceVariant, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: LightModeColors.surface,
        selectedItemColor: LightModeColors.primary,
        unselectedItemColor: LightModeColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LightModeColors.surfaceVariant.withOpacity(0.3),
        contentPadding: AppSpacing.paddingMd,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide:
              const BorderSide(color: LightModeColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: LightModeColors.onSurfaceVariant),
      ),
      textTheme: _buildTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LightModeColors.primary,
          foregroundColor: LightModeColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.full)),
          textStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );

ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: DarkModeColors.primary,
        onPrimary: DarkModeColors.onPrimary,
        primaryContainer: DarkModeColors.primaryContainer,
        onPrimaryContainer: DarkModeColors.onPrimaryContainer,
        secondary: DarkModeColors.secondary,
        onSecondary: DarkModeColors.onSecondary,
        secondaryContainer: DarkModeColors.surfaceVariant,
        tertiary: DarkModeColors.tertiary,
        onTertiary: DarkModeColors.onTertiary,
        error: DarkModeColors.error,
        onError: DarkModeColors.onError,
        surface: DarkModeColors.surface,
        onSurface: DarkModeColors.onSurface,
        surfaceContainerHighest: DarkModeColors.surfaceVariant,
        onSurfaceVariant: DarkModeColors.onSurfaceVariant,
        outline: DarkModeColors.outline,
        surfaceTint: Colors.transparent,
      ),
      scaffoldBackgroundColor: DarkModeColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor:
            DarkModeColors.background, // Match background on dark mode
        foregroundColor: DarkModeColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: DarkModeColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side:
              const BorderSide(color: DarkModeColors.surfaceVariant, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DarkModeColors.background,
        selectedItemColor: DarkModeColors.primary,
        unselectedItemColor: DarkModeColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DarkModeColors.surfaceVariant,
        contentPadding: AppSpacing.paddingMd,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          borderSide:
              const BorderSide(color: DarkModeColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: DarkModeColors.onSurfaceVariant),
      ),
      textTheme: _buildTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DarkModeColors.primary,
          foregroundColor: DarkModeColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.full)),
          textStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );

TextTheme _buildTextTheme() {
  return TextTheme(
    displayLarge: GoogleFonts.inter(
        fontSize: FontSizes.displayLarge, fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.inter(
        fontSize: FontSizes.displayMedium, fontWeight: FontWeight.bold),
    displaySmall: GoogleFonts.inter(
        fontSize: FontSizes.displaySmall, fontWeight: FontWeight.bold),
    headlineLarge: GoogleFonts.inter(
        fontSize: FontSizes.headlineLarge, fontWeight: FontWeight.bold),
    headlineMedium: GoogleFonts.inter(
        fontSize: FontSizes.headlineMedium, fontWeight: FontWeight.w600),
    headlineSmall: GoogleFonts.inter(
        fontSize: FontSizes.headlineSmall, fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.inter(
        fontSize: FontSizes.titleLarge, fontWeight: FontWeight.bold),
    titleMedium: GoogleFonts.inter(
        fontSize: FontSizes.titleMedium, fontWeight: FontWeight.w600),
    titleSmall: GoogleFonts.inter(
        fontSize: FontSizes.titleSmall, fontWeight: FontWeight.w600),
    labelLarge: GoogleFonts.inter(
        fontSize: FontSizes.labelLarge, fontWeight: FontWeight.w600),
    labelMedium: GoogleFonts.inter(
        fontSize: FontSizes.labelMedium, fontWeight: FontWeight.w500),
    labelSmall: GoogleFonts.inter(
        fontSize: FontSizes.labelSmall, fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.inter(
        fontSize: FontSizes.bodyLarge, fontWeight: FontWeight.normal),
    bodyMedium: GoogleFonts.inter(
        fontSize: FontSizes.bodyMedium, fontWeight: FontWeight.normal),
    bodySmall: GoogleFonts.inter(
        fontSize: FontSizes.bodySmall, fontWeight: FontWeight.normal),
  );
}






















            //  () async {
            //   final auth = context.read<AuthProvider>();
            //   if (!auth.isAuthenticated) {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(content: Text('Please sign in to react')),
            //     );
            //     return;
            //   }

            //   await postProvider.reactToPost(post.id, r["icon"] as String);
            // },