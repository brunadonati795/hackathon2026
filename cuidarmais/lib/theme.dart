import 'package:flutter/material.dart';

class AppColors {
  static const purple = Color(0xFF7157C7);
  static const palePurple = Color(0xFFF6F5FD);
  static const green = Color(0xFF39A86E);
  static const blue = Color(0xFF4E8DF5);
  static const ink = Color(0xFF1C2430);
  static const muted = Color(0xFF788596);
  static const border = Color(0xFFDDE1E8);
  static const red = Color(0xFFC84A4A);
}

ThemeData buildTheme({required bool highContrast, required double brightness}) {
  final surface = highContrast
      ? const Color(0xFFF9F9FB)
      : Color.lerp(const Color(0xFFE9E6F4), Colors.white, brightness)!;
  final primaryTextColor = highContrast ? Colors.black : AppColors.ink;
  final secondaryTextColor = highContrast
      ? const Color(0xFF222222)
      : AppColors.muted;
  final borderColor = highContrast ? Colors.black : AppColors.border;

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: surface,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      brightness: Brightness.light,
    ),
    fontFamily: 'Arial',
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w900,
        color: primaryTextColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: primaryTextColor,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: primaryTextColor,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: primaryTextColor,
      ),
      bodyLarge: TextStyle(fontSize: 17, height: 1.35, color: primaryTextColor),
      bodyMedium: TextStyle(
        fontSize: 15,
        height: 1.35,
        color: secondaryTextColor,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: borderColor,
          width: highContrast ? 2.5 : 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: borderColor,
          width: highContrast ? 2.5 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.purple,
          width: highContrast ? 3 : 2,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: highContrast
              ? const BorderSide(color: Colors.black, width: 2)
              : BorderSide.none,
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor, width: highContrast ? 2.5 : 1),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
  );
}

class AppSurface extends StatelessWidget {
  const AppSurface({super.key, required this.child, this.brightness = 1.0});
  final Widget child;
  final double brightness;

  @override
  Widget build(BuildContext context) {
    // Calculate dim opacity: brightness of 1.0 = 0 opacity overlay; brightness of 0.3 = 0.5 overlay opacity.
    final dimOpacity = ((1.0 - brightness.clamp(0.3, 1.0)) * 0.75).clamp(
      0.0,
      0.65,
    );

    Widget wrappedChild = Stack(
      children: [
        child,
        if (dimOpacity > 0.01)
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: dimOpacity),
              ),
            ),
          ),
      ],
    );

    final size = MediaQuery.sizeOf(context);
    if (size.width < 600) return wrappedChild;

    return ColoredBox(
      color: const Color(0xFFE8E8EA),
      child: Center(
        child: Container(
          width: 410,
          height: size.height > 820
              ? 800
              : (size.height - 24).clamp(300.0, 800.0),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color(0x24000000),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: wrappedChild,
        ),
      ),
    );
  }
}
