import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mqtttool/const.dart';
import 'package:mqtttool/mqtt/MQTTMessage.dart';
import 'package:mqtttool/mqtt/MQTTViewModel.dart';
import 'package:mqtttool/util/view_util.dart';
import 'package:mqtttool/viewmodel/CmdCreator.dart';
import 'package:mqtttool/viewmodel/door_card_viewmodel.dart';
import 'package:provider/provider.dart';

class DoorCardPage extends StatefulWidget {
  @override
  _DoorCardPageState createState() => _DoorCardPageState();
}

class _DoorCardPageState extends State<DoorCardPage> {
  static const String TAG = "DoorCardPage";

  MQTTViewModel _mqttViewModel;
  DoorCardViewModel _doorCardViewModel = DoorCardViewModel.instance();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _mqttViewModel = Provider.of<MQTTViewModel>(context);
    _mqttViewModel.addMqttMessageCallBack(onMqttMessage);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _mqttViewModel.removeMqttMessageCallback(onMqttMessage);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil.log(TAG, "build page");

    _getListCard();

    return ChangeNotifierProvider<DoorCardViewModel>(
      create: (_) => _doorCardViewModel,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: ListView(
          children: <Widget>[
            Selector<MQTTViewModel, MQTTMessage>(
                selector: (context, model) => model.mqttMessage,
                builder: (context, message, child) {
                  if (message != null) onMqttMessage(message.topic, message.message);
                  return Container();
                }),
            _buildBody()
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() => AppBar(
        title: ListTile(
          title: Text(ConstString.APP_NAME, style: TextStyle(color: Colors.white)),
          subtitle: Selector<MQTTViewModel, MQTTStatus>(
              selector: (context, model) => model.mqttStatus,
              builder: (context, status, child) {
                return Text("$status",
                    style: TextStyle(
                      color: status == MQTTStatus.CONNECTED ? Colors.white : Colors.black,
                      fontSize: 13,
                    ));
              }),
        ),
        actions: <Widget>[IconButton(icon: Icon(Icons.add), onPressed: _addCard)],
      );

  Widget _buildBody() {
    ViewUtil.log(TAG, "build body");
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildCardList(),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCardList() {
    return Selector<DoorCardViewModel, int>(
      selector: (context, model) => model.cards.length,
      builder: (context, len, child) {
        return ListView.builder(
          itemCount: len,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return _buildCardItem(index);
          },
        );
      },
    );
  }

  Widget _buildCardItem(int index) {
    String card = _doorCardViewModel.cards[index];
    return ListTile(
      title: Text("$card"),
      leading: Icon(Icons.credit_card),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () => _deleteCard(card),
      ),
    );
  }

  /// Action

  void onMqttMessage(String topic, String message) {
    ViewUtil.log(TAG, message);
    _doorCardViewModel.processMqttMessage(topic, message);
  }

  void _getListCard() {
    _mqttViewModel.publishMessage(ConstDevice.TOPIC, CmdCreator.getCmdGetListCard());
  }

  void _deleteCard(String card) {
    _mqttViewModel.publishMessage(ConstDevice.TOPIC, CmdCreator.getCmdDeleteCard(card));

    Timer(Duration(seconds: 1), () {
      _getListCard();
    });
  }

  void _addCard() {
    _mqttViewModel.publishMessage(ConstDevice.TOPIC, CmdCreator.getCmdAddCard());
  }
}
