
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/authentication/auth_screen.dart';
import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/mainScreens/profile_screens/edit_profile_screen.dart';
import 'package:delivery_service_riders/mainScreens/profile_screens/earnings_screen.dart';
import 'package:delivery_service_riders/mainScreens/profile_screens/order_history_screen.dart';
import 'package:delivery_service_riders/models/riders.dart';
import 'package:delivery_service_riders/services/auth_service.dart';
import 'package:delivery_service_riders/services/util.dart';
import 'package:delivery_service_riders/widgets/circle_image_avatar.dart';
import 'package:delivery_service_riders/widgets/confirmation_dialog.dart';
import 'package:delivery_service_riders/widgets/status_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  void logout() async {
    bool? isLogOut = await ConfirmationDialog.show(
      context,
      'Confirmation',
      'Are you sure you want to logout?',
    );

    if(isLogOut == true) {
      await _authService.setLoginState(false);
      await sharedPreferences!.clear();
      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AuthScreen()));
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (_) => AuthScreen()),
      // );
      // Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: StreamBuilder<DocumentSnapshot>(
          stream: firebaseFirestore
              .collection('riders')
              .doc(sharedPreferences!.getString('uid'))
              .snapshots(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError){
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Store does not exist.'));
            }

            final docData = snapshot.data!.data() as Map<String, dynamic>;
            final rider = Riders.fromJson(docData);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //First container
                Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // InkWell(
                      //   onTap: () {},
                      //   child: CircleAvatar(
                      //     radius: 60,
                      //     backgroundImage: store.storeImageURL != null
                      //         ? NetworkImage(store.storeImageURL!)
                      //         : const AssetImage('assets/avatar.png')
                      //             as ImageProvider,
                      //     backgroundColor: Colors.white,
                      //   ),
                      // ),
                      CircleImageAvatar(
                        imageUrl: rider.riderProfileURL,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rider.riderName ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            reformatPhoneNumber(rider.riderPhone!) ?? '',
                            style: TextStyle(color: gray),
                          ),
                          const SizedBox(width: 4),
                          verifiedStatusWidget(rider.phoneVerified ?? false),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Divider(
                        color: Colors.black.withOpacity(0.05),
                        indent: 32,
                        endIndent: 32,
                        height: 24,
                      ),
                      // Pressable ListTile with Edit Icon, Title and Arrow
                      ListTile(
                        leading: PhosphorIcon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.fill), color: Theme.of(context).primaryColor,),
                        title: const Text('Edit Profile'),
                        trailing: PhosphorIcon(PhosphorIcons.caretRight(PhosphorIconsStyle.regular),),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: PhosphorIcon(PhosphorIcons.currencyDollar(PhosphorIconsStyle.fill), color: Theme.of(context).primaryColor,),
                        title: const Text('Earnings'),
                        trailing: PhosphorIcon(PhosphorIcons.caretRight(PhosphorIconsStyle.regular),),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => EarningsScreen(riderID: sharedPreferences!.getString('uid')!,)));
                        },
                      ),
                    ],
                  ),
                ),
                //Second container
                Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      // Order History ListTile
                      ListTile(
                        leading: PhosphorIcon(PhosphorIcons.boxArrowDown(PhosphorIconsStyle.fill), color: Theme.of(context).primaryColor,),
                        title: const Text('Order History'),
                        trailing: PhosphorIcon(PhosphorIcons.caretRight(PhosphorIconsStyle.regular),),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OrderHistoryScreen(),
                            ),
                          );
                        },
                      ),
                      Divider(
                        color: Colors.black.withOpacity(0.05),
                        indent: 32,
                        height: 0,
                      ),

                      // Logout ListTile with text colored by the primary color from the context
                      ListTile(
                        leading: PhosphorIcon(PhosphorIcons.signOut(PhosphorIconsStyle.fill), color: Colors.red,),
                        title: const Text('Logout', style: TextStyle(color: Colors.red),),
                        trailing: PhosphorIcon(PhosphorIcons.caretRight(PhosphorIconsStyle.regular), color: Colors.red,),
                        onTap: () {
                          logout();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );

          },
        ),
      ),
    );


  }
}
