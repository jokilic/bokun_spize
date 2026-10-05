import 'dart:convert';

class IOSDeviceData {
  final String localizedModel;
  final String model;
  final String modelName;
  final String name;
  final String systemName;

  IOSDeviceData({
    required this.localizedModel,
    required this.model,
    required this.modelName,
    required this.name,
    required this.systemName,
  });

  IOSDeviceData copyWith({
    String? localizedModel,
    String? model,
    String? modelName,
    String? name,
    String? systemName,
  }) => IOSDeviceData(
    localizedModel: localizedModel ?? this.localizedModel,
    model: model ?? this.model,
    modelName: modelName ?? this.modelName,
    name: name ?? this.name,
    systemName: systemName ?? this.systemName,
  );

  factory IOSDeviceData.fromMap(Map<String, dynamic> map) => IOSDeviceData(
    localizedModel: map['localizedModel'] as String,
    model: map['model'] as String,
    modelName: map['modelName'] as String,
    name: map['name'] as String,
    systemName: map['systemName'] as String,
  );

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
    'localizedModel': localizedModel,
    'model': model,
    'modelName': modelName,
    'name': name,
    'systemName': systemName,
  };

  @override
  String toString() => 'IOSDeviceData(localizedModel: $localizedModel, model: $model, modelName: $modelName, name: $name, systemName: $systemName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IOSDeviceData &&
          runtimeType == other.runtimeType &&
          localizedModel == other.localizedModel &&
          model == other.model &&
          modelName == other.modelName &&
          name == other.name &&
          systemName == other.systemName;

  @override
  int get hashCode => localizedModel.hashCode ^ model.hashCode ^ modelName.hashCode ^ name.hashCode ^ systemName.hashCode;
}
