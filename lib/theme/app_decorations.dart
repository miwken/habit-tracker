// Назначение: Общие декорации (скругления, тени).
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  // Скругления
  static const BorderRadius cardBorderRadius = BorderRadius.all(
    Radius.circular(16),
  );
  static const BorderRadius buttonBorderRadius = BorderRadius.all(
    Radius.circular(12),
  );
  static const BorderRadius inputBorderRadius = BorderRadius.all(
    Radius.circular(10),
  );

  // Тени с неоновым свечением
  static List<BoxShadow> get primaryShadow => [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.3),
      blurRadius: 8,
      spreadRadius: 0,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: AppColors.background.withOpacity(0.9),
      blurRadius: 4,
      spreadRadius: 0,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 12,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  // Градиенты
  static Gradient get primaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.secondary],
  );

  static Gradient get backgroundGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.background, AppColors.surface],
  );

  // Границы
  static BoxBorder get primaryBorder =>
      Border.all(color: AppColors.primary.withOpacity(0.5), width: 1);

  static BoxBorder get surfaceBorder =>
      Border.all(color: AppColors.divider, width: 1);
}
