import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/authentication/auth_screen.dart';
import 'package:delivery_service_riders/authentication/email_verification_page.dart';
import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/mainScreens/main_screen.dart';
import 'package:delivery_service_riders/services/geopoint_json.dart';
import 'package:delivery_service_riders/widgets/custom_text_field.dart';
import 'package:delivery_service_riders/widgets/custom_text_field_validations.dart';
import 'package:delivery_service_riders/widgets/error_dialog.dart';
import 'package:delivery_service_riders/widgets/loading_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  BuildContext? _loadingDialogContext;


  // loginNow() async {
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (c) {
  //       return const LoadingDialog(message: "Checking credentials");
  //     },
  //   );
  //
  //   User? currentUser;
  //   await firebaseAuth.signInWithEmailAndPassword(
  //     email: emailController.text.trim(),
  //     password: passwordController.text.trim(),
  //   ).then((auth) {
  //     currentUser = auth.user!;
  //   }).catchError((error) {
  //     Navigator.pop(context);
  //     showDialog(
  //       context: context,
  //       builder: (c) {
  //         return ErrorDialog(
  //           message: error.message.toString(),
  //         );
  //       },
  //     );
  //   });
  //
  //   if(currentUser != null) {
  //     readAndSetDataLocally(currentUser!);
  //   }
  // }

  Future<void> loginNow() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        _loadingDialogContext = dialogContext;
        return const LoadingDialog(message: "Checking credentials");
      },
    );

    try {
      // Attempt to sign in
      UserCredential authResult = await firebaseAuth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Retrieve the signed-in user
      User? currentUser = authResult.user;

      // If a user is found, read data and check its status
      if (currentUser != null) {
        await readAndSetDataLocally(currentUser);
      }
    } on FirebaseAuthException catch (error) {
      // Dismiss the loading dialog
      if (_loadingDialogContext != null) {
        Navigator.pop(_loadingDialogContext!);
        _loadingDialogContext = null; // Reset it so you don't pop it again accidentally
      }

      // Show Error Dialog
      showDialog(
        context: context,
        builder: (_) => const ErrorDialog(
          message: "An error occurred while signing in.",
        ),
      );
    }
  }

  // Future readAndSetDataLocally(User currentUser) async {
  //   await FirebaseFirestore.instance
  //       .collection("riders")
  //       .doc(currentUser.uid)
  //       .get()
  //       .then((snapshot) async {
  //     if (snapshot.exists) {
  //       // Retrieve the GeoPoint
  //       GeoPoint userLocation = snapshot.data()!["riderLocation"];
  //
  //       // Convert GeoPoint to JSON string
  //       String locationString = geoPointToJson(userLocation);
  //
  //       await sharedPreferences!.setString("uid", currentUser.uid);
  //       await sharedPreferences!.setString("email", snapshot.data()!["riderEmail"]);
  //       await sharedPreferences!.setString("name", snapshot.data()!["riderName"]);
  //       await sharedPreferences!.setString("phone", snapshot.data()!["riderPhone"]);
  //       await sharedPreferences!.setString("photoUrl", snapshot.data()!["riderImageURL"]);
  //       await sharedPreferences!.setString("location", locationString);
  //
  //       Navigator.pop(context);
  //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => MainScreen(mainScreenIndex: 0, inProgressScreenIndex: 0,)));
  //     } else {
  //       firebaseAuth.signOut();
  //       await sharedPreferences!.clear();
  //       Navigator.pop(context);
  //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const AuthScreen()));
  //
  //       showDialog(
  //         context: context,
  //         builder: (c) {
  //           return const ErrorDialog(
  //             message: "Login Failed, please try again"
  //           );
  //         }
  //       );
  //     }
  //   });
  // }

  Future<void> readAndSetDataLocally(User currentUser) async {
    DocumentSnapshot storeDoc = await FirebaseFirestore.instance
        .collection("riders")
        .doc(currentUser.uid)
        .get();

    if (!storeDoc.exists) {
      //Close Error Dialog
      Navigator.pop(context);
      await firebaseAuth.signOut();
      showDialog(
        context: context,
        builder: (_) => const ErrorDialog(message: "No account exist"),
      );
      return;
    }

    // Document exists, so check the user's status
    Map<String, dynamic> riderData = storeDoc.data() as Map<String, dynamic>;
    String status = riderData["status"] ?? "unknown";

    if (status == "blocked") {
      //Remove the Loading Dialog
      if (_loadingDialogContext != null) {
        Navigator.pop(_loadingDialogContext!);
        _loadingDialogContext = null; // Reset it so you don't pop it again accidentally
      }

      // If blocked, sign out and show an error
      await firebaseAuth.signOut();
      await sharedPreferences!.clear();
      showDialog(
        context: context,
        builder: (_) => const ErrorDialog(message: "Your account is blocked."),
      );
      return;
    } else if (status == "pending") {
      //Remove the Loading Dialog
      if (_loadingDialogContext != null) {
        Navigator.pop(_loadingDialogContext!);
        _loadingDialogContext = null; // Reset it so you don't pop it again accidentally
      }

      // If pending, sign out and show an error
      await firebaseAuth.signOut();
      await sharedPreferences!.clear();
      showDialog(
        context: context,
        builder: (_) => const ErrorDialog(message: "Your account is pending for approval."),
      );
      return;
    }

    // If status is okay, save relevant data locally
    GeoPoint userLocation = riderData["riderLocation"];
    String locationString = geoPointToJson(userLocation);

    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("email", riderData["riderEmail"].toString());
    await sharedPreferences!.setString("name", riderData["riderName"].toString());
    await sharedPreferences!.setString("profileURL", riderData["riderProfileURL"].toString());
    await sharedPreferences!.setString("location", locationString);

    // Navigate to the main screen
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => MainScreen(mainScreenIndex: 0, inProgressScreenIndex: 0,)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/delivery.png',
                height: 200,
                width: 200,
              ),
              const Text(
                "Welcome to tindaPH for Riders!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 16,
              ),

              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Email Text
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8,),
                      CustomTextField(
                        labelText: 'example@gmail.com',
                        controller: emailController,
                        isObscure: false,
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 8),
                      //Password Text
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8,),
                      //Password Text Field
                      CustomTextField(
                        labelText: 'password',
                        controller: passwordController,
                        isObscure: true,
                        validator: validatePassword,
                      ),
                      //Forgot password? Text
                      TextButton(
                        onPressed: () {
                          // Add your navigation or action here for Sign Up
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => const EmailVerificationPage()),
                          // );
                        },
                        style: TextButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                          foregroundColor: Theme.of(context).primaryColor,
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('Forgot password?'),
                      ),
                      const SizedBox(height: 12),
                      //Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              //Login
                              loginNow();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14,),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12,),
              //Don't have an account? Sign up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EmailVerificationPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      splashFactory: NoSplash.splashFactory,
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Sign Up',),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
