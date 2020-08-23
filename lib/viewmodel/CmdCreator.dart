class CmdCreator {
  static String getCmdSetState(int deviceId, int state) {
    return "{\"cmd\": 2, \"ID\": $deviceId, \"stt\": $state}";
  }

  static String getCmdGetAllDeviceState() {
    return "{\"cmd\": 1, \"ID\": 0}";
  }

  static String getCmdGetListCard() {
    return "{\"cmd\": 4}";
  }

  static String getCmdDeleteCard(String card) {
    return "{\"cmd\": 5, \"card\":\"$card\"}";
  }

  static String getCmdAddCard() {
    return "{\"cmd\": 6}";
  }
}
