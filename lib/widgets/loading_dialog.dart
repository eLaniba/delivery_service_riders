import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({
    super.key,
    this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      key: key,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top:16),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).colorScheme.primary
              ),
            ),
          ),
          const SizedBox(height: 8,),
          Text(
            "$message\, please wait...",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
