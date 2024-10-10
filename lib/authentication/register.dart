import 'dart:io';

import 'package:delivery_service_riders/widgets/custom_text_field_validations.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/custom_text_field.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();
  String imageValidation = "";

  Position? position;
  List<Placemark>? placeMarks;

  String sellerImageUrl = "";
  String completeAddress = "";

  Future<void> _getImage() async
  {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

getCurrentLocation() async {
    try {
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Position newPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      position = newPosition;
      placeMarks = await placemarkFromCoordinates(
        position!.latitude,
        position!.longitude,
      );

      Placemark pMark = placeMarks![0];

      completeAddress = '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';

      locationController.text = completeAddress;
    } catch (e) {
      rethrow;
    }
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
              "Create an account,",
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(
              height: 16,
            ),

            InkWell(
              onTap: _getImage,
              splashColor: Colors.white,
              highlightColor: Colors.white,
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.15,
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage: imageXFile==null ? null : FileImage(File(imageXFile!.path)),
                child: imageXFile == null ? Icon(
                  Icons.add_photo_alternate, size: MediaQuery
                    .of(context)
                    .size
                    .width * 0.15,
                  color: Colors.white,
                ) : null,
              ),
            ),
            Text(
              imageValidation,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            //sample
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 40.0, bottom: 16.0),
                child: Column(
                  children: [
                    CustomTextField(
                      labelText: 'Name',
                      controller: nameController,
                      isObscure: false,
                      validator: validateName,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
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
                      height: 16,
                    ),
                    CustomTextField(
                      labelText: 'Confirm password',
                      controller: confirmPasswordController,
                      isObscure: true,
                      validator: (value) {
                        if (value == null || value.isEmpty || value.trim() != passwordController.text.trim()) {
                          return 'Password did not match';
                        }
                        return null;
                      }
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CustomTextField(
                      labelText: 'Phone',
                      controller: phoneController,
                      isObscure: false,
                      validator: validatePhone,
                    ),
                    const SizedBox(
                      height: 16,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            labelText: 'Your location',
                            controller: locationController,
                            isObscure: false,
                            enabled: false,
                            validator: validateLocation,
                          ),
                        ),

                        IconButton(
                          onPressed: getCurrentLocation,
                          icon: const Icon(Icons.location_on),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 16,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (imageXFile == null) {
                            imageValidation = "Please pick an image";
                          } else {
                            imageValidation = "";
                          }

                          if (_formKey.currentState!.validate()) {
                            print('shhhheeeeeeeeeeeeeeeeeeeeeeeshhhhhhhhhhhhhhhhhhhhhhhhhhhhhh');
                          }

                        });


                      },
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
