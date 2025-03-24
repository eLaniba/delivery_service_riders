
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/models/riders.dart';
import 'package:delivery_service_riders/services/image_picker_service.dart';
import 'package:delivery_service_riders/services/util.dart';
import 'package:delivery_service_riders/widgets/circle_image_avatar.dart';
import 'package:delivery_service_riders/widgets/confirmation_dialog.dart';
import 'package:delivery_service_riders/widgets/custom_text_field.dart';
import 'package:delivery_service_riders/widgets/show_floating_toast.dart';
import 'package:delivery_service_riders/widgets/status_widget.dart';
import 'package:delivery_service_riders/widgets/upload_document_option.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  //Image
  XFile? riderProfileNew;

  // Controllers for the text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Get the current user ID from Firebase Auth
  String? get currentUserId => firebaseAuth.currentUser!.uid;

  // Stream for the current user document from Firestore
  Stream<DocumentSnapshot<Map<String, dynamic>>> get _userStream {
    return FirebaseFirestore.instance
        .collection('riders')
        .doc(currentUserId)
        .snapshots();
  }

  Future<void> _getImage(ImageSource source, String docType) async {
    XFile? imageXFile;

    if (docType == 'profile') {
      imageXFile = await ImagePickerService().pickCropImage(
        cropAspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        imageSrouce: source,
      );
    }

    if(imageXFile != null) {
      switch (docType) {
        case 'profile':
        // Show confirmation dialog
          bool? isConfirm = await ConfirmationDialog.show(
            context,
            'Change Profile?',
            'Are you sure you want to change your profile?',
          );

          if (isConfirm == true) {
            uploadImage(imageXFile, 'profile');
          }
          break;
      }
    }
  }

  void uploadImage(XFile imageXFile, String imageType) async {
    DocumentReference riderDocument = firebaseFirestore.collection('riders').doc(currentUserId);
    showFloatingToast(
      context: context,
      message: 'Uploading image, please wait...',
    );

    try {
      switch (imageType) {
        case 'profile':
          String profileFileName = 'profile_file';
          String profileFilePath = 'riders/$currentUserId/images/$profileFileName';
          String profileURL = await uploadFileAndGetDownloadURL(file: imageXFile, storagePath: profileFilePath);

          await riderDocument.update({
            "riderProfileURL": profileURL,
          });
          break;
      }

      showFloatingToast(
        context: context,
        backgroundColor: Colors.green,
        message: 'Image upload successful.',
      );

    } catch(e) {
      showFloatingToast(context: context, message: 'An unknown error occurred, please try again');
    }
  }


  // Save profile changes to Firestore
  Future<void> _saveProfile() async {
    if (currentUserId == null) return;
    await firebaseFirestore.collection('riders').doc(currentUserId).update({
      'riderName': _nameController.text.trim(),
      // 'userEmail': _emailController.text,
      'riderPhone': _phoneController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  Future<void> verifyAndActivatePhone(String phoneNumber) async {
    final User? user = firebaseAuth.currentUser;
    if (user == null) {
      debugPrint('No user signed in');
      return;
    }

    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Automatic verification: directly link the phone credential
        try {
          UserCredential userCredential = await user.linkWithCredential(credential);
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'phoneVerified': true,
            'userPhone': userCredential.user?.phoneNumber,
          });
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
              content: Text("Phone verified successfully!"),
                backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          debugPrint("Error during auto-verification: $e");
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint("Verification failed: ${e.message}");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification failed: ${e.message}"))
        );
      },
      codeSent: (String verificationId, int? resendToken) async {
        // Manual verification: prompt user to enter the OTP
        String smsCode = await _getSmsCodeFromUser(context);
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: smsCode);
        try {
          UserCredential userCredential = await user.linkWithCredential(credential);
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'phoneVerified': true,
            'userPhone': userCredential.user?.phoneNumber,
          });
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Phone verified successfully!"))
          );
        } catch (e) {
          debugPrint("Error during linking: $e");
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error linking phone number: $e"))
          );
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint("Code auto-retrieval timeout");
      },
    );
  }

  // Helper method to prompt the user for the OTP.
  Future<String> _getSmsCodeFromUser(BuildContext context) async {
    String smsCode = '';
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter OTP'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              smsCode = value;
            },
            decoration: const InputDecoration(
              labelText: 'OTP',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
    return smsCode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('User data not available')),
          );
        }

        // Create a Users object from the Firestore data
        final data = snapshot.data!.data()!;
        Riders rider = Riders.fromJson(data);

        // Only update controllers if they haven't been modified yet
        if (_nameController.text.isEmpty) {
          _nameController.text = rider.riderName ?? '';
        }
        if (_emailController.text.isEmpty) {
          _emailController.text = rider.riderEmail ?? '';
        }
        if (_phoneController.text.isEmpty) {
          _phoneController.text = rider.riderPhone ?? '';
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pressable Circle Avatar
                Center(
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(context: context, builder: (BuildContext context) {
                        return UploadDocumentOption(onImageSelected: _getImage, docType: 'profile',);
                      });
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleImageAvatar(
                          imageUrl: rider.riderProfileURL,
                          size: 100,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 2,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                PhosphorIcons.camera(PhosphorIconsStyle.fill),
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Name field
                const Text(
                  "Name",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Enter your name',
                  isObscure: false,
                ),
                const SizedBox(height: 20),
                // Email Text
                Row(
                  children: [
                    const Text(
                      "Email",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4,),
                    verifiedStatusWidget(rider.emailVerified!),
                  ],
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Enter your email',
                  enabled: false,
                  isObscure: false,
                  inputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                // Mobile Number field
                Row(
                  children: [
                    const Text(
                      "Mobile Number",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4,),
                    verifiedStatusWidget(rider.phoneVerified!),
                  ],
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Enter your mobile number',
                  isObscure: false,
                  inputType: TextInputType.phone,
                  suffixIcon: rider.phoneVerified == false
                      ? TextButton(
                          style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                          ),
                          onPressed: () {
                            print('Verify is clicked!');
                            // Implement your phone verification logic here.
                            verifyAndActivatePhone(_phoneController.text.trim());
                          },
                          child: const Text("Verify"),
                        )
                      : null,
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context).primaryColor,
              ),
              height: 60,
              child: TextButton(
                onPressed: _saveProfile,
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
