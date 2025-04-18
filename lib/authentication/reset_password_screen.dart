import 'package:delivery_service_riders/widgets/confirmation_dialog.dart';
import 'package:delivery_service_riders/widgets/custom_text_field.dart';
import 'package:delivery_service_riders/widgets/custom_text_field_validations.dart';
import 'package:delivery_service_riders/widgets/error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isSendingResetLink = false;
  bool _emailSent = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
    setState(() {
      _isSendingResetLink = true;
    });

    try {
      final email = _emailController.text.trim();
      await _auth.sendPasswordResetEmail(email: email);

      // Firebase won't throw if the email is unregistered
      setState(() {
        _emailSent = true;
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Something went wrong.";
      if (e.code == 'invalid-email') {
        errorMessage = "The email address is badly formatted.";
      }
      // You may show a generic error for anything else, but avoid exposing user existence
      await showDialog(
        context: context,
        builder: (ctx) => ErrorDialog(
          message: errorMessage,
        ),
      );
    } catch (e) {
      await showDialog(
        context: context,
        builder: (ctx) => ErrorDialog(
          message: e.toString(),
        ),
      );
    }

    setState(() {
      _isSendingResetLink = false;
    });
  }


  Widget _buildEmailInputForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/verify_email.png', height: 200, width: 200),
        const Text(
          "Enter your email to\nreset your password",
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                labelText: 'example@gmail.com',
                controller: _emailController,
                isObscure: false,
                validator: validateEmail,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _sendPasswordResetEmail();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor:
                    Theme.of(context).colorScheme.inversePrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: _isSendingResetLink
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color:
                      Theme.of(context).colorScheme.inversePrimary,
                      strokeWidth: 3,
                    ),
                  )
                      : const Text("Send"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResetConfirmation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/verify_email_sent.png', height: 200, width: 200),
        const Text(
          "Password Reset Email Sent",
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
        const Text(
          "Check your inbox and follow the instructions.",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // close the page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.inversePrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: const Text("Okay"),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool? shouldLeave = await ConfirmationDialog.show(
          context,
          'Confirmation',
          'Are you sure you want to leave this page?',
        );
        return shouldLeave ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Reset Password"),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: _emailSent
                ? _buildResetConfirmation()
                : _buildEmailInputForm(),
          ),
        ),
      ),
    );
  }
}
