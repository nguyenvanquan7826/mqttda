import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../const.dart';

class Device {
  int id;
  int type;
  String name;
  String image;
  int state;

  Device({this.id, this.type, this.name, this.image, this.state = 2});

  Device.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    name = json['name'];
    image = json['image'];
    state = json['state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['name'] = this.name;
    data['image'] = this.image;
    data['state'] = this.state;
    return data;
  }

  String getTopicSub() {
    return ConstDevice.TOPIC;
  }

  String getTopicPub() {
    return ConstDevice.TOPIC_PUB;
  }

  String getImage() {
    switch (type) {
      case ConstDevice.TYPE_FAN:
        return ConstImage.ICON_FAN;
      case ConstDevice.TYPE_DOOR:
        return _getDoorIcon();
        case ConstDevice.TYPE_DOOR_1:
        return _getDoorIcon1();
      case ConstDevice.TYPE_SENSOR_RAIN:
        return _getRainIcon();
      case ConstDevice.TYPE_SENSOR_GAS:
        return ConstImage.ICON_GAS;
      case ConstDevice.TYPE_DRY:
        return ConstImage.ICON_DRY;
    }
    return ConstImage.ICON_LIGHT;
  }

  String _getDoorIcon() {
    return state == ConstDevice.STATE_LIGHT_OFF ? ConstImage.ICON_DOOR_CLOSE : ConstImage.ICON_DOOR_OPEN;
  }
  String _getDoorIcon1() {
    return state == ConstDevice.STATE_LIGHT_OFF ? ConstImage.ICON_DOOR_CLOSE_1 : ConstImage.ICON_DOOR_OPEN_1;
  }

  String _getRainIcon() {
    return state == ConstDevice.STATE_LIGHT_ON ? ConstImage.ICON_RAIN : ConstImage.ICON_NOT_RAIN;
  }

  Color getColor() {
    return state == ConstDevice.STATE_LIGHT_ON ? Colors.red : Colors.blueGrey;
  }
}
