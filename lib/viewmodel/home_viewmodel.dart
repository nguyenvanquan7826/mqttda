import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mqtttool/const.dart';
import 'package:mqtttool/model/Device.dart';
import 'package:mqtttool/model/Room.dart';
import 'package:mqtttool/util/view_util.dart';

class HomeViewModel with ChangeNotifier {
  static const String TAG = "HomeViewModel";

  static const String KEY_CMD_JSON = "cmdJson";
  static const String KEY_LAST_TYPE_ENCODE = "lastEncode";
  static const int DEVICE_DOOR_ID = 14;

  int _serverType;
  List<Room> rooms = List();

  int get serverType => _serverType;

  HomeViewModel.instance() {
    _serverType = ConstServerType.SERVER_TYPE_TEST;

    initListRoom();
  }

  void initListRoom() {
    rooms = List();

    int roomId = 1;
    int deviceId = 1;
    Room gara = Room(id: roomId++, name: "Gara", devices: List<Device>());
    gara.devices.add(Device(id: deviceId++, name: "Cửa cuốn", type: ConstDevice.TYPE_DOOR));
    gara.devices.add(Device(id: deviceId++, name: "Đèn", type: ConstDevice.TYPE_LIGHT));
    rooms.add(gara);

    // skip for card device
    deviceId++;

    Room kitchen = Room(id: roomId++, name: "Phòng bếp", devices: List<Device>());
    kitchen.devices.add(Device(id: deviceId++, name: "Đèn", type: ConstDevice.TYPE_LIGHT));
    kitchen.devices.add(Device(id: deviceId++, name: "Quạt", type: ConstDevice.TYPE_FAN));
    kitchen.devices.add(Device(id: deviceId++, name: "Cảm biến ga", type: ConstDevice.TYPE_SENSOR_GAS));
    rooms.add(kitchen);

    Room bedRoom = Room(id: roomId++, name: "Phòng ngủ", devices: List<Device>());
    bedRoom.devices.add(Device(id: deviceId++, name: "Đèn", type: ConstDevice.TYPE_LIGHT));
    bedRoom.devices.add(Device(id: deviceId++, name: "Quạt", type: ConstDevice.TYPE_FAN));
    rooms.add(bedRoom);

    Room livingRoom = Room(id: roomId++, name: "Phòng khách", devices: List<Device>());
    livingRoom.devices.add(Device(id: deviceId++, name: "Đèn", type: ConstDevice.TYPE_LIGHT));
    livingRoom.devices.add(Device(id: deviceId++, name: "Quạt", type: ConstDevice.TYPE_FAN));
    rooms.add(livingRoom);

    Room dry = Room(id: roomId++, name: "Phơi quần áo", devices: List<Device>());
    dry.devices.add(Device(id: deviceId++, name: "Dàn phơi", type: ConstDevice.TYPE_DRY));
    dry.devices.add(Device(id: deviceId++, name: "Cảm biến mưa", type: ConstDevice.TYPE_SENSOR_RAIN));
    rooms.add(dry);

    Room wc = Room(id: roomId++, name: "WC", devices: List<Device>());
    wc.devices.add(Device(id: deviceId++, name: "Đèn", type: ConstDevice.TYPE_LIGHT));
    rooms.add(wc);

    Room cong = Room(id: roomId++, name: "Cổng", devices: List<Device>());
    cong.devices.add(Device(id: DEVICE_DOOR_ID, name: "Cổng tự động", type: ConstDevice.TYPE_DOOR_1));
    rooms.add(cong);
  }

  void changeServer(int serverType) {
    _serverType = serverType;
    notifyListeners();
  }

  void processMqttMessage(String topic, String message) {
    try {
      var data = jsonDecode(message);
      int state = data['stt'];
      int deviceId = data['ID'];
      for (Room room in this.rooms) {
        for (Device device in room.devices) {
          if (device.id == deviceId) {
            processMessageFormDevice(device, state);
            break;
          }
        }
      }
    } catch (error) {
      ViewUtil.log(TAG, 'error json');
    }
  }

  void processMessageFormDevice(Device device, int state) {
    device.state = state;
    notifyListeners();
  }

  int getStateChangeDevice(Device device) {
    int state = device.state == ConstDevice.STATE_LIGHT_ON ? ConstDevice.STATE_LIGHT_OFF : ConstDevice.STATE_LIGHT_ON;
    return state;
  }
}
