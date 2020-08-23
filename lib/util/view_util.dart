import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ViewUtil {
  static const _LOG = true;

  static void log(String TAG, String message) {
    if (_LOG) {
      print("$TAG - $message");
    }
  }

  static Widget buildRadioTitle({Widget title, int value, int groupValue, Function onChanged}) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Row(
        children: <Widget>[
          Radio(value: value, groupValue: groupValue, onChanged: onChanged),
          title,
        ],
      ),
    );
  }
}
