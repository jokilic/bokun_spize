import 'package:hive_ce/hive_ce.dart';

@HiveType(typeId: 6)
enum Sex {
  @HiveField(0)
  male,

  @HiveField(1)
  female,
}
