import 'package:flutter/material.dart';

enum NotificationType { success, error, warning, info }

void showModernNotification(
  BuildContext context, {
  required String messageFa,
  required String messageEn,
  bool isPersian = false,
  NotificationType type = NotificationType.success,
}) {
  Color bgColor;
  IconData iconData;

  switch (type) {
    case NotificationType.success:
      bgColor = Colors.green.shade700;
      iconData = Icons.check_circle_outline;
      break;
    case NotificationType.error:
      bgColor = Colors.redAccent.shade700;
      iconData = Icons.error_outline;
      break;
    case NotificationType.warning:
      bgColor = Colors.orangeAccent.shade700;
      iconData = Icons.warning_amber_rounded;
      break;
    case NotificationType.info:
    default:
      bgColor = Colors.blueAccent.shade700;
      iconData = Icons.info_outline;
      break;
  }

  final message = isPersian ? messageFa : messageEn;

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: bgColor,
      content: Row(
        children: [
          Icon(iconData, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}