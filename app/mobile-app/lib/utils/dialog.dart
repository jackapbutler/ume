import 'package:flutter/material.dart';

void createDialog(BuildContext context, String mainText, String hintText) {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Text(mainText),
        content: Text(hintText),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
