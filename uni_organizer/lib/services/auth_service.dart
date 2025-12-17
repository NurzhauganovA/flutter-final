import 'package:firebase_auth/firebase_auth.dart';
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp({required String email, required String password}) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);

    if (result.user != null) {
      await DatabaseService(uid: result.user!.uid).createUserProfile(email);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}