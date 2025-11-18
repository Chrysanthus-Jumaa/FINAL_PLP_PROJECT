import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'app_button.dart';

class ErrorDialog {
  static void show(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.errorRed),
            SizedBox(width: AppTheme.sm),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          AppButton(
            text: 'OK',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class SuccessDialog {
  static void show(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppTheme.successGreen),
            SizedBox(width: AppTheme.sm),
            Text('Success'),
          ],
        ),
        content: Text(message),
        actions: [
          AppButton(
            text: 'OK',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}