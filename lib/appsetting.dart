import 'dart:convert';

import 'package:mqtttool/const.dart';
import 'package:mqtttool/util/db_util.dart';

class AppSetting {
  /// SAVE TOPIC
  static void saveListTopic(List<String> listTopic) {
    DbUtil.saveString(ConstKeyDb.KEY_LIST_TOPIC_JSON, jsonEncode(listTopic));
  }

  static Future<List<String>> getListTopic() async {
    String jsonText = await DbUtil.getString(ConstKeyDb.KEY_LIST_TOPIC_JSON);
    List<String> list = jsonText == null ? List() : (jsonDecode(jsonText) as List<dynamic>).cast<String>();
    return list;
  }

  /// LAST DEVICE ID

  static void saveLastDeviceId(String deviceId) {
    DbUtil.saveString(ConstKeyDb.KEY_LAST_DEVICE_ID, deviceId);
  }

  static Future<String> getLastDeviceId() async {
    return await DbUtil.getString(ConstKeyDb.KEY_LAST_DEVICE_ID);
  }

  /// LAST TOPIC

  static void saveLastTopic(String topic) {
    DbUtil.saveString(ConstKeyDb.KEY_LAST_TOPIC, topic);
  }

  static Future<String> getLastTopic() async {
    return await DbUtil.getString(ConstKeyDb.KEY_LAST_TOPIC);
  }
}
