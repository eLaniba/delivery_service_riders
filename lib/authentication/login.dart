import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/authentication/auth_screen.dart';
import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/mainScreens/main_screen.dart';
import 'package:delivery_service_riders/widgets/custom_text_field.dart';
import 'package:delivery_service_riders/widgets/custom_text_field_validations.dart';
import 'package:delivery_service_riders/widgets/error_dialog.dart';
import 'package:delivery_service_riders/widgets/loading_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  loginNow() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (c) {
        return const LoadingDialog(message: "Checking credentials");
      },
    );

    User? currentUser;
    await firebaseAuth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ).then((auth) {
      currentUser = auth.user!;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: error.message.toString(),
          );
        },
      );
    });

    if(currentUser != null) {
      readAndSetDataLocally(currentUser!);
    }
  }

  Future readAndSetDataLocally(User currentUser) async {
    await FirebaseFirestore.instance
        .collection("riders")
        .doc(currentUser.uid)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        await sharedPreferences!.setString("uid", currentUser.uid);
        await sharedPreferences!.setString("email", snapshot.data()!["riderEmail"]);
        await sharedPreferences!.setString("name", snapshot.data()!["riderName"]);
        await sharedPreferences!.setString("photoUrl", snapshot.data()!["riderAvatarUrl"]);

        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (c) => const MainScreen()));
      } else {
        firebaseAuth.signOut();
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (c) => const AuthScreen()));

        showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "You have been logged out"
            );
          }
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Welcome,",
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(
              height: 16,
            ),

            //sample
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                child: Column(
                  children: [
                    CustomTextField(
                      labelText: 'Email',
                      controller: emailController,
                      isObscure: false,
                      validator: validateEmail,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CustomTextField(
                      labelText: 'Password',
                      controller: passwordController,
                      isObscure: true,
                      validator: validatePassword,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // showDialog(
                        //   context: context,
                        //   builder: (c) {
                        //     return const ErrorDialog(
                        //       message: "sampleeeee"
                        //     );
                        //   }
                        // );

                        if (_formKey.currentState!.validate()) {
                          //Login
                          loginNow();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.inversePrimary,
                        padding: const EdgeInsets.only(left: 64, right: 64),
                      ),
                      child: const Text("Login"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
