import 'package:flutter/material.dart';
import 'package:mqtttool/const.dart';
import 'package:mqtttool/model/Device.dart';
import 'package:mqtttool/model/Room.dart';
import 'package:mqtttool/mqtt/MQTTViewModel.dart';
import 'package:mqtttool/mqtt/server.dart';
import 'package:mqtttool/page/door_card_page.dart';
import 'package:mqtttool/util/view_util.dart';
import 'package:mqtttool/viewmodel/CmdCreator.dart';
import 'package:mqtttool/viewmodel/home_viewmodel.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String TAG = "HomePage";

  MQTTViewModel _mqttViewModel;
  HomeViewModel _homeViewModel = HomeViewModel.instance();

  @override
  void initState() {
    ViewUtil.log(TAG, "initState");
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _mqttViewModel = Provider.of<MQTTViewModel>(context, listen: false);
    _mqttViewModel.setConnectCallBack(() {
      if (_mqttViewModel.mqttStatus == MQTTStatus.CONNECTED) {
        _mqttViewModel.subscribeToTopic(ConstDevice.TOPIC_PUB);
        _getStateAllDevice();
      }
    });
    _mqttViewModel.addMqttMessageCallBack((topic, message) => onMqttMessage(topic, message));

    if (_mqttViewModel.mqttStatus != MQTTStatus.CONNECTED) {
      _onChangeServer();
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil.log(TAG, "build page");

    return ChangeNotifierProvider<HomeViewModel>(
      create: (_) => _homeViewModel,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: ListView(
          children: <Widget>[
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
        actions: <Widget>[IconButton(icon: Icon(Icons.sync), onPressed: _onChangeServer)],
      );

  Widget _buildBody() {
    ViewUtil.log(TAG, "build body");
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildRoomList(),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRoomList() {
    return ListView.builder(
      itemCount: _homeViewModel.rooms.length,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return _buildRoomItem(index);
      },
    );
  }

  Widget _buildRoomItem(int roomIndex) {
    Room room = _homeViewModel.rooms[roomIndex];
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(width: double.infinity, child: Text("${room.name}")),
          _buildDeviceListInRoom(roomIndex),
        ],
      ),
    );
  }

  Widget _buildDeviceListInRoom(int roomIndex) {
    Room room = _homeViewModel.rooms[roomIndex];
    return GridView.builder(
      itemCount: room.devices.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        //Device device = room.devices[index];
        return _buildDeviceItem(roomIndex, index);
      },
    );
  }

  Widget _buildDeviceItem(int roomIndex, int deviceIndex) {
    Device device = _homeViewModel.rooms[roomIndex].devices[deviceIndex];
    return Card(
      child: InkWell(
        onTap: () => _clickDevice(device),
        onLongPress: () => _onLongPress(device),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Selector<HomeViewModel, int>(
            selector: (context, model) => model.rooms[roomIndex].devices[deviceIndex].state,
            builder: (context, state, child) {
              print("build item device in selector ${device.id}");
              return Column(
                children: <Widget>[
                  Expanded(child: Image.asset(device.getImage(), color: device.getColor())),
                  SizedBox(height: 8),
                  Text("${device.name}"),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Action

  void onMqttMessage(String topic, String message) {
    ViewUtil.log(TAG, message);
    _homeViewModel.processMqttMessage(topic, message);
  }

  void _clickDevice(Device device) {
    print("click ${device.id}");
    int state = _homeViewModel.getStateChangeDevice(device);
    String cmd = CmdCreator.getCmdSetState(device.id, state);
    _mqttViewModel.publishMessage(device.getTopicSub(), cmd);

    //_homeViewModel.processMessageFormDevice(device, state);
  }

  void _onLongPress(Device device) {
    if (device.id != HomeViewModel.DEVICE_DOOR_ID) {
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => DoorCardPage()));
  }

  void _onChangeServer({int serverType = ConstServerType.SERVER_TYPE_TEST}) {
    _homeViewModel.changeServer(serverType);

    if (serverType == ConstServerType.SERVER_TYPE_TEST) {
      _mqttViewModel.setServer(ServerTest());
    }
  }

  void _getStateAllDevice() {
    Device device = _homeViewModel.rooms[0].devices[0];
    String topic = device.getTopicSub();
    _mqttViewModel.publishMessage(topic, CmdCreator.getCmdGetAllDeviceState());
  }
}
