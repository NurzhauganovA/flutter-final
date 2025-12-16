import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Получить текущего пользователя
  User? get currentUser => _auth.currentUser;

  // Поток для отслеживания статуса (вошел/вышел)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Вход по Email/Password
  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Регистрация
  Future<void> signUp({required String email, required String password}) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  // Выход
  Future<void> signOut() async {
    await _auth.signOut();
  }
}