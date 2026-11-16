import 'package:material_ui/material_ui.dart';

import 'colors.dart';
import 'text_style.dart';
import 'theme.dart';

extension BokunSpizeThemeExtension on ThemeData {
  BokunSpizeColorsExtension get bokunSpizeColors => extension<BokunSpizeColorsExtension>() ?? BokunSpizeTheme.lightAppColors;
  BokunSpizeTextThemesExtension get bokunSpizeTextStyles => extension<BokunSpizeTextThemesExtension>() ?? BokunSpizeTheme.lightTextTheme;
}

extension ThemeGetter on BuildContext {
  ThemeData get theme => Theme.of(this);
  BokunSpizeColorsExtension get colors => theme.bokunSpizeColors;
  BokunSpizeTextThemesExtension get textStyles => theme.bokunSpizeTextStyles;
}
