//import 'dart:convert';
//import 'dart:typed_data';
//
//import 'package:flutter/material.dart';
//import 'package:mqtttool/Cmd.dart';
//import 'package:mqtttool/aes_helper.dart';
//import 'package:mqtttool/appsetting.dart';
//import 'package:mqtttool/const.dart';
//import 'package:mqtttool/home_viewmodel.dart';
//import 'package:mqtttool/list_topic_page.dart';
//import 'package:mqtttool/mqtt/MQTTViewModel.dart';
//import 'package:mqtttool/mqtt/server.dart';
//import 'package:mqtttool/util/view_util.dart';
//import 'package:provider/provider.dart';
//
//import 'const.dart';
//
//class MyHomePage extends StatefulWidget {
//  @override
//  _MyHomePageState createState() => _MyHomePageState();
//}
//
//class _MyHomePageState extends State<MyHomePage> {
//  static const String TAG = "Home Page";
//
//  MqttViewModel viewModel;
//
//  final _deviceIdController = TextEditingController(text: 'HUNSIM0375535863');
//  final _topicPubController = TextEditingController(text: 'swsim/HUNSIM0375535863/settings/ok');
//  final _cmdController = TextEditingController(text: '{\"swsim\":1, \"result\":1}');
//  final _nameController = TextEditingController(text: 'Config sim success');
//
//  final _formKey = GlobalKey<FormState>();
//  HomeViewModel _homeViewModel = HomeViewModel.instance();
//
//  @override
//  void initState() {
//    super.initState();
//
//    AppSetting.getLastDeviceId().then((deviceId) {
//      _deviceIdController.text = deviceId ?? _deviceIdController.text;
//    });
//    AppSetting.getLastTopic().then((topic) {
//      _topicPubController.text = topic ?? _topicPubController.text;
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    ViewUtil.log(TAG, "build");
//    viewModel = Provider.of<MqttViewModel>(context);
//
//    return ChangeNotifierProvider<HomeViewModel>(
//      create: (_) => _homeViewModel,
//      child: Scaffold(
//        appBar: _buildAppBar(),
//        body: _buildBody(),
//      ),
//    );
//  }
//
//  Widget _buildAppBar() => AppBar(
//        title: ListTile(
//          title: Text(ConstString.APP_NAME, style: TextStyle(color: Colors.white)),
//          subtitle: Selector<MqttViewModel, MqttStatus>(
//            selector: (context, model) => model.mqttStatus,
//            builder: (context, status, child) => Text("$status",
//                style: TextStyle(
//                  color: status == MqttStatus.CONNECTED ? Colors.white : Colors.black,
//                  fontSize: 13,
//                )),
//          ),
//        ),
//        actions: <Widget>[IconButton(icon: Icon(Icons.arrow_drop_down_circle), onPressed: _openListTopicPage)],
//      );
//
//  Widget _buildBody() {
//    return SingleChildScrollView(
//      padding: EdgeInsets.only(left: 16, right: 16),
//      child: Form(
//          key: _formKey,
//          child: Column(
//            crossAxisAlignment: CrossAxisAlignment.stretch,
//            children: <Widget>[
//              _buildMqttServer(),
//              _buildFormContent(),
//              SizedBox(height: 16),
//              Row(
//                children: <Widget>[
//                  _buildExpandBtn("Send", () => _sendMessage(_cmdController.text)),
//                  SizedBox(width: 30),
//                  _buildExpandBtn("Save", _saveCmd),
//                ],
//              ),
//              Selector<HomeViewModel, int>(
//                selector: (context, model) => model.listCmd.length,
//                builder: (context, len, child) {
//                  return ListView.builder(
//                    itemCount: _homeViewModel.listCmd.length,
//                    shrinkWrap: true,
//                    physics: NeverScrollableScrollPhysics(),
//                    itemBuilder: (BuildContext context, int index) {
//                      Cmd cmd = _homeViewModel.listCmd[index];
//                      return ListTile(
//                        title: Text(cmd.name),
//                        subtitle: Text(cmd.content),
//                        onTap: () => _sendCmdMessage(cmd),
//                        trailing: IconButton(
//                          icon: Icon(Icons.delete),
//                          onPressed: () => _deleteCmd(index),
//                        ),
//                      );
//                    },
//                  );
//                },
//              ),
//            ],
//          )),
//    );
//  }
//
//  Widget _buildExpandBtn(String text, Function onPressed) => Expanded(
//        child: FlatButton(
//          child: Text(text),
//          color: Colors.blueAccent,
//          textColor: Colors.white,
//          onPressed: onPressed,
//        ),
//      );
//
//  Widget _buildMqttServer() {
//    Widget server = Selector<HomeViewModel, int>(
//      selector: (context, model) => model.serverType,
//      builder: (context, serverType, child) {
//        return Row(
//          children: <Widget>[
//            _buildExpandRadioServer(ConstServerType.SERVER_TYPE_TEST, serverType, "Test"),
//            _buildExpandRadioServer(ConstServerType.SERVER_TYPE_HUNONIC, serverType, "Hunonic"),
//          ],
//        );
//      },
//    );
//
//    return server;
//  }
//
//  Widget _buildExpandRadioServer(int value, int groupValue, String text) => Expanded(
//        child: ViewUtil.buildRadioTitle(
//          value: value,
//          groupValue: groupValue,
//          onChanged: _onChangeServer,
//          title: Text(text),
//        ),
//      );
//
//  Widget _buildFormContent() {
//    return Column(
//      children: <Widget>[
//        TextFormField(
//          decoration: const InputDecoration(hintText: 'device id', labelText: 'device id'),
//          controller: _deviceIdController,
//          validator: (deviceId) => deviceId.length < 16 ? "Device id must leng >= 16" : null,
//        ),
//        TextFormField(
//          decoration: const InputDecoration(hintText: 'topic', labelText: 'topic'),
//          controller: _topicPubController,
//          validator: (topic) => topic.isEmpty ? "Please enter topic" : null,
//        ),
//        TextFormField(
//          decoration: const InputDecoration(hintText: 'cmd', labelText: 'cmd'),
//          controller: _cmdController,
//        ),
//        TextFormField(
//          decoration: const InputDecoration(hintText: 'name of cmd', labelText: 'name of cmd'),
//          controller: _nameController,
//          validator: (name) => name.isEmpty ? "Please enter name" : null,
//        ),
//        Selector<HomeViewModel, int>(
//          selector: (context, model) => model.typeEncode,
//          builder: (context, type, child) {
//            return Row(
//              children: <Widget>[
//                _buildExpandRadioEncodeType(ConstEncodeType.TYPE_TEXT, type, "Text"),
//                _buildExpandRadioEncodeType(ConstEncodeType.TYPE_BY_DEFAULT, type, "Default"),
//                _buildExpandRadioEncodeType(ConstEncodeType.TYPE_BY_DEVICE, type, "Device"),
//              ],
//            );
//          },
//        ),
//      ],
//    );
//  }
//
//  Widget _buildExpandRadioEncodeType(int value, int groupValue, String text) => Expanded(
//        child: ViewUtil.buildRadioTitle(
//          value: value,
//          groupValue: groupValue,
//          onChanged: _onChangeTypeEncode,
//          title: Text(text),
//        ),
//      );
//
//  void _openListTopicPage() {
//    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ListTopicPage())).then((topic) {
//      _topicPubController.text = topic;
//    });
//  }
//
//  void _onChangeTypeEncode(int val) {
//    _homeViewModel.changeTypeEncode(val);
//  }
//
//  void _onChangeServer(int serverType) {
//    _homeViewModel.changeServer(serverType);
//
//    if (serverType == ConstServerType.SERVER_TYPE_TEST) {
//      viewModel.setServer(ServerTest());
//    } else {
//      viewModel.setServer(ServerHunonic());
//    }
//  }
//
//  void _saveCmd() {
//    _homeViewModel.saveCmd(Cmd(content: _cmdController.text, name: _nameController.text));
//  }
//
//  void _deleteCmd(int index) {
//    // set up the button
//    Widget cancelBtn = FlatButton(child: Text("Cancel"), onPressed: () => Navigator.of(context).pop());
//    Widget okBtn = FlatButton(
//        child: Text("OK"),
//        onPressed: () {
//          Navigator.of(context).pop();
//          _homeViewModel.deleteCmd(index);
//        });
//
//    // set up the AlertDialog
//    AlertDialog alert = AlertDialog(
//      title: Text("Delete"),
//      content: Text("Do you want delete: ${_homeViewModel.listCmd[index].name}?"),
//      actions: [cancelBtn, okBtn],
//    );
//    // show the dialog
//    showDialog(context: context, builder: (context) => alert);
//  }
//
//  void _sendCmdMessage(Cmd cmd) {
//    _cmdController.text = cmd.content;
//    _nameController.text = cmd.name;
//    _sendMessage(cmd.content);
//  }
//
//  void _sendMessage(String message) {
//    if (_formKey.currentState.validate()) {
//      String topic = _topicPubController.text;
//      String deviceId = _deviceIdController.text;
//      Uint8List dataCmd = getDataEncode(deviceId, message);
//      viewModel.publishMessageByeData(topic, dataCmd);
//    }
//
//    _homeViewModel.saveTopicIfNeed(_topicPubController.text);
//    AppSetting.saveLastDeviceId(_deviceIdController.text);
//    AppSetting.saveLastTopic(_topicPubController.text);
//  }
//
//  Uint8List getDataEncode(String deviceId, String text) {
//    switch (_homeViewModel.typeEncode) {
//      case 2:
//        return getDataEncodeByDefault(text);
//      case 3:
//        return getDataEncodeByDevice(deviceId, text);
//    }
//    return getDataEncodeText(text);
//  }
//
//  Uint8List getDataEncodeText(String text) {
//    return Uint8List.fromList(text.codeUnits);
//  }
//
//  Uint8List getDataEncodeByDefault(String text) {
//    String keyText = '0000000000000000';
//    AESHelper aes = AESHelper();
//    return aes.aesEncodeText(text, keyText, keyText);
//  }
//
//  Uint8List getDataEncodeByDevice(String deviceId, String text) {
//    Uint8List data = getDataEncodeByDefault(deviceId);
//
//    Uint8List keyDevice = data.sublist(4, 20);
//    Uint8List ivDevice = data.sublist(12, 28);
//    String keyDeviceBase64 = base64.encode(keyDevice);
//    String ivDeviceBase64 = base64.encode(ivDevice);
//
//    AESHelper aes = AESHelper();
//    Uint8List dataCmd = aes.aesEncodeByte64(text, keyDeviceBase64, ivDeviceBase64);
//
//    return dataCmd;
//  }
//}
