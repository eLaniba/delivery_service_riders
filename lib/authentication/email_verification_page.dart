
import 'package:delivery_service_riders/authentication/stepper/sign_up_stepper.dart';
import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/widgets/confirmation_dialog.dart';
import 'package:delivery_service_riders/widgets/custom_text_field.dart';
import 'package:delivery_service_riders/widgets/custom_text_field_validations.dart';
import 'package:delivery_service_riders/widgets/error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({Key? key}) : super(key: key);

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isSendingVerification = false;
  bool _emailSent = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Try to create a provisional account and send a verification email.
  Future<void> _sendVerificationEmail() async {

    setState(() {
      _isSendingVerification = true;
    });

    final String email = _emailController.text.trim();
    const String provisionalPassword = "tempPassword123"; // For example only

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: provisionalPassword,
      );
      User? provisionalUser = userCredential.user;
      if (provisionalUser != null) {
        await provisionalUser.sendEmailVerification();
        setState(() {
          _emailSent = true;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // The email already exists.
        try {
          // Sign in to get user ID
          UserCredential existingUserCredential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: provisionalPassword, // Use the provisional password
          );
          User? existingUser = existingUserCredential.user;

          if (existingUser != null && existingUser.emailVerified) {
            String userId = existingUser.uid;

            // Check Firestore if the user document exists
            final userDoc = await firebaseFirestore.collection('users').doc(userId).get();

            if (!userDoc.exists) {
              // If the user doesn't exist in Firestore, delete from Auth
              // await existingUser.delete();
              // print("Provisional account deleted because it wasn't found in Firestore.");

              //Navigate to the Fill up form
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  // builder: (context) => Register(user: user!,email: _emailController.text.trim(),),
                  builder: (context) => SignUpStepper(user: existingUser, email: email,),
                ),
              );

            } else {
              print("User exists in Firestore, account not deleted.");
              _showExistingEmailDialog(email);
            }
          } else {
            await existingUser!.sendEmailVerification();
            setState(() {
              _emailSent = true;
            });
          }
        } catch (signInError) {
          print("Error signing in to retrieve existing user: $signInError");
          if(signInError.toString().contains('firebase_auth/invalid-credential')) {
            print('YESSS DADDYYY!');
            _showExistingEmailDialog(email);
          }
        }
      } else {
        // Handle other errors.
        showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(message: e.message ?? "An error occurred");
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (c) {
          return const ErrorDialog(message: "An unexpected error occurred.");
        },
      );
    } finally {
      setState(() {
        _isSendingVerification = false;
      });
    }
  }

  /// Show a dialog offering the user to reset their password if the email is already in use.
  void _showExistingEmailDialog(String email) {
    // Capture the parent context (which is still active) before showing the dialog.
    final BuildContext parentContext = context;
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: const Text("Email Already Exists"),
        content: const Text(
          "This email is already in use.",
        ),
        actions: [
          //Cancel
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Okay"),
          ),
          //Yes
          // TextButton(
          //   onPressed: () async {
          //     // Dismiss the dialog using the dialog's context.
          //     Navigator.pop(dialogContext);
          //     try {
          //       await _auth.sendPasswordResetEmail(email: email);
          //       // Schedule the navigation and SnackBar using the captured parent context.
          //       Future.delayed(Duration.zero, () {
          //         ScaffoldMessenger.of(parentContext).showSnackBar(
          //           SnackBar(
          //             content: Text("We've sent your password reset email to $email"),
          //             backgroundColor: Theme.of(context).primaryColor,
          //           ),
          //         );
          //         Navigator.pushReplacement(
          //           parentContext,
          //           MaterialPageRoute(
          //             builder: (_) => ExistingAccountLoginPage(email: email),
          //           ),
          //         );
          //       });
          //     } catch (error) {
          //       Future.delayed(Duration.zero, () {
          //         ScaffoldMessenger.of(parentContext).showSnackBar(
          //           SnackBar(
          //             content: Text("Error sending reset email: $error"),
          //             backgroundColor: Theme.of(context).primaryColor,
          //           ),
          //         );
          //       });
          //     }
          //   },
          //   child: const Text("Yes"),
          // ),
        ],
      ),
    );
  }

  /// Once the email is verified, proceed to the full registration page.
  Future<void> _checkEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      await user?.reload();
      user = _auth.currentUser;
      if (user != null && user.emailVerified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            // builder: (context) => Register(user: user!,email: _emailController.text.trim(),),
            builder: (context) => SignUpStepper(user: user!, email: _emailController.text.trim(),),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Email not verified yet. Please check your inbox."),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Error checking verification status."),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Widget _buildEmailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/verify_email.png',
          height: 200,
          width: 200,
        ),
        const Text(
          "Enter your email to \nreceive a verification link",
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            children: [
              //Email Text Field
              CustomTextField(
                labelText: 'example@gmail.com',
                controller: _emailController,
                isObscure: false,
                validator: validateEmail,
              ),
              const SizedBox(height: 16),
              //Send Verification Email Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _isSendingVerification ? null : _sendVerificationEmail();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: _isSendingVerification
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.inversePrimary,
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

  Widget _buildVerificationStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/verify_email_sent.png',
          height: 200,
          width: 200,
        ),
        const Text(
          "A verification email sent",
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
        const Text(
          "Verify your email using the link in your inbox.",
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _checkEmailVerification,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.inversePrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: const Text("I've Verified My Email"),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show a warning dialog when the user tries to leave.
        bool? shouldLeave = await ConfirmationDialog.show(
          context,
          'Confirmation',
          'Are you sure you want to leave this page? Your progress may be lost.',
        );
        // If the user didn't confirm, don't allow the page to pop.
        return shouldLeave ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Verify Your Email"),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: _emailSent ? _buildVerificationStatus() : _buildEmailInput(),
          ),
        ),
      ),
    );
  }

}
