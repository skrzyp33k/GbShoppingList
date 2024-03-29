import 'package:firebase_auth/firebase_auth.dart';
import 'package:gb_shopping_list/models/user.dart';
import 'package:gb_shopping_list/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //create User object

  UserModel? _createModel(User? user) {
    return user != null
        ? UserModel(
            uid: user.uid, emailVerified: user.emailVerified, email: user.email)
        : null;
  }

  String? get uid {
    return _auth.currentUser?.uid;
  }

  //auth change user stream
  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_createModel);
  }

  //getter for instance
  FirebaseAuth get instance {
    return _auth;
  }

  //send verification email
  void sendEmailVerification() {
    _auth.currentUser?.sendEmailVerification();
  }

  //register with email and password
  Future registerEmail(
      {required String email, required String password}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      sendEmailVerification();
      DatabaseService(uid: user!.uid).addNewUser();
      return _createModel(user);
    } catch (ex) {
      return null;
    }
  }

  //sign in with email and password

  Future signInEmail({required String email, required String password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _createModel(user);
    } catch (ex) {
      return null;
    }
  }

  //sign out

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (ex) {
      return null;
    }
  }

  //delete user
  void deleteUser() async {
    await DatabaseService(uid: _auth.currentUser!.uid).deleteUserSpace();
    await _auth.currentUser!.delete();
    signOut();
  }
}
