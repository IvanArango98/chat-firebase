import 'package:chat_firebase/helperfunctions/shared_helper.dart';
import 'package:chat_firebase/views/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMethos{
  final FirebaseAuth auth = FirebaseAuth.instance;
  getCurrentUser(){
    return auth.currentUser;
  }

  SignInWithGoogle(BuildContext context) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication? googleSignInAuthentication = await googleSignInAccount?.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication?.idToken,
      accessToken: googleSignInAuthentication?.accessToken
    );
    
    UserCredential result = await _firebaseAuth.signInWithCredential(credential);
    User? userDetails = result.user;

    if(result != null)
    {
      SharedPreferenceHelper().saveUserEmail(userDetails!.email.toString());
      SharedPreferenceHelper().saveUserId(userDetails!.uid.toString());
      SharedPreferenceHelper().saveDisplayName(userDetails!.displayName.toString());
      SharedPreferenceHelper().saveUserProfileUrl(userDetails!.photoURL.toString());            
    }
    else{

    }

  }



}