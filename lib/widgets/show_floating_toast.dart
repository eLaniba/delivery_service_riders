import 'package:flutter/material.dart';

void showFloatingToast({
  required BuildContext context,
  required String message,
  IconData icon = Icons.info_outline,
  Color backgroundColor = const Color(0xFF323232),
  Color textColor = Colors.white,
  bool showDismissButton = false,
  String dismissLabel = 'Okay',
  Duration duration = const Duration(seconds: 3),
}) {
  // Clear any existing snackbars before showing a new one
  ScaffoldMessenger.of(context).clearSnackBars();

  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
    backgroundColor: backgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    duration: duration,
    content: Row(
      children: [
        Icon(icon, color: textColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: textColor),
          ),
        ),
      ],
    ),
    action: showDismissButton
        ? SnackBarAction(
      label: dismissLabel,
      textColor: textColor,
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    )
        : null,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);

  // Force auto-dismiss even with action
  if (showDismissButton) {
    Future.delayed(duration, () {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    });
  }
}
