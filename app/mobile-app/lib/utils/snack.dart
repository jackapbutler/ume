import 'package:flutter/material.dart';

class CustomSnackBar extends SnackBar {
  @override
  // ignore: overridden_fields
  final Text content;
  final bool isError;

  CustomSnackBar({context, required this.content, this.isError = false})
      : super(
          content: content,
          backgroundColor: isError
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary, // hardcoded colors
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          behavior: SnackBarBehavior.floating, // Floating effect
          margin: const EdgeInsets.all(16), // Padding around the snack bar
          duration: const Duration(seconds: 3), // Visible duration
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 8), // Inner padding
        );
}
