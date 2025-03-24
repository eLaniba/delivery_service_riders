import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/services/image_picker_service.dart';
import 'package:delivery_service_riders/services/util.dart';
import 'package:delivery_service_riders/widgets/confirmation_dialog.dart';
import 'package:delivery_service_riders/widgets/show_floating_toast.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CustomTextField extends StatefulWidget {
  CustomTextField({
    super.key,
    this.controller,
    this.inputType,
    this.enabled,
    this.isObscure,
    this.labelText,
    this.validator,
    this.suffixIcon,
    this.prefixText,
  });

  final String? labelText;
  final TextEditingController? controller;
  TextInputType? inputType = TextInputType.text;
  bool? enabled = true;
  bool? isObscure = true;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final String? prefixText;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      controller: widget.controller,
      keyboardType: widget.inputType,
      obscureText: widget.isObscure!,
      decoration: InputDecoration(
        prefixText: widget.prefixText,
        suffixIcon: widget.suffixIcon,
        // Smaller label and hint for compact design
        labelText: widget.labelText,
        labelStyle: const TextStyle(
          color: Colors.grey, // Lighter label color
          fontSize: 16, // Smaller label font
        ),
        // Borders with soft, rounded corners
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5, // Thinner focused border
          ),
          borderRadius: BorderRadius.circular(24), // Slightly smaller radius for a more compact look
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2), // Subtle border color
            width: 1.5, // Even thinner border for normal state
          ),
          borderRadius: BorderRadius.circular(24), // Slightly smaller radius
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        // Adjusted padding for a more compact field
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12.0), // Reduced padding
        isDense: true, // Reduce height of the text field
        floatingLabelBehavior: FloatingLabelBehavior.never, // Modern floating label behavior
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), // Faded hint text
          fontSize: 12, // Smaller hint text
        ),
      ),
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
