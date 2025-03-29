import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/global/permission_service.dart';
import 'package:delivery_service_riders/mainScreens/main_screen_provider.dart';
import 'package:delivery_service_riders/services/geopoint_json.dart';
import 'package:delivery_service_riders/services/image_picker_service.dart';
import 'package:delivery_service_riders/widgets/custom_text_field_validations.dart';
import 'package:delivery_service_riders/widgets/error_dialog.dart';
import 'package:delivery_service_riders/widgets/loading_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global/global.dart';
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

  String riderImageURL = "";
  String completeAddress = "";
  GeoPoint? geoPoint;

  Future<void> _getImage(ImageSource source) async
  {
    imageXFile = await ImagePickerService().pickCropImage(
      cropAspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 5),
      imageSrouce: source,
    );
    setState(() {
      imageXFile;
      if (imageXFile != null) {
        imageValidation = "";
      }
    });
  }

  getCurrentLocation() async {
    PermissionService permissionService = PermissionService();

    await permissionService.requestLocationPermission();
    if (await Permission.location.isGranted) {
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

        geoPoint = GeoPoint(position!.latitude, position!.longitude);

        Placemark pMark = placeMarks![1];

        completeAddress = '${pMark.street}, ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.country}';

        locationController.text = completeAddress;
      } catch (e) {
        rethrow;
      }
    } else {
      print('Location permission is not granted');
    }
}

  registerNow() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (c) {
        return const LoadingDialog(message: "Checking credentials");
      },
    );

    //Authenticate Riders and Save Data to Firestore if != null
    authenticateRider();

  }

  void authenticateRider() async {
    User? currentUser;

    await firebaseAuth.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ).then((auth) {
      currentUser = auth.user;
    }).catchError((error){
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c)
          {
            return ErrorDialog(
              message: error.message.toString(),
            );
          }
      );
    });

    if(currentUser != null)
    {
      await uploadImage(currentUser);

      saveDataToFirestore(currentUser!).then((value) {
        Navigator.pop(context);
        //send user to homePage
        Route newRoute = MaterialPageRoute(builder: (c) => MainScreenProvider(mainScreenIndex: 0, inProgressScreenIndex: 2));
        Navigator.pushReplacement(context, newRoute);
      });
    }
  }

  Future<void> uploadImage(User? currentUser) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      FirebaseStorage fStorage = FirebaseStorage.instance;

      Reference reference = fStorage.ref().child("riders").child(currentUser!.uid.toString()).child(fileName);

      UploadTask uploadTask = reference.putFile(File(imageXFile!.path));

      TaskSnapshot taskSnapshot = await uploadTask;

      riderImageURL = await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c)
          {
            return ErrorDialog(
              message: e.toString(),
            );
          }
      );
    }
  }

  Future saveDataToFirestore(User currentUser) async {
    FirebaseFirestore.instance.collection("riders").doc(currentUser.uid).set({
      "riderID": currentUser.uid,
      "riderEmail": currentUser.email,
      "riderName": nameController.text.trim(),
      "riderImageURL": riderImageURL,
      "riderPhone": phoneController.text.trim(),
      "riderAddress": locationController.text.trim(),
      "riderStatus": "approved",
      "riderLocation": geoPoint,
    });

    //Save data locally
    String locationString = geoPointToJson(geoPoint!);
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("name", nameController.text.trim());
    await sharedPreferences!.setString("phone", phoneController.text.trim());
    await sharedPreferences!.setString("photoUrl", riderImageURL);
    await sharedPreferences!.setString("location", locationString);
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
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    // return Container(
                    //   height: 130,
                    //   padding: EdgeInsets.all(16),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       InkWell(
                    //         onTap: () {
                    //           Navigator.pop(context);
                    //           _getImage(ImageSource.camera);
                    //         },
                    //         child: Row(
                    //
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             Icon(Icons.camera_alt_outlined),
                    //             SizedBox(width: 8,),
                    //             Text(
                    //               "Use camera",
                    //               style: TextStyle(
                    //                 fontSize: 18,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //       SizedBox(height: 16,),
                    //       InkWell(
                    //         onTap: () {
                    //           Navigator.pop(context);
                    //           _getImage(ImageSource.gallery);
                    //         },
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             Icon(Icons.image_outlined),
                    //             Text(
                    //               "Choose from gallery",
                    //               style: TextStyle(
                    //                 fontSize: 18,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // );
                    return Container(
                      height: 150,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Upload',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16,),
                          Row(
                            children: [
                              //Use Camera
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  _getImage(ImageSource.camera);
                                },
                                child: const Column(
                                  children: [
                                    CircleAvatar(
                                      child: Icon(Icons.camera_alt_outlined),
                                    ),
                                    Text('Camera'),
                                  ],
                                ),
                              ),
                              SizedBox(width: 24,),
                              //Use Gallery
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  _getImage(ImageSource.gallery);
                                },
                                child: const Column(
                                  children: [
                                    CircleAvatar(
                                      child: Icon(Icons.image_outlined),
                                    ),
                                    Text('Gallery'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
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
                            enabled: true,
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

                            if (_formKey.currentState!.validate()) {
                              //Register
                              registerNow();
                            }
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                        padding: const EdgeInsets.only(left: 64, right: 64),
                      ),
                      child: const Text("Register"),
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
