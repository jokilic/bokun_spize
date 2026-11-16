import 'package:material_ui/material_ui.dart';

import 'colors.dart';

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

  static const TextStyle smallButton = dateTimeButton;

  ///
  /// TEXT FIELDS
  ///

  static const TextStyle textFieldLabel = appBarValueUnit;

  static const TextStyle textFieldText = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle textFieldHint = textFieldText;

  static const TextStyle smallTextFieldText = TextStyle(
    fontFamily: plusJakartaSansFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle smallTextFieldHint = smallTextFieldText;

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
  static const TextStyle calendarToday = listTileTitle;
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

  static const TextStyle timePickerDisabledValue = timePickerInactiveValue;

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

  static const TextStyle accountMetricValue = dateTimeButton;

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

enum BokunSpizeTextStyleToken {
  appBarTitle(BokunSpizeTextStyles.appBarTitle),
  appBarCaption(BokunSpizeTextStyles.appBarCaption),
  appBarPrimaryValue(BokunSpizeTextStyles.appBarPrimaryValue),
  expandedAppBarPrimaryValue(BokunSpizeTextStyles.expandedAppBarPrimaryValue),
  appBarValueUnit(BokunSpizeTextStyles.appBarValueUnit),
  expandedAppBarValueUnit(BokunSpizeTextStyles.expandedAppBarValueUnit),
  appBarCalorieValue(BokunSpizeTextStyles.appBarCalorieValue),
  appBarComparisonValue(BokunSpizeTextStyles.appBarComparisonValue),
  appBarComparisonUnit(BokunSpizeTextStyles.appBarComparisonUnit),
  appBarNutritionLabel(BokunSpizeTextStyles.appBarNutritionLabel),
  appBarNutritionValue(BokunSpizeTextStyles.appBarNutritionValue),
  appBarNutritionUnit(BokunSpizeTextStyles.appBarNutritionUnit),
  expandedAppBarNutritionLabel(BokunSpizeTextStyles.expandedAppBarNutritionLabel),
  expandedAppBarNutritionValue(BokunSpizeTextStyles.expandedAppBarNutritionValue),
  sheetTitle(BokunSpizeTextStyles.sheetTitle),
  screenTitle(BokunSpizeTextStyles.screenTitle),
  sheetSubtitle(BokunSpizeTextStyles.sheetSubtitle),
  screenSubtitle(BokunSpizeTextStyles.screenSubtitle),
  sectionTitle(BokunSpizeTextStyles.sectionTitle),
  compactFieldLabel(BokunSpizeTextStyles.compactFieldLabel),
  dateTimeSummary(BokunSpizeTextStyles.dateTimeSummary),
  mainButton(BokunSpizeTextStyles.mainButton),
  secondaryButton(BokunSpizeTextStyles.secondaryButton),
  secondaryAction(BokunSpizeTextStyles.secondaryAction),
  inlineAction(BokunSpizeTextStyles.inlineAction),
  imageSourceAction(BokunSpizeTextStyles.imageSourceAction),
  dateTimeButton(BokunSpizeTextStyles.dateTimeButton),
  smallButton(BokunSpizeTextStyles.smallButton),
  textFieldLabel(BokunSpizeTextStyles.textFieldLabel),
  textFieldText(BokunSpizeTextStyles.textFieldText),
  textFieldHint(BokunSpizeTextStyles.textFieldHint),
  smallTextFieldText(BokunSpizeTextStyles.smallTextFieldText),
  smallTextFieldHint(BokunSpizeTextStyles.smallTextFieldHint),
  textFieldTrailingText(BokunSpizeTextStyles.textFieldTrailingText),
  navigationBarLabel(BokunSpizeTextStyles.navigationBarLabel),
  listTileEmoji(BokunSpizeTextStyles.listTileEmoji),
  accountListTileEmoji(BokunSpizeTextStyles.accountListTileEmoji),
  listTileTitle(BokunSpizeTextStyles.listTileTitle),
  listTileSubtitle(BokunSpizeTextStyles.listTileSubtitle),
  listTileNutritionValue(BokunSpizeTextStyles.listTileNutritionValue),
  listTileCaloriesValue(BokunSpizeTextStyles.listTileCaloriesValue),
  listTileCaloriesUnit(BokunSpizeTextStyles.listTileCaloriesUnit),
  listTilePrimaryValue(BokunSpizeTextStyles.listTilePrimaryValue),
  listTilePrimaryValueUnit(BokunSpizeTextStyles.listTilePrimaryValueUnit),
  listTileStatus(BokunSpizeTextStyles.listTileStatus),
  emptyStateTitle(BokunSpizeTextStyles.emptyStateTitle),
  emptyStateDescription(BokunSpizeTextStyles.emptyStateDescription),
  snackbarText(BokunSpizeTextStyles.snackbarText),
  graphTitle(BokunSpizeTextStyles.graphTitle),
  successStateTitle(BokunSpizeTextStyles.successStateTitle),
  graphMenuItem(BokunSpizeTextStyles.graphMenuItem),
  graphMenuButton(BokunSpizeTextStyles.graphMenuButton),
  graphNoData(BokunSpizeTextStyles.graphNoData),
  graphTooltipDate(BokunSpizeTextStyles.graphTooltipDate),
  graphTooltipValue(BokunSpizeTextStyles.graphTooltipValue),
  graphAxisLabel(BokunSpizeTextStyles.graphAxisLabel),
  calendarWeekdayLabel(BokunSpizeTextStyles.calendarWeekdayLabel),
  calendarControl(BokunSpizeTextStyles.calendarControl),
  calendarDay(BokunSpizeTextStyles.calendarDay),
  calendarToday(BokunSpizeTextStyles.calendarToday),
  calendarSelectedDay(BokunSpizeTextStyles.calendarSelectedDay),
  calendarPeriod(BokunSpizeTextStyles.calendarPeriod),
  calendarSelectedPeriod(BokunSpizeTextStyles.calendarSelectedPeriod),
  timePickerActiveValue(BokunSpizeTextStyles.timePickerActiveValue),
  timePickerInactiveValue(BokunSpizeTextStyles.timePickerInactiveValue),
  timePickerDisabledValue(BokunSpizeTextStyles.timePickerDisabledValue),
  metricEditorValue(BokunSpizeTextStyles.metricEditorValue),
  metricEditorUnit(BokunSpizeTextStyles.metricEditorUnit),
  accountMetricValue(BokunSpizeTextStyles.accountMetricValue),
  macroCardTitle(BokunSpizeTextStyles.macroCardTitle),
  macroCardValue(BokunSpizeTextStyles.macroCardValue),
  macroCardDetail(BokunSpizeTextStyles.macroCardDetail),
  infoCardTitle(BokunSpizeTextStyles.infoCardTitle),
  infoCardDescription(BokunSpizeTextStyles.infoCardDescription),
  goalCalculationLabel(BokunSpizeTextStyles.goalCalculationLabel),
  goalCalculationValue(BokunSpizeTextStyles.goalCalculationValue),
  rulerLabel(BokunSpizeTextStyles.rulerLabel),
  weightPickerValue(BokunSpizeTextStyles.weightPickerValue),
  weightPickerUnit(BokunSpizeTextStyles.weightPickerUnit),
  entranceTitle(BokunSpizeTextStyles.entranceTitle),
  entranceSeparator(BokunSpizeTextStyles.entranceSeparator),
  entranceSwitchAction(BokunSpizeTextStyles.entranceSwitchAction),
  appVersion(BokunSpizeTextStyles.appVersion),
  largeEmoji(BokunSpizeTextStyles.largeEmoji);

  final TextStyle style;

  const BokunSpizeTextStyleToken(this.style);
}

class BokunSpizeTextThemesExtension extends ThemeExtension<BokunSpizeTextThemesExtension> {
  final Map<BokunSpizeTextStyleToken, TextStyle> styles;

  BokunSpizeTextThemesExtension({
    required Map<BokunSpizeTextStyleToken, TextStyle> styles,
  }) : styles = Map.unmodifiable(styles);

  /// Resolves the themed style for the requested semantic token
  TextStyle resolve(BokunSpizeTextStyleToken token) => styles[token]!;

  TextStyle get appBarTitle => resolve(BokunSpizeTextStyleToken.appBarTitle);
  TextStyle get appBarCaption => resolve(BokunSpizeTextStyleToken.appBarCaption);
  TextStyle get appBarPrimaryValue => resolve(BokunSpizeTextStyleToken.appBarPrimaryValue);
  TextStyle get expandedAppBarPrimaryValue => resolve(BokunSpizeTextStyleToken.expandedAppBarPrimaryValue);
  TextStyle get appBarValueUnit => resolve(BokunSpizeTextStyleToken.appBarValueUnit);
  TextStyle get expandedAppBarValueUnit => resolve(BokunSpizeTextStyleToken.expandedAppBarValueUnit);
  TextStyle get appBarCalorieValue => resolve(BokunSpizeTextStyleToken.appBarCalorieValue);
  TextStyle get appBarComparisonValue => resolve(BokunSpizeTextStyleToken.appBarComparisonValue);
  TextStyle get appBarComparisonUnit => resolve(BokunSpizeTextStyleToken.appBarComparisonUnit);
  TextStyle get appBarNutritionLabel => resolve(BokunSpizeTextStyleToken.appBarNutritionLabel);
  TextStyle get appBarNutritionValue => resolve(BokunSpizeTextStyleToken.appBarNutritionValue);
  TextStyle get appBarNutritionUnit => resolve(BokunSpizeTextStyleToken.appBarNutritionUnit);
  TextStyle get expandedAppBarNutritionLabel => resolve(BokunSpizeTextStyleToken.expandedAppBarNutritionLabel);
  TextStyle get expandedAppBarNutritionValue => resolve(BokunSpizeTextStyleToken.expandedAppBarNutritionValue);
  TextStyle get sheetTitle => resolve(BokunSpizeTextStyleToken.sheetTitle);
  TextStyle get screenTitle => resolve(BokunSpizeTextStyleToken.screenTitle);
  TextStyle get sheetSubtitle => resolve(BokunSpizeTextStyleToken.sheetSubtitle);
  TextStyle get screenSubtitle => resolve(BokunSpizeTextStyleToken.screenSubtitle);
  TextStyle get sectionTitle => resolve(BokunSpizeTextStyleToken.sectionTitle);
  TextStyle get compactFieldLabel => resolve(BokunSpizeTextStyleToken.compactFieldLabel);
  TextStyle get dateTimeSummary => resolve(BokunSpizeTextStyleToken.dateTimeSummary);
  TextStyle get mainButton => resolve(BokunSpizeTextStyleToken.mainButton);
  TextStyle get secondaryButton => resolve(BokunSpizeTextStyleToken.secondaryButton);
  TextStyle get secondaryAction => resolve(BokunSpizeTextStyleToken.secondaryAction);
  TextStyle get inlineAction => resolve(BokunSpizeTextStyleToken.inlineAction);
  TextStyle get imageSourceAction => resolve(BokunSpizeTextStyleToken.imageSourceAction);
  TextStyle get dateTimeButton => resolve(BokunSpizeTextStyleToken.dateTimeButton);
  TextStyle get smallButton => resolve(BokunSpizeTextStyleToken.smallButton);
  TextStyle get textFieldLabel => resolve(BokunSpizeTextStyleToken.textFieldLabel);
  TextStyle get textFieldText => resolve(BokunSpizeTextStyleToken.textFieldText);
  TextStyle get textFieldHint => resolve(BokunSpizeTextStyleToken.textFieldHint);
  TextStyle get smallTextFieldText => resolve(BokunSpizeTextStyleToken.smallTextFieldText);
  TextStyle get smallTextFieldHint => resolve(BokunSpizeTextStyleToken.smallTextFieldHint);
  TextStyle get textFieldTrailingText => resolve(BokunSpizeTextStyleToken.textFieldTrailingText);
  TextStyle get navigationBarLabel => resolve(BokunSpizeTextStyleToken.navigationBarLabel);
  TextStyle get listTileEmoji => resolve(BokunSpizeTextStyleToken.listTileEmoji);
  TextStyle get accountListTileEmoji => resolve(BokunSpizeTextStyleToken.accountListTileEmoji);
  TextStyle get listTileTitle => resolve(BokunSpizeTextStyleToken.listTileTitle);
  TextStyle get listTileSubtitle => resolve(BokunSpizeTextStyleToken.listTileSubtitle);
  TextStyle get listTileNutritionValue => resolve(BokunSpizeTextStyleToken.listTileNutritionValue);
  TextStyle get listTileCaloriesValue => resolve(BokunSpizeTextStyleToken.listTileCaloriesValue);
  TextStyle get listTileCaloriesUnit => resolve(BokunSpizeTextStyleToken.listTileCaloriesUnit);
  TextStyle get listTilePrimaryValue => resolve(BokunSpizeTextStyleToken.listTilePrimaryValue);
  TextStyle get listTilePrimaryValueUnit => resolve(BokunSpizeTextStyleToken.listTilePrimaryValueUnit);
  TextStyle get listTileStatus => resolve(BokunSpizeTextStyleToken.listTileStatus);
  TextStyle get emptyStateTitle => resolve(BokunSpizeTextStyleToken.emptyStateTitle);
  TextStyle get emptyStateDescription => resolve(BokunSpizeTextStyleToken.emptyStateDescription);
  TextStyle get snackbarText => resolve(BokunSpizeTextStyleToken.snackbarText);
  TextStyle get graphTitle => resolve(BokunSpizeTextStyleToken.graphTitle);
  TextStyle get successStateTitle => resolve(BokunSpizeTextStyleToken.successStateTitle);
  TextStyle get graphMenuItem => resolve(BokunSpizeTextStyleToken.graphMenuItem);
  TextStyle get graphMenuButton => resolve(BokunSpizeTextStyleToken.graphMenuButton);
  TextStyle get graphNoData => resolve(BokunSpizeTextStyleToken.graphNoData);
  TextStyle get graphTooltipDate => resolve(BokunSpizeTextStyleToken.graphTooltipDate);
  TextStyle get graphTooltipValue => resolve(BokunSpizeTextStyleToken.graphTooltipValue);
  TextStyle get graphAxisLabel => resolve(BokunSpizeTextStyleToken.graphAxisLabel);
  TextStyle get calendarWeekdayLabel => resolve(BokunSpizeTextStyleToken.calendarWeekdayLabel);
  TextStyle get calendarControl => resolve(BokunSpizeTextStyleToken.calendarControl);
  TextStyle get calendarDay => resolve(BokunSpizeTextStyleToken.calendarDay);
  TextStyle get calendarToday => resolve(BokunSpizeTextStyleToken.calendarToday);
  TextStyle get calendarSelectedDay => resolve(BokunSpizeTextStyleToken.calendarSelectedDay);
  TextStyle get calendarPeriod => resolve(BokunSpizeTextStyleToken.calendarPeriod);
  TextStyle get calendarSelectedPeriod => resolve(BokunSpizeTextStyleToken.calendarSelectedPeriod);
  TextStyle get timePickerActiveValue => resolve(BokunSpizeTextStyleToken.timePickerActiveValue);
  TextStyle get timePickerInactiveValue => resolve(BokunSpizeTextStyleToken.timePickerInactiveValue);
  TextStyle get timePickerDisabledValue => resolve(BokunSpizeTextStyleToken.timePickerDisabledValue);
  TextStyle get metricEditorValue => resolve(BokunSpizeTextStyleToken.metricEditorValue);
  TextStyle get metricEditorUnit => resolve(BokunSpizeTextStyleToken.metricEditorUnit);
  TextStyle get accountMetricValue => resolve(BokunSpizeTextStyleToken.accountMetricValue);
  TextStyle get macroCardTitle => resolve(BokunSpizeTextStyleToken.macroCardTitle);
  TextStyle get macroCardValue => resolve(BokunSpizeTextStyleToken.macroCardValue);
  TextStyle get macroCardDetail => resolve(BokunSpizeTextStyleToken.macroCardDetail);
  TextStyle get infoCardTitle => resolve(BokunSpizeTextStyleToken.infoCardTitle);
  TextStyle get infoCardDescription => resolve(BokunSpizeTextStyleToken.infoCardDescription);
  TextStyle get goalCalculationLabel => resolve(BokunSpizeTextStyleToken.goalCalculationLabel);
  TextStyle get goalCalculationValue => resolve(BokunSpizeTextStyleToken.goalCalculationValue);
  TextStyle get rulerLabel => resolve(BokunSpizeTextStyleToken.rulerLabel);
  TextStyle get weightPickerValue => resolve(BokunSpizeTextStyleToken.weightPickerValue);
  TextStyle get weightPickerUnit => resolve(BokunSpizeTextStyleToken.weightPickerUnit);
  TextStyle get entranceTitle => resolve(BokunSpizeTextStyleToken.entranceTitle);
  TextStyle get entranceSeparator => resolve(BokunSpizeTextStyleToken.entranceSeparator);
  TextStyle get entranceSwitchAction => resolve(BokunSpizeTextStyleToken.entranceSwitchAction);
  TextStyle get appVersion => resolve(BokunSpizeTextStyleToken.appVersion);
  TextStyle get largeEmoji => resolve(BokunSpizeTextStyleToken.largeEmoji);

  /// Merges replacement styles into the current themed typography map
  @override
  BokunSpizeTextThemesExtension copyWith({
    Map<BokunSpizeTextStyleToken, TextStyle>? styles,
  }) {
    if (styles == null || styles.isEmpty) {
      return this;
    }

    return BokunSpizeTextThemesExtension(
      styles: {
        ...this.styles,
        ...styles,
      },
    );
  }

  /// Interpolates every semantic style during animated theme transitions
  @override
  BokunSpizeTextThemesExtension lerp(
    covariant BokunSpizeTextThemesExtension? other,
    double t,
  ) {
    if (other == null) {
      return this;
    }

    final lerpedStyles = <BokunSpizeTextStyleToken, TextStyle>{};
    for (final token in BokunSpizeTextStyleToken.values) {
      lerpedStyles[token] = TextStyle.lerp(resolve(token), other.resolve(token), t)!;
    }

    return BokunSpizeTextThemesExtension(styles: lerpedStyles);
  }
}

/// Creates a complete themed typography map from the app color extension
BokunSpizeTextThemesExtension getTextThemesExtension({
  required BokunSpizeColorsExtension colorsExtension,
}) {
  final styles = <BokunSpizeTextStyleToken, TextStyle>{
    for (final token in BokunSpizeTextStyleToken.values)
      token: token.style.copyWith(
        color: colorsExtension.text,
      ),
  };

  ///
  /// ON COLORED SURFACES
  ///

  styles[BokunSpizeTextStyleToken.mainButton] = BokunSpizeTextStyleToken.mainButton.style.copyWith(
    color: colorsExtension.buttonText,
  );
  styles[BokunSpizeTextStyleToken.graphTooltipDate] = BokunSpizeTextStyleToken.graphTooltipDate.style.copyWith(
    color: colorsExtension.buttonText.withValues(alpha: 0.7),
  );
  styles[BokunSpizeTextStyleToken.graphTooltipValue] = BokunSpizeTextStyleToken.graphTooltipValue.style.copyWith(
    color: colorsExtension.buttonText,
  );
  styles[BokunSpizeTextStyleToken.calendarSelectedDay] = BokunSpizeTextStyleToken.calendarSelectedDay.style.copyWith(
    color: colorsExtension.buttonText,
  );
  styles[BokunSpizeTextStyleToken.calendarSelectedPeriod] = BokunSpizeTextStyleToken.calendarSelectedPeriod.style.copyWith(
    color: colorsExtension.listTileBackground,
  );

  ///
  /// MUTED TEXT
  ///

  styles[BokunSpizeTextStyleToken.compactFieldLabel] = BokunSpizeTextStyleToken.compactFieldLabel.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.5),
  );
  styles[BokunSpizeTextStyleToken.textFieldLabel] = BokunSpizeTextStyleToken.textFieldLabel.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.5),
  );
  styles[BokunSpizeTextStyleToken.textFieldHint] = BokunSpizeTextStyleToken.textFieldHint.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.5),
  );
  styles[BokunSpizeTextStyleToken.smallTextFieldHint] = BokunSpizeTextStyleToken.smallTextFieldHint.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.5),
  );
  styles[BokunSpizeTextStyleToken.accountListTileEmoji] = BokunSpizeTextStyleToken.accountListTileEmoji.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.7),
  );
  styles[BokunSpizeTextStyleToken.listTileSubtitle] = BokunSpizeTextStyleToken.listTileSubtitle.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.7),
  );
  styles[BokunSpizeTextStyleToken.listTileCaloriesUnit] = BokunSpizeTextStyleToken.listTileCaloriesUnit.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.5),
  );
  styles[BokunSpizeTextStyleToken.listTilePrimaryValueUnit] = BokunSpizeTextStyleToken.listTilePrimaryValueUnit.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.7),
  );
  styles[BokunSpizeTextStyleToken.emptyStateDescription] = BokunSpizeTextStyleToken.emptyStateDescription.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.75),
  );
  styles[BokunSpizeTextStyleToken.graphNoData] = BokunSpizeTextStyleToken.graphNoData.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.4),
  );
  styles[BokunSpizeTextStyleToken.graphAxisLabel] = BokunSpizeTextStyleToken.graphAxisLabel.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.7),
  );
  styles[BokunSpizeTextStyleToken.timePickerInactiveValue] = BokunSpizeTextStyleToken.timePickerInactiveValue.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.45),
  );
  styles[BokunSpizeTextStyleToken.timePickerDisabledValue] = BokunSpizeTextStyleToken.timePickerDisabledValue.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.2),
  );
  styles[BokunSpizeTextStyleToken.metricEditorUnit] = BokunSpizeTextStyleToken.metricEditorUnit.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.7),
  );
  styles[BokunSpizeTextStyleToken.accountMetricValue] = BokunSpizeTextStyleToken.accountMetricValue.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.7),
  );
  styles[BokunSpizeTextStyleToken.macroCardDetail] = BokunSpizeTextStyleToken.macroCardDetail.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.75),
  );
  styles[BokunSpizeTextStyleToken.infoCardDescription] = BokunSpizeTextStyleToken.infoCardDescription.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.7),
  );
  styles[BokunSpizeTextStyleToken.goalCalculationLabel] = BokunSpizeTextStyleToken.goalCalculationLabel.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.5),
  );
  styles[BokunSpizeTextStyleToken.goalCalculationValue] = BokunSpizeTextStyleToken.goalCalculationValue.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.7),
  );
  styles[BokunSpizeTextStyleToken.weightPickerUnit] = BokunSpizeTextStyleToken.weightPickerUnit.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.7),
  );
  styles[BokunSpizeTextStyleToken.entranceSeparator] = BokunSpizeTextStyleToken.entranceSeparator.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.5),
  );
  styles[BokunSpizeTextStyleToken.appVersion] = BokunSpizeTextStyleToken.appVersion.style.copyWith(
    color: colorsExtension.text.withValues(alpha: 0.7),
  );

  return BokunSpizeTextThemesExtension(styles: styles);
}
