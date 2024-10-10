import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField({
    super.key,
    this.controller,
    this.enabled,
    this.isObscure,
    this.labelText,
    this.validator,
  });

  final String? labelText;
  final TextEditingController? controller;
  bool? enabled = true;
  bool? isObscure = true;
  final String? Function(String?)? validator;

  //Validation for email

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      obscureText: isObscure!,
      decoration: InputDecoration(
          labelText: labelText,
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary,)
          ),
          enabledBorder: const UnderlineInputBorder(),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error,)
          ),
      ),
      validator: validator,
    );
  }
}
