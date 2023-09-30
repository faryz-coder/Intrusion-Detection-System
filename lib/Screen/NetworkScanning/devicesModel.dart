class Devices {
  final List<Device> devices;

  const Devices({
    required this.devices,
  });

  factory Devices.fromJson(Map<String, dynamic> json) {
    final deviceList = json['devices'] as List<dynamic>;
    final devices = deviceList.map((deviceJson) {
      return Device.fromJson(deviceJson as Map<String, dynamic>);
    }).toList();
    return Devices(
      devices: devices,
    );
  }
}

class Device {
  final String ip;
  final String mac;
  final String name;
  final int allowed;

  const Device({
    required this.ip,
    required this.mac,
    required this.name,
    required this.allowed,

  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      ip: json['ip'] as String,
      mac: json['mac'] as String,
      name: json['name'] as String,
      allowed: json['allowed'] as int,
    );
  }
}