import 'package:phosphor_flutter/phosphor_flutter.dart';

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
      PhosphorIconsStyle.duotone,
    ),
    Sex.female => PhosphorIcons.genderFemale(
      PhosphorIconsStyle.duotone,
    ),
  };
}
