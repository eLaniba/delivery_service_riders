import 'dart:io';
import 'package:flutter/material.dart';

class ImageConfirm extends StatelessWidget {
  final File imageFile;
  final VoidCallback onSend;
  final VoidCallback onCancel;

  const ImageConfirm({
    Key? key,
    required this.imageFile,
    required this.onSend,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: const Text('Confirm image'),
      content: SizedBox(
        width: 300,
        height: 300,
        child: Image.file(
          imageFile,
          fit: BoxFit.cover,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: onSend,
          child: const Text('Send'),
        ),
      ],
    );
  }
}
