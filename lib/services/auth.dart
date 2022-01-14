import 'package:chat_firebase/services/database.dart';
import 'package:chat_firebase/views/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
    static String userIdKey = "USERIDKEY";
  static String userNameKey = "USERNAMEKEY";
  static String displayNameKey = "USERDISPLAYNAME";
  static String userEmailKey = "USEREMAILKEY";
  static String userProfilePicKey = "USERPROFILEKEY";

  getCurrentUser() async {
    return await auth.currentUser;
  }


  signInWithGoogle(BuildContext context) async {


    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );
      
    UserCredential result =
        await _firebaseAuth.signInWithCredential(credential);

    User? userDetails = result.user;

    if (result != null) { 
      SharedPreferences prefs = await SharedPreferences.getInstance();

    //id
      prefs.setString(userIdKey, userDetails!.uid.toString());

      //mail         
      prefs.setString(userEmailKey, userDetails.email.toString());

        //username
       prefs.setString(userNameKey, userDetails.email.toString().substring(0,userDetails.email.toString().indexOf("@")));

       prefs.setString(displayNameKey, userDetails.displayName.toString());
      
      prefs.setString(userProfilePicKey, userDetails.photoURL.toString());

      Map<String, dynamic> userInfoMap = {
        "email": userDetails.email,
        "username": userDetails.email.toString().substring(0,userDetails.email.toString().indexOf("@")),
        "name": userDetails.displayName,
        "imgUrl": userDetails.photoURL
      };

      DatabaseMethods()
          .addUserInfoToDB(userDetails.uid, userInfoMap)
          .then((value) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));
      });
    }
  }

  Future signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();    
  
    await auth.signOut();
  }
}