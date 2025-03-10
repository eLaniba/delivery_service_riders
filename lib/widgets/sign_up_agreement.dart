import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignUpAgreement extends StatelessWidget {
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  const SignUpAgreement({
    Key? key,
    required this.onTermsTap,
    required this.onPrivacyTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Base text style from your theme (adjust if needed)
    final baseStyle = Theme.of(context).textTheme.bodyMedium;

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(text: 'By signing up you agree to our '),
          TextSpan(
            text: 'Terms and conditions',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              decoration: TextDecoration.underline,
              decorationColor: Theme.of(context).primaryColor
            ),
            recognizer: TapGestureRecognizer()..onTap = onTermsTap,
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy policy',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              decoration: TextDecoration.underline,
              decorationColor: Theme.of(context).primaryColor
            ),
            recognizer: TapGestureRecognizer()..onTap = onPrivacyTap,
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
