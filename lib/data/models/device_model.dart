class DeviceModel {
  final String id;
  final String name;
  final String location;
  final double temperature;
  final double humidity;
  final double pressure;

  const DeviceModel({
    required this.id,
    required this.name,
    required this.location,
    this.temperature = 0.0,
    this.humidity = 0.0,
    this.pressure = 0.0,
  });

  // Метод для створення копії об'єкта зі зміненими полями
  DeviceModel copyWith({
    String? id,
    String? name,
    String? location,
    double? temperature,
    double? humidity,
    double? pressure,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      pressure: pressure ?? this.pressure,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'temperature': temperature,
      'humidity': humidity,
      'pressure': pressure,
    };
  }

  factory DeviceModel.fromJson(Map<String, dynamic> map) {
    return DeviceModel(
      id: (map['id'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      location: (map['location'] ?? '') as String,
      temperature: (map['temperature'] as num? ?? 0.0).toDouble(),
      humidity: (map['humidity'] as num? ?? 0.0).toDouble(),
      pressure: (map['pressure'] as num? ?? 0.0).toDouble(),
    );
  }
}
