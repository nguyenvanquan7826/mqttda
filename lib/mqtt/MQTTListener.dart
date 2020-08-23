import 'dart:typed_data';

class MQTTListener {
  String tag;
  Function(String topic, Uint8List data) callback;
}
