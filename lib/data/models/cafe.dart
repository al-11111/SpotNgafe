class Cafe {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String openHours;
  final int priceMin;
  final int priceMax;
  final bool hasWifi;
  final bool hasOutlet;

  const Cafe({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.openHours,
    required this.priceMin,
    required this.priceMax,
    required this.hasWifi,
    required this.hasOutlet,
  });

  factory Cafe.fromMap(Map<String, dynamic> data, String docId) {
    return Cafe(
      id: docId,
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      openHours: data['openHours'] as String? ?? '',
      priceMin: (data['priceMin'] as num?)?.toInt() ?? 0,
      priceMax: (data['priceMax'] as num?)?.toInt() ?? 0,
      hasWifi: data['hasWifi'] as bool? ?? false,
      hasOutlet: data['hasOutlet'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'openHours': openHours,
      'priceMin': priceMin,
      'priceMax': priceMax,
      'hasWifi': hasWifi,
      'hasOutlet': hasOutlet,
    };
  }
}
