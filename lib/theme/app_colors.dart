// Назначение: Хранит все цвета приложения в одном месте.
import 'package:flutter/material.dart';

class AppColors {
  // Основные цвета
  static const Color primary = Color(0xFF00D9FF); // Неоновый циан
  static const Color primaryDark = Color(0xFF0099CC); // Более тёмный циан
  static const Color secondary = Color(0xFF9D00FF); // Неоновый фиолетовый

  // Фоны
  static const Color background = Color.fromARGB(255, 255, 255, 255); // Почти чёрный
  static const Color surface = Color(0xFF151520); // Тёмная поверхность
  static const Color surfaceLight = Color(
    0xFF1E1E2E,
  ); // Более светлая поверхность

  // Текст
  static const Color textPrimary = Color(0xFFE5E7EB); // Светло-серый
  static const Color textSecondary = Color(0xFF9CA3AF); // Серый
  static const Color textDisabled = Color(0xFF6B7280); // Тёмно-серый

  // Статусные цвета
  static const Color success = Color(0xFF00FF9D); // Неоновый зелёный
  static const Color successLight = Color(0x3300FF9D); // С прозрачностью
  static const Color error = Color(0xFFFF006E); // Ярко-розовый
  static const Color errorLight = Color(0x33FF006E); // С прозрачностью
  static const Color neutral = Color(0xFF6B7280); // Серый

  // Дополнительные
  static const Color divider = Color(0xFF2D3748); // Разделители
  static const Color shadow = Color(0x66000000); // Тень
  static const Color overlay = Color(0x80151520); // Наложение

  // Глюч-эффекты (опционально)
  static const Color glitchBlue = Color(0xFF00F3FF);
  static const Color glitchPurple = Color(0xFF9D00FF);
}
