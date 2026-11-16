import 'package:material_ui/material_ui.dart';

/// Shared typography definitions without theme-specific colors
///
/// Component aliases keep typography tied to its UI role when multiple roles share the same style
class BokunSpizeTextStyles {
  static const String epilogueFontFamily = 'Epilogue';
  static const String plusJakartaSansFontFamily = 'PlusJakartaSans';

  ///
  /// APP BAR
  ///

  static const TextStyle appBarTitle = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w900,
    height: 1.2,
    letterSpacing: 0.6,
  );

  static const TextStyle appBarCaption = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
  );

  static const TextStyle appBarPrimaryValue = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: 1.2,
  );

  static const TextStyle expandedAppBarPrimaryValue = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 60,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: 1.2,
  );

  static const TextStyle appBarValueUnit = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
  );

  static const TextStyle expandedAppBarValueUnit = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
  );

  static const TextStyle appBarCalorieValue = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
  );

  static const TextStyle appBarComparisonValue = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle appBarComparisonUnit = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 8,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );

  static const TextStyle appBarNutritionLabel = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 8,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.4,
  );

  static const TextStyle appBarNutritionValue = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 8,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.4,
  );

  static const TextStyle appBarNutritionUnit = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 8,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.4,
  );

  static const TextStyle expandedAppBarNutritionLabel = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.4,
  );

  static const TextStyle expandedAppBarNutritionValue = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.4,
  );

  ///
  /// SHEETS AND SCREENS
  ///

  static const TextStyle sheetTitle = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: 0.6,
  );

  static const TextStyle screenTitle = sheetTitle;

  static const TextStyle sheetSubtitle = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle screenSubtitle = sheetSubtitle;

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.6,
  );

  static const TextStyle compactFieldLabel = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
  );

  static const TextStyle dateTimeSummary = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  ///
  /// BUTTONS AND ACTIONS
  ///

  static const TextStyle mainButton = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle secondaryButton = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.6,
  );

  static const TextStyle secondaryAction = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle inlineAction = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle imageSourceAction = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
  );

  static const TextStyle dateTimeButton = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  ///
  /// TEXT FIELDS
  ///

  static const TextStyle textFieldLabel = appBarValueUnit;

  static const TextStyle textFieldText = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle smallTextFieldText = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle textFieldTrailingText = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  ///
  /// NAVIGATION AND LIST TILES
  ///

  static const TextStyle navigationBarLabel = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle listTileEmoji = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle accountListTileEmoji = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    height: 1,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const TextStyle listTileTitle = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle listTileSubtitle = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle listTileNutritionValue = dateTimeButton;

  static const TextStyle listTileCaloriesValue = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle listTileCaloriesUnit = navigationBarLabel;

  static const TextStyle listTilePrimaryValue = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle listTilePrimaryValueUnit = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 1.2,
  );

  static const TextStyle listTileStatus = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  ///
  /// EMPTY AND SUCCESS STATES
  ///

  static const TextStyle emptyStateTitle = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.6,
  );

  static const TextStyle emptyStateDescription = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.6,
  );

  static const TextStyle snackbarText = dateTimeButton;

  ///
  /// GRAPHS
  ///

  static const TextStyle graphTitle = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.6,
  );

  static const TextStyle successStateTitle = graphTitle;
  static const TextStyle graphMenuItem = secondaryAction;
  static const TextStyle graphMenuButton = secondaryButton;
  static const TextStyle graphNoData = dateTimeButton;

  static const TextStyle graphTooltipDate = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle graphTooltipValue = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle graphAxisLabel = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );

  ///
  /// DATE AND TIME PICKERS
  ///

  static const TextStyle calendarWeekdayLabel = appBarComparisonValue;

  static const TextStyle calendarControl = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle calendarDay = textFieldTrailingText;
  static const TextStyle calendarSelectedDay = listTileTitle;

  static const TextStyle calendarPeriod = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle calendarSelectedPeriod = calendarControl;

  static const TextStyle timePickerActiveValue = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle timePickerInactiveValue = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w500,
  );

  ///
  /// METRICS AND GOALS
  ///

  static const TextStyle metricEditorValue = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle metricEditorUnit = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle macroCardTitle = inlineAction;

  static const TextStyle macroCardValue = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle macroCardDetail = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle infoCardTitle = graphTooltipValue;

  static const TextStyle infoCardDescription = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle goalCalculationLabel = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle goalCalculationValue = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle rulerLabel = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle weightPickerValue = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 56,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle weightPickerUnit = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  ///
  /// ENTRANCE AND ACCOUNT
  ///

  static const TextStyle entranceTitle = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: 0.6,
  );

  static const TextStyle entranceSeparator = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 1,
  );

  static const TextStyle entranceSwitchAction = inlineAction;

  static const TextStyle appVersion = TextStyle(
    fontFamily: epilogueFontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle largeEmoji = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 80,
    fontWeight: FontWeight.w400,
  );
}
