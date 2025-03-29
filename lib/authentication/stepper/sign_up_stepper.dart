
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/authentication/add_address_screen.dart';
import 'package:delivery_service_riders/authentication/register_success_screen.dart';
import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/services/auth_service.dart';
import 'package:delivery_service_riders/services/image_picker_service.dart';
import 'package:delivery_service_riders/services/util.dart';
import 'package:delivery_service_riders/widgets/confirmation_dialog.dart';
import 'package:delivery_service_riders/widgets/custom_text_field.dart';
import 'package:delivery_service_riders/widgets/custom_text_field_validations.dart';
import 'package:delivery_service_riders/widgets/document_upload_card.dart';
import 'package:delivery_service_riders/widgets/error_dialog.dart';
import 'package:delivery_service_riders/widgets/loading_dialog.dart';
import 'package:delivery_service_riders/widgets/sign_up_agreement.dart';
import 'package:delivery_service_riders/widgets/upload_document_option.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SignUpStepper extends StatefulWidget {
  final String? email;
  final User user;

  const SignUpStepper({Key? key, required this.email, required this.user}) : super(key: key);

  @override
  State<SignUpStepper> createState() => _SignUpStepperState();
}

class _SignUpStepperState extends State<SignUpStepper> {

  int _currentStep = 0;

  // Step 1: Three documents
  XFile? _idFile;
  XFile? _driverFile;

  // Step 2: Form fields
  XFile? _imgFile;
  String imgValidate = '';
  //AuthService class (see services/auth_service.dart)
  final AuthService _authService = AuthService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Position? position;
  List<Placemark>? placeMarks;

  String? address;
  GeoPoint? geoPoint;

  // For password visibility
  bool _isPasswordHidden = true;

  // Check if Step 1 is completed: i.e., all three files are non-null
  bool get _isStep1Complete {
    return _idFile != null && _driverFile != null;
  }

  Future signUp(User currentUser) async {
    showDialog(
      barrierDismissible: false,
        context: context,
        builder: (c) {
          return const LoadingDialog(
            message: 'Creating account',
          );
        });

    final String storePhone = formatPhoneNumber(phoneController.text.trim());
    final String storeName  = capitalizeEachWord(nameController.text.trim());

    DocumentReference storeDocument = firebaseFirestore.collection('riders').doc(currentUser.uid);

    try {
      await currentUser.updatePassword(passwordController.text.trim());

      await storeDocument.set({
        "riderID": currentUser.uid,
        "riderEmail": currentUser.email,
        "riderName": storeName,
        "riderPhone": storePhone,
        "status": "registered",
        //Address of the store
        "riderAddress": address,
        "riderLocation": geoPoint,
        // Bool for Approval in Admin
        "emailVerified": true,
        "phoneVerified": true, //Todo: Temporary enable
        "idVerified": true, //Todo: Temporary enable
        "driverVerified": true, //Todo: Temporary enable
      });

      //Uploading the 3 Documents(images) to Firebase Cloud Storage
      //Step 1: Assigning Filenames
      String idFileName = 'id_file';
      String driverFileName = 'driver_file';
      String profileFileName = 'profile_file';

      String idImagePath = 'riders/${currentUser.uid}/documents/$idFileName';
      String driverImagePath = 'riders/${currentUser.uid}/documents/$driverFileName';
      String profileFilePath = 'riders/${currentUser.uid}/images/$profileFileName';

      //Step 2: Upload images to Cloud Storage
      String idURL = await uploadFileAndGetDownloadURL(file: _idFile!, storagePath: idImagePath);
      String driverURL = await uploadFileAndGetDownloadURL(file: _driverFile!, storagePath: driverImagePath);
      String profileURL = await uploadFileAndGetDownloadURL(file: _imgFile!, storagePath: profileFilePath);

      //Step 3: Update Firebase Firestore Document
      await storeDocument.update({
        'idURL': idURL,
        'idPath': idImagePath,
        'driverURL': driverURL,
        'driverPath': driverImagePath,
        'riderProfileURL': profileURL,
        'riderProfilePath ': profileFilePath,
      });

      // Save geoPoint data locally
      // String locationString = geoPointToJson(geoPoint!);
      //
      // await sharedPreferences!.setString("uid", currentUser.uid);
      // await sharedPreferences!.setString("name", storeName);
      // await sharedPreferences!.setString("email", currentUser.email.toString());
      // await sharedPreferences!.setString("phone", storePhone);
      // await sharedPreferences!.setString("address", address!);
      // await sharedPreferences!.setString("location", locationString);

      // Saving login state locally so user don't have to re-login if the app exits
      // await _authService.setLoginState(true);

      // Close the Loading Dialog
      Navigator.pop(context);
      // Navigate to the main screen if the login is successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RegisterSuccessScreen()),
      );
    } catch (e) {
      if(e.toString().contains('firebase_auth/requires-recent-login')) {
        // Close the Loading Dialog
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (c) {
            print(e);
            return ErrorDialog(message: "Request timeout. Please try again.");
          },
        );

      } else {
        // Close the Loading Dialog
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (c) {
            print(e);
            return ErrorDialog(message: "An error occurred: $e");
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Store Sign Up"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: WillPopScope(
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
        child: Stepper(
          currentStep: _currentStep,
          type: StepperType.horizontal,
          steps: _getSteps(),
          onStepCancel: _onStepCancel,
          onStepContinue: _onStepContinue,
          onStepTapped: (index) {
            // If user taps Step 2 but Step 1 is incomplete, disallow
            if (index > _currentStep && !_isStep1Complete) {
              // Show a message
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Please upload all 3 documents before proceeding."),
              ));
              return;
            }
            setState(() => _currentStep = index);
          },
          controlsBuilder: (context, details) {
            // Build custom step control (Continue/Cancel) row
            final isLastStep = _currentStep == _getSteps().length - 1;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if(!isLastStep)
                  ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Theme.of(context).colorScheme.primary,
                    foregroundColor:
                    Theme.of(context).colorScheme.inversePrimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 50,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text('Continue'),
                ),
                const SizedBox(width: 8),
                // if (_currentStep != 0) // Only show cancel if not on first step
                //   Padding(
                //     padding: const EdgeInsets.only(top: 16),
                //     child: ElevatedButton(
                //       onPressed: details.onStepCancel,
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor:
                //         Theme.of(context).colorScheme.primary,
                //         foregroundColor:
                //         Theme.of(context).colorScheme.inversePrimary,
                //         padding: const EdgeInsets.symmetric(
                //           vertical: 14,
                //         ),
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(4),
                //         ),
                //       ),
                //       child: const Text('Back'),
                //     ),
                //   ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Step> _getSteps() {
    return [
      // Step 1: Document Upload
      Step(
        title: const Text("Documents"),
        isActive: _currentStep >= 0,
        state: _stepState(0),
        content: _buildStep1Content(),
      ),
      // Step 2: Form Fields
      Step(
        title: const Text("Sign up"),
        isActive: _currentStep >= 1,
        state: _stepState(1),
        content: _buildStep2Content(),
      ),
    ];
  }

