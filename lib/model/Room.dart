import 'package:mqtttool/model/Device.dart';

class Room {
  int id;
  String name;
  List<Device> devices;

  Room({this.id, this.name, this.devices});

  Room.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['device'] != null) {
      devices = new List<Device>();
      json['device'].forEach((v) {
        devices.add(new Device.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    if (this.devices != null) {
      data['device'] = this.devices.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
