import 'package:flutter/material.dart';

import 'colors.dart';
import 'text_style.dart';
import 'theme.dart';

extension BokunSpizeThemeExtension on ThemeData {
  BokunSpizeColorsExtension get bokunSpizeColors =>
      extension<BokunSpizeColorsExtension>() ??
      BokunSpizeTheme.getLightAppColors(
        primaryColor: BokunSpizeColors.bokunSpizeGreen,
      );
  BokunSpizeTextThemesExtension get bokunSpizeTextStyles =>
      extension<BokunSpizeTextThemesExtension>() ??
      BokunSpizeTheme.getLightTextTheme(
        primaryColor: BokunSpizeColors.bokunSpizeGreen,
      );
}

extension ThemeGetter on BuildContext {
  ThemeData get theme => Theme.of(this);
  BokunSpizeColorsExtension get colors => theme.bokunSpizeColors;
  BokunSpizeTextThemesExtension get textStyles => theme.bokunSpizeTextStyles;
}

BokunSpizeTextThemesExtension getTextThemesExtension({
  required BokunSpizeColorsExtension colorsExtension,
}) => BokunSpizeTextThemesExtension(
  button: BokunSpizeTextStyles.button.copyWith(
    color: colorsExtension.text,
  ),
  appBarTitleSmall: BokunSpizeTextStyles.appBarTitleSmall.copyWith(
    color: colorsExtension.text,
  ),
  appBarTitleBig: BokunSpizeTextStyles.appBarTitleBig.copyWith(
    color: colorsExtension.text,
  ),
  appBarSubtitleBig: BokunSpizeTextStyles.appBarSubtitleBig.copyWith(
    color: colorsExtension.text,
  ),
  homeFloatingActionButton: BokunSpizeTextStyles.homeFloatingActionButton.copyWith(
    color: colorsExtension.text,
  ),
  homeMonthChip: BokunSpizeTextStyles.homeMonthChip.copyWith(
    color: colorsExtension.text,
  ),
  homeCategoryTitle: BokunSpizeTextStyles.homeCategoryTitle.copyWith(
    color: colorsExtension.text,
  ),
  homeTransactionTitle: BokunSpizeTextStyles.homeTransactionTitle.copyWith(
    color: colorsExtension.text,
  ),
  homeTransactionTime: BokunSpizeTextStyles.homeTransactionTime.copyWith(
    color: colorsExtension.text,
  ),
  homeTransactionNote: BokunSpizeTextStyles.homeTransactionNote.copyWith(
    color: colorsExtension.text,
  ),
  homeTransactionNoteBold: BokunSpizeTextStyles.homeTransactionNoteBold.copyWith(
    color: colorsExtension.text,
  ),
  homeTransactionValue: BokunSpizeTextStyles.homeTransactionValue.copyWith(
    color: colorsExtension.text,
  ),
  homeTransactionEuro: BokunSpizeTextStyles.homeTransactionEuro.copyWith(
    color: colorsExtension.text,
  ),
  homeTitle: BokunSpizeTextStyles.homeTitle.copyWith(
    color: colorsExtension.text,
  ),
  homeTitleBold: BokunSpizeTextStyles.homeTitleBold.copyWith(
    color: colorsExtension.text,
  ),
  homeTitleEuro: BokunSpizeTextStyles.homeTitleEuro.copyWith(
    color: colorsExtension.text,
  ),
  transactionAmountCurrentValue: BokunSpizeTextStyles.transactionAmountCurrentValue.copyWith(
    color: colorsExtension.text,
  ),
  transactionAmountNumber: BokunSpizeTextStyles.transactionAmountNumber.copyWith(
    color: colorsExtension.text,
  ),
  textField: BokunSpizeTextStyles.textField.copyWith(
    color: colorsExtension.text,
  ),
  transactionCategoryName: BokunSpizeTextStyles.transactionCategoryName.copyWith(
    color: colorsExtension.text,
  ),
  transactionTimeActive: BokunSpizeTextStyles.transactionTimeActive.copyWith(
    color: colorsExtension.text,
  ),
  transactionTimeInactive: BokunSpizeTextStyles.transactionTimeInactive.copyWith(
    color: colorsExtension.text,
  ),
  transactionDateInactive: BokunSpizeTextStyles.transactionDateInactive.copyWith(
    color: colorsExtension.text,
  ),
  transactionDateActive: BokunSpizeTextStyles.transactionDateActive.copyWith(
    color: colorsExtension.listTileBackground,
  ),
  categoryName: BokunSpizeTextStyles.categoryName.copyWith(
    color: colorsExtension.text,
  ),
  categoryIcon: BokunSpizeTextStyles.categoryIcon.copyWith(
    color: colorsExtension.text,
  ),
);
