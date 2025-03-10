import 'package:delivery_service_riders/global/global.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //Check if the user is logged in
  Future<bool> isLoggedIn() async {
    bool isLoggedIn = sharedPreferences!.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      //Verify if the user is still logged in via Firebase AUth
      User? user = firebaseAuth.currentUser;
      if(user != null) {
        //User is logged in in Firebase Auth
        return true;
      } else {
        //User is logged out in Firebase Auth
        return false;
      }
    }

    //Not logged in
    return false;
  }

  //Set the login state in SharedPreferences
  Future<void> setLoginState(bool state) async {
    await sharedPreferences!.setBool('isLoggedIn', state);
  }
}