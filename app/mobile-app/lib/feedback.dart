import 'package:app/api.dart';
import 'package:flutter/material.dart';
import 'package:app/utils/analytics.dart';

void openFeedback({
  required BuildContext context,
  required String title,
  required String category,
  required Function afterFeedback,
  required Function onCancel,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController feedbackController = TextEditingController();
      return AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextField(
            controller: feedbackController,
            decoration: InputDecoration(hintText: "Enter your feedback"),
            maxLines: 3,
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              onCancel();
            },
          ),
          TextButton(
            child: Text('Submit'),
            onPressed: () {
              String feedback = feedbackController.text;
              logUserEvent('give_feedback', {'category': category});
              sendFeedback(feedback, category);
              afterFeedback();
            },
          ),
        ],
      );
    },
  );
}
