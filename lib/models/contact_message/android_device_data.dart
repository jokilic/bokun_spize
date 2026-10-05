import 'dart:convert';

class AndroidDeviceData {
  final String brand;
  final String device;
  final String manufacturer;
  final String model;
  final String name;

  AndroidDeviceData({
    required this.brand,
    required this.device,
    required this.manufacturer,
    required this.model,
    required this.name,
  });

  AndroidDeviceData copyWith({
    String? brand,
    String? device,
    String? manufacturer,
    String? model,
    String? name,
  }) => AndroidDeviceData(
    brand: brand ?? this.brand,
    device: device ?? this.device,
    manufacturer: manufacturer ?? this.manufacturer,
    model: model ?? this.model,
    name: name ?? this.name,
  );

  factory AndroidDeviceData.fromMap(Map<String, dynamic> map) => AndroidDeviceData(
    brand: map['brand'] as String,
    device: map['device'] as String,
    manufacturer: map['manufacturer'] as String,
    model: map['model'] as String,
    name: map['name'] as String,
  );

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
    'brand': brand,
    'device': device,
    'manufacturer': manufacturer,
    'model': model,
    'name': name,
  };

  @override
  String toString() => 'AndroidDeviceData(brand: $brand, device: $device, manufacturer: $manufacturer, model: $model, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AndroidDeviceData &&
          runtimeType == other.runtimeType &&
          brand == other.brand &&
          device == other.device &&
          manufacturer == other.manufacturer &&
          model == other.model &&
          name == other.name;

  @override
  int get hashCode => brand.hashCode ^ device.hashCode ^ manufacturer.hashCode ^ model.hashCode ^ name.hashCode;
}
