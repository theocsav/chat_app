import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  
  // instance of auth and firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // sign in
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      // sign user in
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // save user information in a separate document
      

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }
  // sign up
  Future<UserCredential> signUpWithEmailPassword(String name, email, password, language) async {
    try {
      // create user
      UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
          email: email, 
          password: password
        );
      
      // save user information in a separate document
      _firestore.collection("Users").doc(userCredential.user!.uid).set(
        {
          'name': name,
          'uid': userCredential.user!.uid,
          'email': email,
          'language': language
        },
      );
        
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }
  // sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }
  // errors
}