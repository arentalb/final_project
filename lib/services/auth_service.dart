import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  final _authInstance = FirebaseAuth.instance;
  Future<User?> signup(String email, String password, String name) async {

    try {
     UserCredential userCredential = await _authInstance
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        await user.updateProfile(displayName: name);
        await user.reload();
        user = _authInstance.currentUser;
      }
      return user;
} on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'پاسۆردەکەت ضعیفە';
      } else if (e.code == 'email-already-in-use') {
        throw 'ئیمەیلەکەت پێشتر بەکارهێنراوە';
      }
    } catch (e) {
      throw 'هەڵەیەک ڕوویدا';
    }
    return null;
  }

  Future<User?> signin(String email, String password) async {
    try {
      UserCredential userCredential = await _authInstance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        throw ' پاسسۆردەکەت هەڵەی یان هەژمارەکەت نەدۆزرایەوە';
      }
    } catch (e) {
      throw 'هەڵەیەک ڕوویدا';
    }
    return null;
  }

  Future<void> signout() async {
    await _authInstance.signOut();
  }
}
