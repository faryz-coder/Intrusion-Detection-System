class Appliances {
  final List<Appliance> appliances;

  const Appliances({
    required this.appliances,
  });

  factory Appliances.fromJson(Map<String, dynamic> json) {
    final deviceList = json['appliances'] as List<dynamic>;
    final appliances = deviceList.map((deviceJson) {
      return Appliance.fromJson(deviceJson as Map<String, dynamic>);
    }).toList();
    return Appliances(
      appliances: appliances,
    );
  }
}

class Appliance {
  final String name;
  final bool status;

  const Appliance({
    required this.name,
    required this.status,

  });

  factory Appliance.fromJson(Map<String, dynamic> json) {
    return Appliance(
      name: json['name'] as String,
      status: json['status'] as int == 1,
    );
  }
}