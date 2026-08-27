import 'package:phosphor_icons/phosphor_icons.dart';

enum Sex {
  male,
  female,
}

extension SexExtension on Sex {
  String get localName => switch (this) {
    Sex.male => 'Muško',
    Sex.female => 'Žensko',
  };

  PhosphorIconData get icon => switch (this) {
    Sex.male => PhosphorIcons.genderMale(
      PhosphorIconsStyle.bold,
    ),
    Sex.female => PhosphorIcons.genderFemale(
      PhosphorIconsStyle.bold,
    ),
  };
}
