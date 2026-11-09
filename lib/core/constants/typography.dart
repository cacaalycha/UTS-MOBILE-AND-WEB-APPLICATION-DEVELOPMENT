import 'package:flutter/material.dart';

/// Skala tipografi Case iPhone Caca.
///
/// Sumber: Worksheet Minggu 4 — hanya empat ukuran:
/// Judul 32 px, Subjudul 24 px, Isi 20 px, Keterangan 18 px.
class AppTypography {
  AppTypography._();

  static const double titleSize = 32;
  static const double subtitleSize = 24;
  static const double bodySize = 20;
  static const double captionSize = 18;

  static const TextStyle title = TextStyle(
    fontSize: titleSize,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: subtitleSize,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontSize: bodySize,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static const TextStyle caption = TextStyle(
    fontSize: captionSize,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// Varian tebal untuk label tombol.
  static const TextStyle button = TextStyle(
    fontSize: bodySize,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
}
