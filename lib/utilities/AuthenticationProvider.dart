import 'package:firebase_auth/firebase_auth.dart';


class AuthenticationProvider{
  // FirebaseAuth instance
  final FirebaseAuth firebaseAuth;

  //Constructor to initialize the Firebase Auth instance.
  AuthenticationProvider(this.firebaseAuth);

//Using Stream to listen to Authentication State
  Stream<User?> get authState => firebaseAuth.idTokenChanges();


  //............RUDIMENTARY METHODS FOR AUTHENTICATION................


  //SIGN UP METHOD
  Future<String?> signUp({required String email, required String password}) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return "Signed up!";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  //SIGN IN METHOD
  Future<String?> signIn({required String email, required String password}) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return "Signed in!";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  //SIGN OUT METHOD
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

}