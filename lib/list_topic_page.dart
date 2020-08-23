import 'package:flutter/material.dart';
import 'package:mqtttool/appsetting.dart';
import 'package:mqtttool/util/view_util.dart';

class ListTopicPage extends StatefulWidget {
  @override
  _ListTopicPageState createState() => _ListTopicPageState();
}

class _ListTopicPageState extends State<ListTopicPage> {
  static const String TAG = "ListTopicPage";

  List<String> _listTopic = List();

  @override
  void initState() {
    super.initState();

    AppSetting.getListTopic().then((list) {
      _listTopic.clear();
      _listTopic.addAll(list);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil.log(TAG, "build");
    return Scaffold(
      appBar: AppBar(title: Text("List topic")),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      child: ListView.builder(
        itemCount: _listTopic.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          String topic = _listTopic[index];
          return ListTile(
            title: Text("$topic"),
            onTap: () => _selectTopic(topic),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _showDialogDeleteConfirm(topic),
            ),
          );
        },
      ),
    );
  }

  void _selectTopic(String topic) {
    Navigator.of(context).pop(topic);
  }

  void _showDialogDeleteConfirm(String topic) {
    // set up the button
    Widget cancelBtn = FlatButton(child: Text("Cancel"), onPressed: () => Navigator.of(context).pop());
    Widget okBtn = FlatButton(
        child: Text("OK"),
        onPressed: () {
          _delete(topic);
          Navigator.of(context).pop();
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete"),
      content: Text("Do you want delete: $topic?"),
      actions: [cancelBtn, okBtn],
    );
    // show the dialog
    showDialog(context: context, builder: (context) => alert);
  }

  void _delete(String topic) {
    _listTopic.remove(topic);
    AppSetting.saveListTopic(_listTopic);
    setState(() {});
  }
}