  // Helper to set the step state: show error if step is not done, complete if done
  StepState _stepState(int stepIndex) {
    if (stepIndex == 0) {
      // Step 1
      return _isStep1Complete ? StepState.complete : StepState.indexed;
    } else {
      // Step 2
      // If user hasn't even completed step 1 yet, we keep it indexed or disabled
      if (!_isStep1Complete) return StepState.disabled;

      // If we have a validated form, we can mark this complete as well
      // but typically, you might only mark it complete after they've done the sign up.
      return StepState.indexed;
    }
  }

  // Step 1 content: three DocumentUploadCards in a row or wrap
  Widget _buildStep1Content() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          //DTI/SEC
          ListTile(
            title: Text('Upload a copy of your Government-Issued ID'),
            leading: PhosphorIcon(
              _idFile == null ? PhosphorIcons.circle(PhosphorIconsStyle.regular,) : PhosphorIcons.checkCircle(PhosphorIconsStyle.fill,),
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8,),
          DocumentUploadCard(
            imageXFile: _idFile,
            label: "Valid ID",
            onTap: () {
              showModalBottomSheet(context: context, builder: (BuildContext context) {
                return UploadDocumentOption(onImageSelected: _getImage, docType: 'id',);
              });
            },
          ),

          //MAYOR'S PERMIT
          ListTile(
            title: Text('Upload a copy of your Driver’s License'),
            leading: PhosphorIcon(
              _driverFile == null ? PhosphorIcons.circle(PhosphorIconsStyle.regular,) : PhosphorIcons.checkCircle(PhosphorIconsStyle.fill,),
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8,),
          DocumentUploadCard(
            imageXFile: _driverFile,
            label: "Driver's License",
            onTap: () {
              showModalBottomSheet(context: context, builder: (BuildContext context) {
                return UploadDocumentOption(onImageSelected: _getImage, docType: 'driver',);
              });
            },
          ),
        ],
      ),
    );
  }

  // Step 2 content: form fields for store details
  Widget _buildStep2Content() {
    return Column(
      children: [
        // Image.asset('assets/create_account.png', scale: 10,),
        DocumentUploadCard(
            imageXFile: _imgFile,
            onTap: () {
              showModalBottomSheet(context: context, builder: (BuildContext context) {
                return UploadDocumentOption(onImageSelected: _getImage, docType: 'image',);
              });
            },
            label: 'Upload profile image'),
        // const SizedBox(height: 8,),
        //Image Validation Text
        Text(
          imgValidate,
          style: const TextStyle(
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
        // const SizedBox(height: 4,),
        Text(
          "${widget.email}",
          style: const TextStyle(
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full Name Text
              const Text(
                'Full Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Full Name Text Field
              CustomTextField(
                labelText: 'Full name',
                controller: nameController,
                isObscure: false,
                validator: validateName,
              ),
              const SizedBox(height: 8),
              // Store Location Text
              const Text(
                'Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Address Text Field
              InkWell(
                borderRadius: BorderRadius.circular(24),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => AddAddressScreen()));

                  if (result != null) {
                    setState(() {
                      address =
                          result['addressEng'].toString().trim();
                      addressController.text = address!;
                      geoPoint = result['location'];
                    });
                  }
                },
                child: IgnorePointer(
                  child: CustomTextField(
                    labelText: 'Select a location',
                    controller: addressController,
                    isObscure: false,
                    validator: validateLocation,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Mobile Number Text + Icon Helper
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Mobile Number',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'To verify your account, make sure you use a valid mobile number.',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.blue,
                          behavior: SnackBarBehavior.floating,
                          action: SnackBarAction(
                            label: 'DISMISS',
                            textColor: Colors.white,
                            onPressed: () {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            },
                          ),
                          duration: const Duration(seconds: 3), // Adjust as needed
                        ),
                      );

                    },
                    child: SizedBox(
                      child: PhosphorIcon(
                        PhosphorIcons.info(
                            PhosphorIconsStyle.regular),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Mobile Number Text Field
              CustomTextField(
                labelText: '+639102445676',
                controller: phoneController,
                isObscure: false,
                validator: validatePhone,
                prefixText: '+63',
              ),
              const SizedBox(height: 8),
              // Password Text
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Password Text Field
              CustomTextField(
                labelText: 'Password',
                controller: passwordController,
                isObscure: _isPasswordHidden,
                validator: validatePassword,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isPasswordHidden = !_isPasswordHidden;
                    });
                  },
                  icon: PhosphorIcon(
                    _isPasswordHidden
                        ? PhosphorIcons.eyeSlash(
                        PhosphorIconsStyle.bold)
                        : PhosphorIcons.eye(
                        PhosphorIconsStyle.bold),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SignUpAgreement(
                  onTermsTap: () {}, onPrivacyTap: () {}),
              const SizedBox(height: 8),
              // Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && _imgFile != null) {
                      // Signup
                      signUp(widget.user);
                    } else {
                      if(_imgFile == null) {
                        setState(() {
                          imgValidate = 'Upload store\'s image or logo';
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Theme.of(context).colorScheme.primary,
                    foregroundColor:
                    Theme.of(context).colorScheme.inversePrimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text("Sign Up"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Step control logic
  void _onStepContinue() {
    final isLastStep = _currentStep == _getSteps().length - 1;

    if (_currentStep == 0) {
      // If user is on step 1
      if (!_isStep1Complete) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Please upload the 2 documents."),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
        return;
      }
      // Move to step 2
      setState(() => _currentStep += 1);
    } else if (isLastStep) {
      // On step 2 (last step), we want to validate form or sign up
      if (_formKey.currentState!.validate()) {
        // Perform sign-up logic here
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("All Done! You can now sign up..."),
        ));
        // e.g., Navigator.pop(context) or push to next screen
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep == 0) return;
    setState(() => _currentStep -= 1);
  }

  Future<void> _getImage(ImageSource source, String docType) async {
    XFile? imageXFile;

    if (docType == 'id' || docType == 'driver' || docType == 'bir') {
      imageXFile = await ImagePickerService().pickCropImage(
        cropAspectRatio: const CropAspectRatio(ratioX: 8.5, ratioY: 13),
        imageSrouce: source,
      );
    } else {
      imageXFile = await ImagePickerService().pickCropImage(
        cropAspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        imageSrouce: source,
      );
    }

    if(imageXFile != null) {
      switch (docType) {
        case 'id':
          bool imageValidate = await validateImage(imageXFile, '');
          if(imageValidate) {
            setState(() {
              _idFile = imageXFile;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("The image you provided isn’t valid. Please try again or choose a different image."),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          break;
        case 'driver':
          bool imageValidate = await validateImage(imageXFile, '');
          if(imageValidate) {
            setState(() {
              _driverFile = imageXFile;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("The image you provided isn’t valid. Please try again or choose a different image."),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          break;
        case 'image':
            setState(() {
              imgValidate = '';
              _imgFile = imageXFile;
            });

          break;
      }
    }
  }
}
