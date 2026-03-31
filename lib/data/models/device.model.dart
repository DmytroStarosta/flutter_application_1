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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'temperature': temperature,
      'humidity': humidity,
      'pressure': pressure,
    };
  }

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
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
