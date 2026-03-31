import 'package:flutter/material.dart';

/// All colors used across Dashboard_path screens.
/// Import this file in any dashboard widget instead of using raw Color(0x...) literals.
class DashboardColors {
  // ── Brand / Primary ────────────────────────────────────────────────
  static const Color primary        = Color(0xFF1A1A2E);   // dark navy — nav, headings
  static const Color accent         = Color(0xFF4A90D9);   // blue — links, chart line
  static const Color teal           = Color(0xFF2D6A5A);   // teal — save button, scan, add-category
  static const Color tealAlt        = Color(0xFF0B8A8A);   // teal alt — expense history header/filter
  static const Color green          = Color(0xFF4CAF50);   // success green
  static const Color red            = Color(0xFFE53935);   // danger red
  static const Color orange         = Color(0xFFFFB347);   // food / warning orange
  static const Color amber          = Color(0xFFF57C00);   // highlight amber
  static const Color logoutRed      = Color(0xFF750909);   // logout text/button color

  // ── Backgrounds ────────────────────────────────────────────────────
  static const Color scaffoldBg     = Color(0xFFF7F8FC);   // main scaffold background
  static const Color cardBg         = Colors.white;
  static const Color highlightBg    = Color(0xFFFFF9C4);   // yellow-tinted expense highlight
  static const Color scanBannerBg   = Color(0xFFFDF3E3);   // warm scan banner
  static const Color autoFillBg     = Color(0xFFE8F5F0);   // autofill success banner
  static const Color scanOverlayBg  = Color(0xFF1C1C1E);   // dark scanning overlay
  static const Color logoutBtnBg    = Color(0xFFEED4D6);   // logout button background

  // ── Category chip ─────────────────────────────────────────────────
  static const Color chipSelected   = Color(0xFFFFEDD5);   // selected category chip
  static const Color chipBorder     = Color(0xFFE5E0D8);   // default chip border
  static const Color chipSelectedBorder = Color(0xFFE06B00); // selected chip text/border

  // ── Text ─────────────────────────────────────────────────────────
  static const Color textDark       = Color(0xFF1A1A2E);   // primary dark text
  static const Color textDark2      = Color(0xFF1C1C1E);   // slightly different dark text
  static const Color textMedium     = Color(0xFF555555);   // period picker text
  static const Color textGrey       = Colors.grey;
  static const Color textLight      = Color(0xFF8A8A8E);   // section labels, muted text
  static const Color textMuted      = Color(0xFF6E6E73);   // category label unselected
  static const Color textHint       = Color(0xFFB0B0B5);   // input hint text
  static const Color textGreen      = Color(0xFF1B5E45);   // autofill banner text
  static const Color textOrange     = Color(0xFF7A5C00);   // scan banner text
  static const Color textAmber      = Color(0xFFB85C1A);   // expense history amount
  static const Color textProfile    = Color(0xFF5A5A5A);   // profile text
  static const Color textProfileSub = Color(0xFF6B6B6B);   // profile subtitle

  // ── Borders / dividers ────────────────────────────────────────────
  static const Color borderDefault  = Color(0xFFE0E0E0);
  static const Color borderLight    = Color(0xFFD0CEC8);
  static const Color borderHighlight= Color(0xFFFFD54F);   // highlighted expense border
  static const Color borderScan     = Color(0xFFEDD9A3);   // scan banner border
  static const Color borderAutoFill = Color(0xFF2D6A5A);   // autofill banner border
  static const Color borderReceipt  = Color(0xFFEEEAE2);   // receipt tile border
  static const Color borderProfile  = Color(0xFFBABABA);   // profile divider

  // ── Chart / data colors ───────────────────────────────────────────
  static const Color chartBlue      = Color(0xFF4FC3F7);
  static const Color chartGreen     = Color(0xFF81C784);
  static const Color chartPurple    = Color(0xFFCE93D8);
  static const Color chartOrange    = Color(0xFFFFB347);
  static const Color chartLineBlue  = Color(0xFF4A90D9);
  static const Color scannerGreen   = Color(0xFF4FD1A5);

  // ── Progress states ───────────────────────────────────────────────
  static const Color progressOnTrack = Color(0xFF4CAF50);
  static const Color progressWarning = Color(0xFFFFB347);
  static const Color progressDanger  = Color(0xFFE53935);
}
