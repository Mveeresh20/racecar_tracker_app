import 'package:flutter/material.dart';

extension ThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  /// TextTheme and TextStyle getters
  TextTheme get textTheme => theme.textTheme;
  TextStyle? get displaySmall => theme.textTheme.displaySmall;
  TextStyle? get displayMedium => theme.textTheme.displayMedium;
  TextStyle? get displayLarge => theme.textTheme.displayLarge;
  TextStyle? get titleSmall => theme.textTheme.titleSmall;
  TextStyle? get titleMedium => theme.textTheme.titleMedium;
  TextStyle? get titleLarge => theme.textTheme.titleLarge;
  TextStyle? get headlineSmall => theme.textTheme.headlineSmall;
  TextStyle? get headlineMedium => theme.textTheme.headlineMedium;
  TextStyle? get headlineLarge => theme.textTheme.headlineLarge;
  TextStyle? get labelSmall => theme.textTheme.labelSmall;
  TextStyle? get labelMedium => theme.textTheme.labelMedium;
  TextStyle? get labelLarge => theme.textTheme.labelLarge;
  TextStyle? get bodySmall => theme.textTheme.bodySmall;
  TextStyle? get bodyMedium => theme.textTheme.bodyMedium;
  TextStyle? get bodyLarge => theme.textTheme.bodyLarge;

  IconThemeData get iconTheme => theme.iconTheme;

  Brightness get brightness => theme.brightness;

  bool get isDark => theme.brightness == Brightness.dark;

  bool get isLight => theme.brightness == Brightness.light;
}
