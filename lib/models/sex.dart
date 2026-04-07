import 'package:hive_ce/hive_ce.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

@HiveType(typeId: 6)
enum Sex {
  @HiveField(0)
  male,

  @HiveField(1)
  female,
}

extension SexExtension on Sex {
  String get name => switch (this) {
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
