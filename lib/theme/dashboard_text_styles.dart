import 'package:flutter/material.dart';
import 'dashboard_colors.dart';

/// All TextStyle definitions used across Dashboard_path screens.
/// Centralises font-family (Poppins), font sizes, weights and colors.
class DashboardTextStyles {
  static const String _font = 'Poppins';

  // ── Section / Card headings ──────────────────────────────────────
  static const TextStyle cardTitle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: DashboardColors.textDark,
  );

  static const TextStyle cardTitleSm = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: DashboardColors.textDark,
  );

  // ── Amount / large number display ────────────────────────────────
  static const TextStyle amountLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: DashboardColors.textDark,
  );

  static const TextStyle amountMedium = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: DashboardColors.textDark2,
  );

  static const TextStyle amountSmall = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 14,
    color: DashboardColors.textDark,
  );

  // ── Expense item ─────────────────────────────────────────────────
  static const TextStyle expenseCategory = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13,
    color: DashboardColors.textDark,
  );

  static const TextStyle expenseDate = TextStyle(
    fontSize: 11,
    color: Colors.grey,
  );

  static const TextStyle expenseAmountRed = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 14,
    color: DashboardColors.red,
  );

  static const TextStyle expenseAmountHighlight = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 14,
    color: DashboardColors.amber,
  );

  // ── History list tile ────────────────────────────────────────────
  static const TextStyle historyCategory = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: DashboardColors.textDark2,
  );

  static const TextStyle historyNote = TextStyle(
    fontSize: 12,
    color: DashboardColors.textLight,
    height: 1.4,
  );

  static const TextStyle historyAmount = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: DashboardColors.textAmber,
  );

  // ── Stat cards ───────────────────────────────────────────────────
  static const TextStyle statCardTitle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 12,
    color: DashboardColors.textDark,
  );

  static const TextStyle statCardSubtitle = TextStyle(
    fontSize: 11,
    color: Colors.grey,
    height: 1.4,
  );

  static const TextStyle statBadge = TextStyle(
    fontSize: 9,
    color: DashboardColors.green,
  );

  static const TextStyle statBadgePercent = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 13,
  );

  // ── Labels / captions ────────────────────────────────────────────
  static const TextStyle sectionLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: DashboardColors.textLight,
    letterSpacing: 0.2,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    color: Colors.grey,
  );

  static const TextStyle captionMedium = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    color: DashboardColors.textMuted,
  );

  // ── Buttons / links ──────────────────────────────────────────────
  static const TextStyle linkBlue = TextStyle(
    color: DashboardColors.accent,
    fontSize: 13,
  );

  static const TextStyle linkBlueBold = TextStyle(
    color: DashboardColors.accent,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle saveButtonLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: Colors.white,
  );

  static const TextStyle navItemSelected = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 11,
  );

  static const TextStyle navItemUnselected = TextStyle(fontSize: 11);

  // ── Greeting header ──────────────────────────────────────────────
  static const TextStyle greetingTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: DashboardColors.textDark,
  );

  static const TextStyle greetingSubtitle = TextStyle(
    fontSize: 11,
    color: Colors.grey,
  );

  // ── AddExpense screen ────────────────────────────────────────────
  static const TextStyle addExpenseTopBarTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: DashboardColors.textDark2,
  );

  static const TextStyle amountDisplay = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: DashboardColors.textDark2,
  );

  static const TextStyle amountDisplayAutoFill = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: DashboardColors.teal,
  );

  static const TextStyle scanBannerTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: DashboardColors.textOrange,
  );

  static const TextStyle categoryChipLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: DashboardColors.textMuted,
  );

  static const TextStyle categoryChipLabelSelected = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: DashboardColors.chipSelectedBorder,
  );

  static const TextStyle receiptLabel = TextStyle(
    fontSize: 13,
    color: DashboardColors.textMuted,
  );

  static const TextStyle receiptValue = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: DashboardColors.textDark2,
  );

  static const TextStyle receiptTotal = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: DashboardColors.teal,
  );

  static const TextStyle scanningLabel = TextStyle(
    color: Colors.white,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle autoFillBannerText = TextStyle(
    fontSize: 12,
    color: DashboardColors.textGreen,
    fontWeight: FontWeight.w500,
  );

  // ── Expense history header ────────────────────────────────────────
  static const TextStyle historyPageTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: DashboardColors.tealAlt,
    letterSpacing: -0.3,
    decoration: TextDecoration.underline,
    decorationColor: DashboardColors.tealAlt,
    decorationThickness: 1.5,
  );

  static const TextStyle historyPeriodText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFF3C3C3E),
  );

  static const TextStyle filterChipLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Color(0xFF3C3C3E),
  );

  static const TextStyle filterChipLabelSelected = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // ── Profile screen ───────────────────────────────────────────────
  static const TextStyle profileName = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: DashboardColors.textProfile,
  );

  static const TextStyle profileEmail = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: DashboardColors.textProfileSub,
  );

  static const TextStyle profileSectionLabel = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: DashboardColors.textProfile,
  );

  static const TextStyle profileMenuTitle = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: DashboardColors.textProfile,
  );

  static const TextStyle profileMenuSubtitle = TextStyle(
    fontFamily: _font,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: DashboardColors.textProfileSub,
  );

  static const TextStyle profileEditButton = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFFF3F3F3),
  );

  static const TextStyle profileLogout = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: DashboardColors.logoutRed,
  );

  static const TextStyle dialogTitle = TextStyle(
    fontFamily: _font,
    fontWeight: FontWeight.w600,
    color: DashboardColors.textProfile,
  );

  static const TextStyle dialogBody = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    color: DashboardColors.textProfileSub,
  );

  // ── Monthly analytics percentage badge ───────────────────────────
  static TextStyle percentBadge(bool isIncrease) => TextStyle(
    fontSize: 12,
    color: isIncrease ? DashboardColors.green : DashboardColors.red,
    fontWeight: FontWeight.w600,
  );
}
