import 'dart:convert';

import 'package:flutter/cupertino.dart';

class DoorCardViewModel with ChangeNotifier {
  static const String TAG = "DoorCardViewModel";

  List<String> cards;

  DoorCardViewModel.instance() {
    cards = List();
  }

  void processMqttMessage(String topic, String message) {
    var data = jsonDecode(message);
    var cmd = data['cmd'];

    // cmd for door
    if (cmd == 4 || cmd == 5 || cmd == 6) {

      // cmd list card
      if (cmd == 4) {
        var cardsJson = data['cards'];
        List<String> stringList = List.from(cardsJson);

        this.cards.clear();
        this.cards.addAll(stringList);
        notifyListeners();
      }
    }
  }


}
