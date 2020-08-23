class ConstEncodeType {
  static const int TYPE_TEXT = 1;
  static const int TYPE_BY_DEFAULT = 2;
  static const int TYPE_BY_DEVICE = 3;
}

class ConstServerType {
  static const int SERVER_TYPE_TEST = 1;
  static const int SERVER_TYPE_HUNONIC = 2;
}

class ConstKeyDb {
  static const String KEY_LIST_TOPIC_JSON = "listTopic";
  static const String KEY_LAST_DEVICE_ID = "lastDeviceId";
  static const String KEY_LAST_TOPIC = "lastTopic";
}

class ConstString {
  static const String APP_NAME = "MQTT DA";
}

class ConstDevice {
  static const int TYPE_LIGHT = 1;
  static const int TYPE_FAN = 2;
  static const int TYPE_DOOR = 3;
  static const int TYPE_RF = 4;
  static const int TYPE_SENSOR_RAIN = 5;
  static const int TYPE_SENSOR_GAS = 6;
  static const int STATE_LIGHT_ON = 1;
  static const int TYPE_DRY = 7; // dan phoi
  static const int STATE_LIGHT_OFF = 2;
  static const int TYPE_DOOR_1 = 8;

  static const String TOPIC = "device/OK";
  static const String TOPIC_PUB = "device";
}

class ConstImage {
  static const String ICON_LIGHT = "assets/images/icon_light.png";
  static const String ICON_FAN = "assets/images/icon_fan.png";
  static const String ICON_DOOR_CLOSE = "assets/images/icon_door_close.png";
  static const String ICON_DOOR_OPEN = "assets/images/icon_door_open.png";
  static const String ICON_RAIN = "assets/images/icon_rain.png";
  static const String ICON_NOT_RAIN = "assets/images/icon_not_rain.png";
  static const String ICON_GAS = "assets/images/icon_gas.png";
  static const String ICON_DRY = "assets/images/icon_dry.png";
  static const String ICON_DOOR_CLOSE_1 = "assets/images/icon_door_close_1.png";
  static const String ICON_DOOR_OPEN_1 = "assets/images/icon_door_open_1.png";
}
