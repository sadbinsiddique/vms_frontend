import 'package:flutter/material.dart';

/// Semantic and brand color palette for the Vehicle Management System.
class AppColors {
  AppColors._();

  // Primary brand colors (Enterprise Indigo & Deep Navy)
  static const Color primary = Color(0xFF1E40AF); // Blue 800
  static const Color primaryHover = Color(0xFF1D4ED8); // Blue 700
  static const Color primaryLight = Color(0xFFDBEAFE); // Blue 100

  // Background and surface colors (Dashboard crisp contrast)
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9); // Slate 100
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderHover = Color(0xFFCBD5E1); // Slate 300

  // Typography colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Status colors
  static const Color success = Color(0xFF16A34A); // Green 600
  static const Color successLight = Color(0xFFDCFCE7); // Green 100
  static const Color warning = Color(0xFFD97706); // Amber 600
  static const Color warningLight = Color(0xFFFEF3C7); // Amber 100
  static const Color error = Color(0xFFDC2626); // Red 600
  static const Color errorLight = Color(0xFFFEE2E2); // Red 100
  static const Color info = Color(0xFF0284C7); // Sky 600
  static const Color infoLight = Color(0xFFE0F2FE); // Sky 100

  // Sidebar navigation
  static const Color sidebarBg = Color(0xFF0F172A); // Slate 900
  static const Color sidebarText = Color(0xFF94A3B8);
  static const Color sidebarTextActive = Color(0xFFFFFFFF);
  static const Color sidebarActiveItem = Color(0xFF1E293B);
}

