import 'package:flutter/material.dart';

/// Mirrors the Bootstrap `bg-primary` blue used throughout the Angular UI
/// (login header, buttons, badges) so the Flutter app feels consistent.
class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF0D6EFD); // Bootstrap primary
  static const Color success = Color(0xFF198754);
  static const Color danger = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF0DCAF0);
  static const Color secondary = Color(0xFF6C757D);
  static const Color dark = Color(0xFF212529);
  static const Color light = Color(0xFFF8F9FA);

  static ThemeData get light_ => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
    ),
    scaffoldBackgroundColor: light,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle:
        const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCED4DA)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCED4DA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  static Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return success; // সবুজ (সফল ডেলিভারি)
      case 'CANCELLED':
      case 'RETURNED':
        return danger; // লাল (বাতিল বা রিটার্ন)
      case 'OUT_FOR_DELIVERY':
      case 'SHIPPED':
        return info; // আসমানী/সায়ান (পথে রয়েছে)
      case 'PROCESSING':
      case 'CONFIRMED':
        return warning; // হলুদ/কমলা (প্রসেসিং বা কনফার্মড)
      case 'REFUNDED':
        return const Color(0xFF6F42C1); // পার্পল (রিফান্ডেড)
      case 'PENDING':
      default:
        return secondary; //াইকট/ধূসর (পেন্ডিং বা ডিফল্ট)
    }
  }
}