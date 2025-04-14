import 'package:flutter/material.dart';

void showCustomDialog(
    BuildContext context,
    {required String title,
      required String message,
      bool isSuccess = true,
      VoidCallback? onConfirm}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(message, style: const TextStyle(fontSize: 16)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (onConfirm != null) {
                onConfirm(); // Gọi onConfirm nếu không null
              }
              Navigator.pop(context);
            },
            child: const Text("Đóng", style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      );
    },
  );
}