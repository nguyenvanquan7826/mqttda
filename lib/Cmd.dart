import 'dart:convert';

class Cmd {
  String content;
  String name;

  Cmd({this.content, this.name});

  Cmd.fromJson(Map<String, dynamic> json) {
    content = json['cmd'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cmd'] = this.content;
    data['name'] = this.name;
    return data;
  }

  static List<Cmd> formJsonList(String json) {
    var list = jsonDecode(json);
    List<Cmd> ls = List<Cmd>.from(list.map((i) => Cmd.fromJson(i)));
    return ls;
  }
}
