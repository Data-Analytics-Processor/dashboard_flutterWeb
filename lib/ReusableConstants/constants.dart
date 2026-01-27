import 'package:flutter/material.dart';

// --- NEO-BANK THEME COLORS ---

// Backgrounds
const Color kBankBg = Color(0xFF0B0E14);         // Deep Navy Black
const Color kBankSurface = Color(0xFF151A23);    // Card Surface
const Color kBankSurfaceLight = Color(0xFF1E2532); // Hover/Input fields

// Accents
const Color kBankPrimary = Color(0xFF4361EE);    // Royal Electric Blue
const Color kBankAccent = Color(0xFF3F37C9);     // Deep Purple/Blue Gradient
const Color kSuccessGreen = Color(0xFF4CC9F0);   // Cyan for status
const Color kExpenseRed = Color(0xFFF72585);     // For errors

// Text & Borders
const Color kTextWhite = Color(0xFFFFFFFF);
const Color kTextGrey = Color(0xFF94A3B8);       // Slate Grey
const Color kBorderColor = Color(0xFF2D3748);    // Subtle borders

// --- RESPONSIVE HELPER ---
class Responsive {
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 850;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 850;
}