import 'package:hive_ce/hive_ce.dart';

@HiveType(typeId: 3)
class Food {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final double quantity;
  @HiveField(2)
  final String unit;

  Food({
    required this.name,
    required this.quantity,
    required this.unit,
  });
}
