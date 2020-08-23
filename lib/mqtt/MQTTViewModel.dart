import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtttool/mqtt/MQTTListener.dart';
import 'package:mqtttool/mqtt/MQTTMessage.dart';
import 'package:mqtttool/mqtt/server.dart';
import 'package:mqtttool/util/view_util.dart';

enum MQTTStatus { INIT, DISCONNECT, CONNECTING, CONNECTED, CONNECT_FAIL }

class MQTTViewModel with ChangeNotifier {
  static const TAG = "MqttWallpaper";
  String _clientIdentifier = 'fluttermqtt';

  MqttClient _client;
  MQTTStatus _mqttStatus = MQTTStatus.INIT;
  ServerInfo _server;
  bool _serverChanging = false;

  List<Function(String topic, String message)> _mqttMessageCallbackList;

  Function(String topic, String message) _mqttMessageCallback;

  List<MQTTListener> _listeners = List();

  Function _connectCallback;

  MQTTMessage _mqttMessage;

  MQTTMessage get mqttMessage => _mqttMessage;

  MQTTStatus get mqttStatus => _mqttStatus;

  void addMQTTListener(MQTTListener listener) {
    if (_listeners == null) _listeners = List();
    this._listeners.add(listener);
  }

  void addMqttMessageCallBack(Function(String topic, String message) listener) {
    if (_mqttMessageCallbackList == null) _mqttMessageCallbackList = List();
    this._mqttMessageCallbackList.add(listener);
  }

  void removeMqttMessageCallback(Function(String topic, String message) listener){
    this._mqttMessageCallbackList.remove(listener);
  }

//  void setMqttMessageCallBack(Function(String topic, String message) callback) {
//    ViewUtil.log(TAG, "setMqttMessageCallBack");
//    this._mqttMessageCallback = callback;
//  }

  void setConnectCallBack(Function connectCallBack) {
    this._connectCallback = connectCallBack;
  }

  void setServer(ServerInfo server) {
    ViewUtil.log(TAG, "set server ${server.getHost()}");
    _server = server;
    _serverChanging = true;
    _mqttStatus = MQTTStatus.INIT;

    if (_client != null) {
      _client.onDisconnected = null;
      disconnect();
    }

    if (_mqttStatus != MQTTStatus.CONNECTED) {
      ViewUtil.log(TAG, "connect when set server");
      _setupMqttClient();
      connect();
    }
  }

  void _setupMqttClient() {
    String clientId = "${_clientIdentifier}_${DateTime.now().millisecondsSinceEpoch}";
    _client = new MqttClient(_server.getHost(), clientId);
    _client.port = _server.getPort();
    _client.logging(false);
    _client.keepAlivePeriod = 20;
    _client.onDisconnected = onDisconnected;
    _client.onSubscribed = onSubscribed;

    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password, the default keepalive interval(60s)
    /// and clean session, an example of a specific one below.
    final MqttConnectMessage connMess = new MqttConnectMessage()
        .withClientIdentifier(clientId)
        .keepAliveFor(20) // Must agree with the keep alive set above or not set
        .startClean()
        .authenticateAs(_server.getUser(), _server.getPassword()) // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);

    ViewUtil.log(TAG, "Mosquitto client connecting....");
    _client.connectionMessage = connMess;
  }

  void connect() async {
    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however eill
    /// never send malformed messages.

    if (_mqttStatus == MQTTStatus.CONNECTED) {
      _mqttStatus = MQTTStatus.CONNECTED;
      ViewUtil.log(TAG, "connected, not need connect again");
      return;
    }

    try {
      await _client.connect();
    } catch (e) {
      print("EXAMPLE::client exception - $e");
      disconnect();
    }

    /// Check we are connected
    if (_client.connectionState == mqtt.ConnectionState.connected) {
      onConnected();
    } else {
      onConnectFail();
      disconnect();
    }
  }

  void onConnected() {
    ViewUtil.log(TAG, "Mosquitto client connected");
    _mqttStatus = MQTTStatus.CONNECTED;
    _connectCallback();
    notifyListeners();
  }

  void onConnectFail() {
    ViewUtil.log(TAG, "ERROR Mosquitto client connection failed - disconnecting, state is ${_client.connectionState}");
    _mqttStatus = MQTTStatus.CONNECT_FAIL;
    _connectCallback();
    notifyListeners();
  }

  void subscribeToTopic(String topicName) {
    ViewUtil.log(TAG, "Subscribing to the $topicName topic");
    _client.subscribe(topicName, MqttQos.atMostOnce);

    _client.updates.listen((List<MqttReceivedMessage> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      String topic = c[0].topic;
      final String message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      /// The above may seem a little convoluted for users only interested in the
      /// payload, some users however may be interested in the received publish message,
      /// lets not constrain ourselves yet until the package has been in the wild
      /// for a while.
      /// The payload is a byte buffer, this will be specific to the topic
      //ViewUtil.log(TAG, "Message: $topic / $message");
      //ViewUtil.log(TAG, "Message base64 ${base64Encode(recMess.payload.message)}");

      //if (_mqttMessageCallback != null) _mqttMessageCallback(topic, message);
      for (int i = 0; i < _mqttMessageCallbackList.length; i++) {
        ViewUtil.log(TAG, "message $i");
        if(_mqttMessageCallbackList[i]!=null){
          _mqttMessageCallbackList[i](topic, message);
        }
      }
//      ViewUtil.log(TAG, "Message from $topic - $message");
//      _mqttMessage = MQTTMessage(topic: topic, message: message);
//      notifyListeners();
      return;
    });
  }

  void onSubscribed(String topic) {
    ViewUtil.log(TAG, "Subscription confirmed for topic $topic");
  }

  void disconnect() {
    ViewUtil.log(TAG, "Disconnecting");
    _client.disconnect();
  }

  void onDisconnected() {
    ViewUtil.log(TAG, "onDisconnected");
    _mqttStatus = MQTTStatus.DISCONNECT;
    _connectCallback();
    notifyListeners();
  }

  void publishMessage(String topic, String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    ViewUtil.log(TAG, "publishMessage $message to topic $topic");
    _client.publishMessage(topic, MqttQos.atMostOnce, builder.payload);
  }

  void publishMessageByeData(String topic, Uint8List byteData) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.payload.addAll(byteData);

    ViewUtil.log(TAG, "publishMessageByeData ${base64.encode(byteData)} to topic $topic");
    _client.publishMessage(topic, MqttQos.atMostOnce, builder.payload);
  }
}
