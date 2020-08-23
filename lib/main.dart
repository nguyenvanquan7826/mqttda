import 'package:flutter/material.dart';
import 'package:mqtttool/mqtt/MQTTViewModel.dart';
import 'package:mqtttool/page/home_page.dart';
import 'package:mqtttool/util/view_util.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ViewUtil.log("MyApp", "build");
    return ChangeNotifierProvider<MQTTViewModel>(
      create: (_) => MQTTViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MyHomePage(),
      ),
    );
  }
}
