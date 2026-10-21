import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// Reusable confirmation dialog for critical actions like deletion.
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;

  const ConfirmDialog({
    super.key,
    this.title = AppStrings.confirmDeleteTitle,
    required this.message,
    this.confirmLabel = AppStrings.delete,
    this.confirmColor = AppColors.error,
  });

  static Future<bool> show({
    required BuildContext context,
    String title = AppStrings.confirmDeleteTitle,
    required String message,
    String confirmLabel = AppStrings.delete,
    Color confirmColor = AppColors.error,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        confirmColor: confirmColor,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
