import 'package:delivery_service_riders/widgets/custom_text_field.dart';
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
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CustomTextField(
                      labelText: 'Password',
                      controller: passwordController,
                      isObscure: true,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
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
